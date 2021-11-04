import("stdfaust.lib");

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(nentry("gain", 1, 0, 1, 0.01)) * en.adsr(0.0, 0.1, 0.7, 1.0, gate);
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01))* pitchwheel;
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

/*

Delay Modulation

*/

modFreqFine = hslider("DM Fine", 0.01, 0.0, 1, 0.001);
modFreqCoarse = hslider("DM Course", 0, 0, 20, 1);

modAmpCoarse =  hslider("DM Amp Coarse", 0, 0, 5000, 100);
modAmpFine =  hslider("DM Amp Fine", 0, 0, 100, 1);
modAmp = modAmpCoarse + modAmpFine;

modWave =  hslider("DM Wave", 0, 0, 2, 1);
lpc = hslider("LPF Cutoff", 10000, -10000, 10000, 10);
hpc = hslider("HPF Cutoff", 0, -10000, 10000, 10);
volume = hslider("Overall volume", 1, 0, 1, 0.01);
ampModFreqFine = hslider("Amp Mod Freq Fine", 0, 0, 1, 0.001);
ampModFreqCoarse = hslider("Amp Mod Freq Coarse", 0, 0, 50, 1);
ampModFreq = ampModFreqFine  + ampModFreqCoarse;
ampModWidth = hslider("Amp Mod Width", 0, 0, 500, 1);
ampFreqMult = 1, freq/128:  select2(checkbox("Follow Pitch"));

dmOsc(f) = modWave, os.triangle(f), os.osc(f), os.sawtooth(f) : select3;
dmFreqCalc = freq * (modFreqCoarse + modFreqFine);

modAmplitude = min(3000, max(0, modAmp + os.osc(ampModFreq) * ampModWidth));
modAmpCalc = modAmplitude * ampFreqMult;

process = os.osc(freq) * gate * gain : @(min(10000, max(0, dmOsc(dmFreqCalc) * modAmpCalc))) : fi.lowpass(6, min(20000, freq + lpc))  : fi.highpass(6, max(1, freq + hpc)) * volume <: _,_;
effect = dm.freeverb_demo;