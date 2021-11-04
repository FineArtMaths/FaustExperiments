import("stdfaust.lib");

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(hslider("gain", 0.5, 0, 1, 0.01));
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

gFreq = freq * pitchwheel;

generalGroup(x) = hgroup("General",x);
volume = generalGroup(hslider("Overall Volume", 0.12, 0.0, 1.0, 0.01) /4);
treble = generalGroup(3 - hslider("Treble", 0.62, 0, 3, 0.01) + 0.001);
bass = generalGroup(3 - hslider("Bass", 2.25, 0, 3, 0.01) + 0.001);
energyLoss = generalGroup(hslider("Energy Loss", 0.02, 0, 1.0, 0.001) / 3);

exciterGroup(x) = hgroup("Exciter",x);
excAttack = exciterGroup(hslider("Attack Time", 0, 0, 1, 0.001));
excSus = exciterGroup(hslider("Sustain", 0.549, 0, 1, 0.001));
noiseDensity = exciterGroup(hslider("Pick hardness", 2141, 0, 10000, 1) + (gain - 0.5) * noiseDensityVel);
noiseDensityVel = exciterGroup(hslider("Pick hardness velocity sensitivity", 200, 0, 10000, 1));
excShape = exciterGroup(hslider("Noise / Square", 0.012, 0.0, 0.2, 0.001));
excVel = exciterGroup(hslider("Velocity Multiplier", 1.0, 0.01, 2.0, 0.01));


bodyGroup(x) = hgroup("Body",x);
rez1 = bodyGroup(vslider("H01", 0, 0, 0.5, 0.01));
rez2 = bodyGroup(vslider("H02", 0, 0, 0.5, 0.01));
rez3 = bodyGroup(vslider("H03", 0, 0, 0.5, 0.01));
rez4 = bodyGroup(vslider("H04", 0, 0, 0.5, 0.01));
rez5 = bodyGroup(vslider("H05", 0, 0, 0.5, 0.01));
rez6 = bodyGroup(vslider("H06", 0, 0, 0.5, 0.01));
rez7 = bodyGroup(vslider("H07", 0, 0, 0.5, 0.01));
rez8 = bodyGroup(vslider("H08", 0, 0, 0.5, 0.01));
rez9 = bodyGroup(vslider("H09", 0, 0, 0.5, 0.01));
rez10 = bodyGroup(vslider("H10", 0, 0, 0.5, 0.01));
rez11 = bodyGroup(vslider("H11", 0, 0, 0.5, 0.01));
rez12 = bodyGroup(vslider("H12", 0, 0, 0.5, 0.01));
rezAmt = bodyGroup(vslider("H Amt", 15, 15, 55, 1));

exciter(f) = no.lfnoise0(noiseDensity) * (1 - excShape), os.square(f/2) * excShape : +  : _ * excVel;
enxciterEnv = en.adsr(excAttack, excAttack + 0.1, (1.0, 0.0 : select2(excSus == 0.0)),0.0, gate) * (excSus, 1.0 : select2(excSus == 0.0));

resonator = _ , 
	fi.resonlp(gFreq * 1,rezAmt,rez1),
	fi.resonlp(gFreq * 2,rezAmt,rez2),
	fi.resonlp(gFreq * 3,rezAmt,rez3),
	fi.resonlp(gFreq * 4,rezAmt,rez4),
	fi.resonlp(gFreq * 5,rezAmt,rez5),
	fi.resonlp(gFreq * 6,rezAmt,rez6),
	fi.resonlp(gFreq * 7,rezAmt,rez7),
	fi.resonlp(gFreq * 8,rezAmt,rez8),
	fi.resonlp(gFreq * 9,rezAmt,rez9),
	fi.resonlp(gFreq * 10,rezAmt,rez10),
	fi.resonlp(gFreq * 11,rezAmt,rez11),
	fi.resonlp(gFreq * 12,rezAmt,rez12)
  :> _ / (rez1 + rez2 + rez3 + rez4 + rez5 + rez6 + rez7 + rez8 + rez9 + rez10 + rez11 + rez12 + 1);

oscillator(h, d) = 
	exciter(gFreq * h + d) * enxciterEnv : 
	fi.fb_fcomb(44100,ma.SR/(gFreq * h + d),1.0,0.999 - energyLoss/10), 1 - energyLoss/5 : 
	* : 
	fi.lowpass(1, freq * treble) : 
	fi.fb_fcomb(44100,ma.SR/(gFreq * h + d),1.0,-0.999 + energyLoss/10) :
	fi.highpass(1, freq / bass);


voice = oscillator(1, 0) * gain * gate;

process = voice  * volume <: resonator <: _,_  ;

effect = dm.phaser2_demo : dm.freeverb_demo;
			