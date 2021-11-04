import("stdfaust.lib");

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(hslider("gain", 0.5, 0, 1, 0.01));
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));

feedback = checkbox("comb"); //hslider("feed", 1.0, 0.9, 1.0, 0.0001);
sustain = hslider("sustain", 0.01, 0.0, 0.1, 0.0001);
noise = hslider("noise vs tone", 0.5, 0.0, 1.0, 0.0001);
noiseDensity = hslider("noise density", 10000, 10, 10000, 1);
excEnv = en.adsr(0.1, 0.1, 1.0, 0.0, gate);

filterCutoff = hslider("lowpass", 2.0, 1.0, 10.0, 0.1);
filterQ = hslider("lowpass Q", 100.0, 5.0, 100.0, 0.1);

modulationDepth = hslider("Modulation depth", 0.0, 0.0, 0.05, 0.001);
modulationSpeed = hslider("Modulation rate", 0.01, 0.0, 20, 0.01);


overallEnv = en.adsr(0.1, 0.0, 1.0, 1.0, gate);
overallVolume = hslider("volume", 1.0, 0.0, 1.0, 0.0001);

// pitchwheel
pitchwheel = hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001);
gFreq = freq * pitchwheel;

// Global gain is set to 1 for now
gGain = 1.0;

comb(f, feed) = fi.fb_fcomb(44100, ma.SR/(f), 1.0, -1 * feed);

exciterOsc(h) = (no.lfnoise0(noiseDensity) * noise + (os.osc(gFreq * h)) * (1 - noise));
exciter(h) = exciterOsc(h) * gate * gGain * excEnv * sustain;

harmonic(h) = exciter(h) <: comb(gFreq * h, -1 * feedback) * 0.5 + comb(gFreq * h * (1 + modulationDepth * (os.lf_triangle(1/modulationSpeed)) - 0.5), -1 * feedback) * 0.5 <: 
	_ +
	fi.resonlp(gFreq * filterCutoff, filterQ, 1.0) +
	fi.resonlp(gFreq * filterCutoff * 2, filterQ, 1.0) +
	fi.resonlp(gFreq * filterCutoff * 3, filterQ, 1.0)
	  ;
timbre = harmonic(1) + 0.5 * harmonic(2) + 0.3 * harmonic(3);

process = timbre * overallEnv * overallVolume <:_,_;
//effect = dm.phaser2_demo;
