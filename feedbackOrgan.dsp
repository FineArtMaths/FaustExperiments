import("stdfaust.lib");
/*
	This is a playable synth whose oscillators are used as exciters for comb filters. 
	It seems to be able to do organs, glass harmonicas, wood / plastic / metal percussion etc.

	WARNING: It can still make very loud sounds if the Drive on any oscillator is turned up while the Tuning is close to 1.0
	
	TO DO:
		* Add a noise oscillator or two
		* Maybe global noise oscillator on the amplitude just to create a bit of analogue variation
		* Include a detuning envelope per harmonic
		* Try to capture pitch wheel, mod wheel and key release (to add a key release noise)
		* Save and load a preset
		* Microtuning
*/

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = en.adsr(0.0, 0.1, 0.7, 1.0, gate);
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));

generalGroup(x) = hgroup("General",x);
unison = generalGroup(hslider("Unison", 0.0, 0.0, 0.1, 0.001));
unisonOnset = generalGroup(hslider("Unison Onset", 0.0, 0.0, 3.0, 0.1));
unisonOnsetEnv = en.adsr(unisonOnset, 0.0, unison, unisonOnset, gate);
baseLevel = generalGroup(hslider("Volume", 0.3, 0.0, 1.0, 0.001));
fmOscRate = generalGroup(hslider("FM Osc Rate", 0.1, 0.01, 200.0, 0.01));
fmOscAmt = generalGroup(hslider("FM Osc Amt", 0.0, 0.0, fmMaxRate, 1));

// Default values for setting up sliders to make them easier to change
minA = 0.0;
maxA = 2.0;
maxDr = 100.0;
baseFeedback = 0.999;
minfeed = 0.0;
maxfeed = 1.0;
fmMaxRate = 5000;

h1Group(x) = hgroup("Harmonic 1",x);
h1Harm = h1Group(hslider("Harmonic", 1, 1, 20, 1));
h1Tuning = h1Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h1Drive = h1Group(hslider("Drive", 0.1, 0.0, maxDr, 0.01));
h1Attack = h1Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h1Decay = h1Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h1Feedback = h1Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h1Sustain = h1Group(checkbox("Sustain"));
h1env = en.adsr(ba.if(h1Perc == 0, h1Attack, h1Attack / 100), ba.if(h1Perc == 0, h1Decay, h1Decay / 100), ba.if(h1Sustain == 0, 0.0, 1.0), h1Decay, gate);
h1Perc = h1Group(checkbox("Percussive"));
h1FMAmount = h1Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h1FMFreq = h1Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h1FMOnset = h1Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h1FMenv = en.adsr(h1FMOnset, 0.0, 1.0, h1FMOnset, gate);

h2Group(x) = hgroup("Harmonic 2",x);
h2Harm = h2Group(hslider("Harmonic", 2, 1, 20, 1));
h2Tuning = h2Group(hslider("Tuning", 1, 0.9, 1.1, 0.0001));
h2Drive = h2Group(hslider("Drive", 0.1, 0.0, maxDr, 0.01));
h2Attack = h2Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h2Decay = h2Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h2Feedback = h2Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h2Sustain = h2Group(checkbox("Sustain"));
h2Perc = h2Group(checkbox("Percussive"));
h2env = en.adsr(ba.if(h2Perc == 0, h2Attack, h2Attack / 100), ba.if(h2Perc == 0, h2Decay, h2Decay / 100), ba.if(h2Sustain == 0, 0.0, 1.0), h2Decay, gate);
h2FMAmount = h2Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h2FMFreq = h2Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h2FMOnset = h2Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h2FMenv = en.adsr(h2FMOnset, 0.0, 1.0, h2FMOnset, gate);

h3Group(x) = hgroup("Harmonic 3",x);
h3Harm = h3Group(hslider("Harmonic", 3, 1, 20, 1));
h3Tuning = h3Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h3Drive = h3Group(hslider("Drive", 0.1, 0.0, maxDr, 0.01));
h3Attack = h3Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h3Decay = h3Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h3Feedback = h3Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h3Sustain = h3Group(checkbox("Sustain"));
h3Perc = h3Group(checkbox("Percussive"));
h3env = en.adsr(ba.if(h3Perc == 0, h3Attack, h3Attack / 100), ba.if(h3Perc == 0, h3Decay, h3Decay / 100), ba.if(h3Sustain == 0, 0.0, 1.0), h3Decay, gate);
h3FMAmount = h3Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h3FMFreq = h3Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h3FMOnset = h3Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h3FMenv = en.adsr(h3FMOnset, 0.0, 1.0, h3FMOnset, gate);

h4Group(x) = hgroup("Harmonic 4",x);
h4Harm = h4Group(hslider("Harmonic", 4, 1, 20, 1));
h4Tuning = h4Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h4Drive = h4Group(hslider("Drive", 0.1, 0.0, maxDr, 0.01));
h4Attack = h4Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h4Decay = h4Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h4Feedback = h4Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h4Sustain = h4Group(checkbox("Sustain"));
h4Perc = h4Group(checkbox("Percussive"));
h4env = en.adsr(ba.if(h4Perc == 0, h4Attack, h4Attack / 100), ba.if(h4Perc == 0, h4Decay, h4Decay / 100), ba.if(h4Sustain == 0, 0.0, 1.0), h4Decay, gate);
h4FMAmount = h4Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h4FMFreq = h4Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h4FMOnset = h4Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h4FMenv = en.adsr(h4FMOnset, 0.0, 1.0, h4FMOnset, gate);


h5Group(x) = hgroup("Harmonic 5",x);
h5Harm = h5Group(hslider("Harmonic", 5, 1, 20, 1));
h5Tuning = h5Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h5Drive = h5Group(hslider("Drive", 0.0, 0.0, maxDr, 0.01));
h5Attack = h5Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h5Decay = h5Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h5Feedback = h5Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h5Sustain = h5Group(checkbox("Sustain"));
h5Perc = h5Group(checkbox("Percussive"));
h5env = en.adsr(ba.if(h5Perc == 0, h5Attack, h5Attack / 100), ba.if(h5Perc == 0, h5Decay, h5Decay / 100), ba.if(h5Sustain == 0, 0.0, 1.0), h5Decay, gate);
h5FMAmount = h5Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h5FMFreq = h5Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h5FMOnset = h5Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h5FMenv = en.adsr(h5FMOnset, 0.0, 1.0, h5FMOnset, gate);

h6Group(x) = hgroup("Harmonic 6",x);
h6Harm = h6Group(hslider("Harmonic", 6, 1, 20, 1));
h6Tuning = h6Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h6Drive = h6Group(hslider("Drive", 0.0, 0.0, maxDr, 0.01));
h6Attack = h6Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h6Decay = h6Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h6Feedback = h6Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h6Sustain = h6Group(checkbox("Sustain"));
h6Perc = h6Group(checkbox("Percussive"));
h6env = en.adsr(ba.if(h6Perc == 0, h6Attack, h6Attack / 100), ba.if(h6Perc == 0, h6Decay, h6Decay / 100), ba.if(h6Sustain == 0, 0.0, 1.0), h6Decay, gate);
h6FMAmount = h6Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h6FMFreq = h6Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h6FMOnset = h6Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h6FMenv = en.adsr(h6FMOnset, 0.0, 1.0, h6FMOnset, gate);

h7Group(x) = hgroup("Harmonic 7",x);
h7Harm = h7Group(hslider("Harmonic", 7, 1, 20, 1));
h7Tuning = h7Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h7Drive = h7Group(hslider("Drive", 0.0, 0.0, maxDr, 0.01));
h7Attack = h7Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h7Decay = h7Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h7Feedback = h7Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h7Sustain = h7Group(checkbox("Sustain"));
h7Perc = h7Group(checkbox("Percussive"));
h7env = en.adsr(ba.if(h7Perc == 0, h7Attack, h7Attack / 100), ba.if(h7Perc == 0, h7Decay, h7Decay / 100), ba.if(h7Sustain == 0, 0.0, 1.0), h7Decay, gate);
h7FMAmount = h7Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h7FMFreq = h7Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h7FMOnset = h7Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h7FMenv = en.adsr(h7FMOnset, 0.0, 1.0, h7FMOnset, gate);

h8Group(x) = hgroup("Harmonic 8",x);
h8Harm = h8Group(hslider("Harmonic", 8, 1, 20, 1));
h8Tuning = h8Group(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h8Drive = h8Group(hslider("Drive", 0.0, 0.0, maxDr, 0.01));
h8Attack = h8Group(hslider("Attack", 0.1, minA, maxA, 0.01));
h8Decay = h8Group(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h8Feedback = h8Group(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h8Sustain = h8Group(checkbox("Sustain"));
h8Perc = h8Group(checkbox("Percussive"));
h8env = en.adsr(ba.if(h8Perc == 0, h8Attack, h8Attack / 100), ba.if(h8Perc == 0, h8Decay, h8Decay / 100), ba.if(h8Sustain == 0, 0.0, 1.0), h8Decay, gate);
h8FMAmount = h8Group(hslider("Vibrato Amt", 0.0, 0.0, 1.0, 0.01));
h8FMFreq = h8Group(hslider("Vibrato Rate", 0.0, 0.0, fmMaxRate, 1.0));
h8FMOnset = h8Group(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h8FMenv = en.adsr(h8FMOnset, 0.0, 1.0, h8FMOnset, gate);

driveDamper(t) = ba.if(
  t == 1, 0.1, ba.if(
	abs(t - 1) < 0.1, max(0.1, abs(t - 1) * 10), 1.0 ))
  ;

oVal(f, harm, level, feed, drive, fmFreq, fmAmt) = os.osc(f) * level * drive :  fi.fb_fcomb(44100, harm * ma.SR/(f) + os.osc(fmFreq + os.osc(fmOscRate) * fmOscAmt) * fmAmt * 5, 0.99, -1 * feed);

voice(f, detune) = 
  oVal((f + f*detune) * h1Harm, h1Harm * h1Tuning, baseLevel * h1env, h1Feedback, h1Drive * driveDamper(h1Tuning), h1FMFreq, h1FMenv * h1FMAmount) + 
  oVal((f + f*detune) * h2Harm, h2Harm * h2Tuning, baseLevel * h2env, h2Feedback, h2Drive * driveDamper(h2Tuning), h2FMFreq, h2FMenv * h2FMAmount) +
  oVal((f + f*detune) * h3Harm, h3Harm * h3Tuning, baseLevel * h3env, h3Feedback, h3Drive * driveDamper(h3Tuning), h3FMFreq, h3FMenv * h3FMAmount) +
  oVal((f + f*detune) * h4Harm, h4Harm * h4Tuning, baseLevel * h4env, h4Feedback, h4Drive * driveDamper(h4Tuning), h4FMFreq, h4FMenv * h4FMAmount) +
  oVal((f + f*detune) * h5Harm, h5Harm * h5Tuning, baseLevel * h5env, h5Feedback, h5Drive * driveDamper(h5Tuning), h5FMFreq, h5FMenv * h5FMAmount) +
  oVal((f + f*detune) * h6Harm, h6Harm * h6Tuning, baseLevel * h6env, h6Feedback, h6Drive * driveDamper(h6Tuning), h6FMFreq, h6FMenv * h6FMAmount) +
  oVal((f + f*detune) * h7Harm, h7Harm * h7Tuning, baseLevel * h7env, h7Feedback, h7Drive * driveDamper(h7Tuning), h7FMFreq, h7FMenv * h7FMAmount) +
  oVal((f + f*detune) * h8Harm, h8Harm * h8Tuning, baseLevel * h8env, h8Feedback, h8Drive * driveDamper(h8Tuning), h8FMFreq, h8FMenv * h8FMAmount);


timbre(f) = voice(f, 0) + voice(f, unisonOnsetEnv * 0.02);

process = gate * timbre(freq) * gain/20  <: _,_;
effect = dm.freeverb_demo;