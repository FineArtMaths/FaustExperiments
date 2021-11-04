import("stdfaust.lib");
/*
	This is a playable synth whose oscillators are used as exciters for comb filters. 
	TO DO:
		* Add a noise oscillator or two
		* Maybe global noise oscillator on the amplitude just to create a bit of analogue variation
		* Include a detuning envelope per harmonic
		* Try to capture pitch wheel, mod wheel and key release (to add a key release noise)
		* Save and load a preset
		* Microtuning
*/

junkGroup(x) = tgroup("Junk",x);  // I don't think tab groups are working properly, or I didn't do this right; either way this just hides the junk, which works for me.
gain = junkGroup(nentry("gain", 1, 0, 1, 0.01)) * en.adsr(0.0, 0.1, 0.7, 1.0, gate);
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01))* pitchwheel;
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

generalGroup(x) = hgroup("1. General",x);
baseLevel = generalGroup(hslider("Volume", 0.3, 0.0, 1.0, 0.001));

// Default values for setting up sliders to make them easier to change
minA = 0.0;
maxA = 2.0;
maxDr = 100.0;
baseFeedback = 0.999;
minfeed = 0.0;
maxfeed = 1.0;
fmMaxRate = 5000;

h1Group(x) = vgroup("2. First Harmonic",x);
h1OscGroup(x) = h1Group(hgroup("Oscillator",x));
h1FMGroup(x) = h1Group(hgroup("FM",x));

h1Group(x) = vgroup("Harmonic 1",x);
h1OscGroup(x) = h1Group(hgroup("Oscillator",x));
h1FMGroup(x) = h1Group(hgroup("FM",x));

h1Harm = h1OscGroup(hslider("Harmonic", 1, 1, 20, 1));
h1Tuning = h1OscGroup(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h1Drive = h1OscGroup(hslider("Drive", 6.0, 0.0, maxDr, 0.01));
h1Attack = h1OscGroup(hslider("Attack", 0.1, minA, maxA, 0.01));
h1Decay = h1OscGroup(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h1Feedback = h1OscGroup(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h1Sustain = h1OscGroup(checkbox("Sustain"));
h1env = en.adsr(ba.if(h1Perc == 0, h1Attack, h1Attack / 100), ba.if(h1Perc == 0, h1Decay, h1Decay / 100), ba.if(h1Sustain == 0, 0.0, 1.0), h1Decay, gate);
h1Perc = h1OscGroup(checkbox("Percussive"));

h1FMAmount = h1FMGroup(hslider("FM Amt", 1.0, 0.0, 1.0, 0.01)) * 5;
h1FMFreqOct = h1FMGroup(hslider("FM Octave", 1, 0, 10, 1));
h1FMFreqFine = h1FMGroup(hslider("FM Fine", 0.0, 0.0, 1.0, 0.001));
h1FMFreq = h1FMFreqOct + h1FMFreqFine;
h1FMFeed = h1FMGroup(hslider("FM feed", 0.0, 0.0, 0.999, 0.001));
h1FMOnset = h1FMGroup(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h1FMenv = en.adsr(h1FMOnset, 0.0, 1.0, h1FMOnset, gate);
h1FMOscRate = h1FMGroup(hslider("FM Osc Rate", 0.1, 0.01, 50.0, 0.01));
h1FMOscAmt = h1FMGroup(hslider("FM Osc Amt", 0.0, 0.0, 200, 1));
h1FMFBOscRate = h1FMGroup(hslider("FM FB Osc Rate", 0.1, 0.01, 50.0, 0.01));
h1FMFBOscAmt = h1FMGroup(hslider("FM FB Osc Amt", 0.0, 0.0, 200, 1));




h2Group(x) = vgroup("3. Second Harmonic",x);
h2OscGroup(x) = h2Group(hgroup("Oscillator",x));
h2FMGroup(x) = h2Group(hgroup("FM",x));

h2Harm = h2OscGroup(hslider("Harmonic", 1, 1, 20, 1));
h2Tuning = h2OscGroup(hslider("Tuning", 1, 0.75, 1.5, 0.001));
h2Drive = h2OscGroup(hslider("Drive", 0.1, 0.0, maxDr, 0.01));
h2Attack = h2OscGroup(hslider("Attack", 0.1, minA, maxA, 0.01));
h2Decay = h2OscGroup(hslider("Decay", 0.1, 0.01, 2.0, 0.01));
h2Feedback = h2OscGroup(hslider("Feedback", baseFeedback, minfeed, maxfeed, 0.01));
h2Sustain = h2OscGroup(checkbox("Sustain"));
h2env = en.adsr(ba.if(h2Perc == 0, h2Attack, h2Attack / 100), ba.if(h2Perc == 0, h2Decay, h2Decay / 100), ba.if(h2Sustain == 0, 0.0, 1.0), h2Decay, gate);
h2Perc = h2OscGroup(checkbox("Percussive"));

h2FMAmount = h2FMGroup(hslider("FM Amt", 0.0, 0.0, 1.0, 0.01)) * 5;
h2FMFreqOct = h2FMGroup(hslider("FM Octave", 0, -5, 5, 1));
h2FMFreqFine = h2FMGroup(hslider("FM Fine", 0.0, 0.0, 1.0, 0.001));
h2FMFreq = h2FMFreqOct + h2FMFreqFine;
h2FMFeed = h2FMGroup(hslider("FM feed", 0.0, 0.0, 0.999, 0.001));
h2FMOnset = h2FMGroup(hslider("Vibrato Onset", 0.0, 0.0, maxA, 0.01));
h2FMenv = en.adsr(h2FMOnset, 0.0, 1.0, h2FMOnset, gate);
h2FMOscRate = h2FMGroup(hslider("FM Osc Rate", 0.1, 0.01, 200.0, 0.01));
h2FMOscAmt = h2FMGroup(hslider("FM Osc Amt", 0.0, 0.0, 200, 1));
h2FMFBOscRate = h2FMGroup(hslider("FM FB Osc Rate", 0.1, 0.01, 200.0, 0.01));
h2FMFBOscAmt = h2FMGroup(hslider("FM FB Osc Amt", 0.0, 0.0, 200, 1));


/****************************
RESONATOR
*****************************/
bodyGroup(x) = hgroup("4. Body",x);
rezu4 = bodyGroup(vslider("U04", 0, 0, 0.5, 0.01));
rezu3 = bodyGroup(vslider("U03", 0, 0, 0.5, 0.01));
rezu2 = bodyGroup(vslider("U02", 0, 0, 0.5, 0.01));
rezu1 = bodyGroup(vslider("U01", 0, 0, 0.5, 0.01));
rez0 = bodyGroup(vslider("H00", 0, 0, 0.5, 0.01));
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
rezBloom = bodyGroup(vslider("Bloom", 0, 0, 2, 0.01));
rezA = bodyGroup(vslider("Amount", 30, 15, 100, 1));
rezAmt = rezA  * en.adsr(rezBloom, 0.0, 1.0, 1.0, gate);

gFreq = freq;

resonator = _ , 
	fi.resonlp(2 * gFreq / 5,rezAmt,rezu3 * 2.5),
	fi.resonlp(gFreq / 4,rezAmt,rezu2 * 2),
	fi.resonlp(2 * gFreq / 3,rezAmt,rezu1 * 1.5),
	fi.resonlp(gFreq / 2,rezAmt,rez0),
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
	fi.resonlp(gFreq * 12,rezAmt,rez11)
  :> _ / (rez1 + rez2 + rez3 + rez4 + rez5 + rez6 + rez7 + rez8 + rez9 + rez10 + rez11 + 1 + rez0 + rezu1 * 1.5 + rezu2 * 2 + rezu3 * 2.5);





driveDamper(t) = ba.if(
  t == 1, 0.1, ba.if(
	abs(t - 1) < 0.1, max(0.1, abs(t - 1) * 10), 1.0 ))
  ;

fmFreqCalc (f, fmFreq, fmoscA, fmoscR) = max(0, f* fmFreq + os.osc(fmoscR) * fmoscA);

fmVal(f, harm, fmFreq, fmAmt, fmFeed, fmoscA, fmoscR, fmfboscA, fmfboscR) =  
  ((((_ + fmFreqCalc(f, fmFreq, fmoscA, fmoscR)) ) : os.square) * fmAmt) 
  ~
  (* (fmFeed * f  + os.osc(fmfboscR) * fmfboscA));
//  (* (fmFeed * (f - 1)  + os.osc(fmfboscR) * fmfboscA));
  
  //os.osc(f * fmFreq + os.osc(fmOscRate) * fmOscAmt) * fmAmt * 5;

oVal(f, harm, level, feed, drive, fmFreq, fmAmt, fmFeed, fmoscA, fmoscR, fmfboscA, fmfboscR) = 
  													os.osc(f + fmVal(f, harm, fmFreq, fmAmt, fmFeed, fmoscA, fmoscR, fmfboscA, fmfboscR)) * level * drive :  
													fi.fb_fcomb(
													  44100, 
													  harm * ma.SR/(f) + fmVal(f, harm, fmFreq, fmAmt, fmFeed, fmoscA, fmoscR, fmfboscA, fmfboscR), 
													  0.99, -1 * feed
													);

voice(f, detune) = 
  oVal((f + f*detune) * h1Harm, h1Harm * h1Tuning, baseLevel * h1env, h1Feedback, h1Drive * driveDamper(h1Tuning), h1FMFreq, h1FMenv * h1FMAmount, h1FMFeed, h1FMOscAmt, h1FMOscRate, h1FMFBOscAmt, h1FMFBOscRate) + 
  oVal((f + f*detune) * h2Harm, h2Harm * h2Tuning, baseLevel * h2env, h2Feedback, h2Drive * driveDamper(h2Tuning), h2FMFreq, h2FMenv * h2FMAmount, h2FMFeed, h2FMOscAmt, h2FMOscRate, h2FMFBOscAmt, h2FMFBOscRate);


timbre(f) = voice(f, 0);

process = gate * timbre(freq) * gain/20  <: resonator <: _, _;
effect = dm.freeverb_demo;