import("stdfaust.lib");

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(nentry("gain", 1, 0, 1, 0.01)) * en.adsr(0.0, 0.1, 0.7, 1.0, gate);
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01))* pitchwheel;
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

/*

Delay Modulation

*/

///////////////
// GUI
///////////////

modFreqFine = hslider("DM Fine", 0.01, 0.0, 1, 0.001);
modFreqCoarse = hslider("DM Course", 2, 1, 20, 1);

modAmpCoarse =  hslider("DM Amp Coarse", 0, 0, 5000, 100);
modAmpFine =  hslider("DM Amp Fine", 0, 0, 100, 1);
modAmp = modAmpCoarse + modAmpFine;

modWave =  hslider("DM Wave", 0, 0, 2, 1);
lpc = hslider("LPF Cutoff", 10000, -10000, 10000, 10);
hpc = hslider("HPF Cutoff", 0, -10000, 10000, 10);
volume = hslider("Overall volume", 1, 0, 1, 0.01);
ampModFreqFine = hslider("Amp Mod Freq Fine", 0.0, 0.0, 1, 0.001);
ampModFreqCoarse = hslider("Amp Mod Freq Coarse", 0, 0, 10, 1);
ampModFreq = ampModFreqFine  + ampModFreqCoarse;
ampModWidth = hslider("Amp Mod Width", 0, 0, 1, 0.001);

feedback = hslider("Feedback", 0.99, 0, 0.99, 0.01);


///////////////
// Algorithm
///////////////

// Calc the delay time based on current pitch and GUI settings 
dmFreqCalc = max(0.1, freq * (modFreqCoarse + modFreqFine  + os.osc(freq * (ampModFreqFine + ampModFreqCoarse)) * ampModWidth));

// A delay line with feedback; delay time is calculated by dmFreqCalc
delayline = + ~ (@(ma.SR/dmFreqCalc) : *(feedback));

process = os.osc(freq) * gate * gain : delayline : fi.lowpass6e(min(20000, freq + lpc))  : fi.highpass(6, max(1, freq + hpc)) * volume <: _,_;
effect = dm.freeverb_demo;


