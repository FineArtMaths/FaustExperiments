import("stdfaust.lib");

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(hslider("gain", 0.5, 0, 1, 0.01));
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

gFreq = freq * pitchwheel;

generalGroup(x) = hgroup("1. General",x);
volume = generalGroup(hslider("Overall Volume", 0.12, 0.0, 1.0, 0.01) /4);
treble = generalGroup(3 - hslider("Treble", 0.62, 0, 3, 0.01) + 0.001);
bass = generalGroup(3 - hslider("Bass", 2.25, 0, 3, 0.01) + 0.001);
energyLoss = generalGroup(hslider("Energy Loss", 0.02, 0, 1.0, 0.001) / 3);

keyGroup(x) = hgroup("2. Key Noise",x);
keyClick = keyGroup(hslider("Tine level", 0.2, 0, 1.0, 0.001));
keyClickF = keyGroup(hslider("Tine Freq", 9, 1, 20, 0.25));
keyClickSus = keyGroup(hslider("Tine Sustain", 0, 0, 1, 0.01) * 0.01 + 0.99);
keyClickInharm = keyGroup(hslider("Tine Inharmonicty", 0.1, 0, 0.5, 0.001));
keyThud = keyGroup(hslider("Key thud", 1.0, 0, 2.0, 0.01));
keyThudF = keyGroup(hslider("Key thud Freq", 150, 10, 300.0, 1));
keyNoiseAttackEffect = keyGroup(hslider("Vel sens", 1.0, 0.0, 1.0, 0.01));

exciterGroup(x) = hgroup("3. Exciter",x);
excAttack = exciterGroup(hslider("Attack Time", 0, 0, 1, 0.001));
excSus = exciterGroup(hslider("Sustain", 0.0, 0, 1, 0.001));
noiseDensity = exciterGroup(hslider("Pick hardness", 2141, 0, 10000, 1));
excShape = exciterGroup(hslider("Noise / Square", 0.012, 0.0, 0.2, 0.001));
excVel = exciterGroup(hslider("Velocity Multiplier", 1.0, 0.01, 2.0, 0.01));


bodyGroup(x) = hgroup("4. Body",x);
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
rezBloom = bodyGroup(vslider("Bloom", 0, 0, 2, 0.01));
rezA = bodyGroup(vslider("Amount", 30, 15, 100, 1));
rezAmt = rezA  * en.adsr(rezBloom, 0.0, 1.0, 1.0, gate);

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

keyClickOsc = os.osc(keyClickF * gFreq) + os.osc(keyClickF * gFreq*(1 + keyClickInharm)) + os.osc(keyClickF * gFreq * (1 + keyClickInharm * 2)) :  _ * en.adsr(0.0, 0.01, 0.0, 0.01, gate) : fi.fb_fcomb(44100,ma.SR/140, 1.0, keyClickSus) ;
keyThudOsc = os.osc(keyThudF) + os.osc(keyThudF*1.005) + os.osc(keyThudF * 1.01) :  _ * en.adsr(0.0, 0.01, 0.0, 0.01, gate) : fi.fb_fcomb(44100,ma.SR/140, 1.0, -0.9) ;

keyNoise = (keyClickOsc * keyClick +  keyThudOsc * keyThud) * (keyNoiseAttackEffect * gain + (1 - keyNoiseAttackEffect));

voice = (oscillator(1, 0) +  keyNoise)   * gain * gate;

process = voice  * volume <: resonator <: _,_  ;

effect = /*dm.phaser2_demo :*/ dm.freeverb_demo;		// phaser sounds good but it's a bit of a cheat
			