import("stdfaust.lib");

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(hslider("gain", 0.5, 0, 1, 0.01));
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

gFreq = freq * pitchwheel;

generalGroup(x) = hgroup("1. General",x);
volume = generalGroup(hslider("Overall Volume", 0.1, 0.0, 1.0, 0.01) /4);
treble = generalGroup(3 - hslider("Treble", 1.4, 0, 3, 0.01) + 0.001);
bass = generalGroup(3 - hslider("Bass", 1.6, 0, 3, 0.01) + 0.001);
energyLoss = generalGroup(hslider("Energy Loss", 0.02, 0, 1.0, 0.001) / 3);
filt = generalGroup(hslider("Filter", 0.0, 0.0, 1.0, 0.01));

keyGroup(x) = hgroup("2. Key noise",x);
keyLevel = keyGroup(hslider("Level", 0.2, 0.0, 1.0, 0.01) * 30);
keyFreq = keyGroup(hslider("Frequency", 0.5, 0, 1.5, 0.25));
keyRand = keyGroup( hslider("Humanize", 0.5, 0, 1, 0.01));

exciterGroup(x) = hgroup("3. Exciter",x);
excAttack = exciterGroup(hslider("Attack Time", 0.0, 0, 1, 0.001));
excSus = exciterGroup(hslider("Sustain", 0.35, 0, 1, 0.001));
noiseDensity = 2000;
excReediness = exciterGroup(hslider("Reed (Clarinet <--> Oboe)", 0.35, 0, 1, 0.001));
bite = exciterGroup(hslider("Bite", 0.0, 0.0, 5.0, 0.5));

noiseosc = ((os.osc(0.1) + os.osc(0.37) + os.osc(0.731) + 3) / 6);
  
noiseShape = en.adsr(excAttack*(1 - gain)/2, 0.0, 1.0, 0.1, gate) * noiseosc;
breathOsc(f) = (no.lfnoise0(noiseDensity) * (1 - excReediness) + os.triangle(f) * excReediness)/2 : fi.resonbp(f * (1 + bite) + os.triangle(bite * 1000) * bite, bite * 20 + 0.01, 1.0 + bite);
exciter(f) = breathOsc(f) * (1 - noiseShape), os.square(f/2) * noiseShape/8 : +;
enxciterEnv = en.adsr(excAttack, excAttack + 0.1, (1.0, 0.0 : select2(excSus == 0.0)),0.0, gate) * (excSus, 1.0 : select2(excSus == 0.0));

ingain = 0.99;
oscillator(h, d) = 
	exciter(gFreq * h + d) * enxciterEnv : 
	fi.fb_fcomb(44100,ma.SR/(gFreq * h + d),ingain,0.999 - energyLoss/10), 1 - energyLoss/2 : * : 
	fi.lowpass(1, freq * treble) : 
	fi.fb_fcomb(44100,ma.SR/(gFreq * h + d),ingain,-0.999 + energyLoss/10), 1 - energyLoss/2 : *  :
	fi.highpass(1, freq / bass);

keyOscillator = os.osc(gFreq * keyFreq) * gain : fi.fb_fcomb(44100,ma.SR/(gFreq * keyFreq),1.0,0.9) * keyLevel * (1 + (no.lfnoise0(1)  * keyRand - 0.5)); 

voice = (oscillator(1, 0) + keyOscillator)   * gain * gate <: fi.resonbp(gFreq * (1 + filt * 6), filt * 20 + 1, 1.0), _ : select2(filt == 0);

process = voice  * volume * 4 <: _,_  ;

effect = /*dm.phaser2_demo :*/ dm.freeverb_demo;		// phaser sounds good but it's a bit of a cheat
