import("stdfaust.lib");
/*
	Written by Rich Cochrane: https://cochranemusic.com

	A simple vehicle for exploring Scheerbart tunings.
	These are 12EDO with one or more notes adjusted up or down to match their nearest 10EDO neighbour.

	Made available under CC BY-NC: https://creativecommons.org/licenses/by-nc/4.0/
	(In sort, you can do what you like with this code as long as you don't use it in a commercial
	product and you give me credit. Additionally, you may use this, or derivatives of it,
	on recorded music that's released for sale if you credit me and link back to cochranemusic.com.)
*/

junkGroup(x) = tgroup("Junk",x);  // This hides controls we don't need.
gain = junkGroup(nentry("gain", 1, 0, 1, 0.01)) * en.adsr(envA, envD, envS, envR, gate);
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

//////////////////////////////////////
// General controls
// (applied to the final sound)
//////////////////////////////////////

generalGroup(x) = hgroup("1. General",x);
generalLevel1(x) = generalGroup(vgroup("A. Level & Filter", x));
baseLevel = generalLevel1(hslider("Volume", 1.0, 0.0, 10.0, 0.01));
filtRez = generalLevel1(hslider("Resonance", 0.1, 0.1, 2.0, 0.001));
filtFreq = generalLevel1(hslider("Cutoff [midi: ctrl 1]", 2000.0, 10.0, 2000.0, 1));
generalLevel2(x) = generalGroup(vgroup("B. Envelope", x));
envA = generalLevel2(hslider("1. A", 0.0, 0.0, 3.0, 0.01));
envD = generalLevel2(hslider("2. D", 0.2, 0.0, 3.0, 0.01));
envS = generalLevel2(hslider("3. S", 0.8, 0.0, 1.0, 0.01));
envR = generalLevel2(hslider("4. R", 0.4, 0.0, 3.0, 0.01));

//////////////////////////////////////
// Tuning controls
//////////////////////////////////////

// Note: When using a MIDI controller, you get retuning in steps of 1 cent.
// When you drag the control on the GUI it snaps to the "correct" values.

tuningGroup(x) = hgroup("2. Tuning",x);
tunings = (
  0,
  tuningGroup(vslider("01. C#[midi:ctrl 14]", 100, 100, 120, 20)),
  tuningGroup(vslider("02. D[midi:ctrl 3]", 200, 120, 240, 40)),
  tuningGroup(vslider("03. D#[midi:ctrl 4]", 300, 240, 360, 60)),
  tuningGroup(vslider("04. E[midi:ctrl 5]", 400, 360, 480, 40)),
  tuningGroup(vslider("05. F[midi:ctrl 6]", 500, 480, 500, 20)),
  600,
  tuningGroup(vslider("07. G[midi:ctrl 7]", 700, 700, 720, 20)),
  tuningGroup(vslider("08. G#[midi:ctrl 8]", 800, 720, 840, 40)),
  tuningGroup(vslider("09. A[midi:ctrl 9]", 900, 840, 960, 60)),
  tuningGroup(vslider("10. A#[midi:ctrl 10]", 1000, 960, 1080, 40)),
  tuningGroup(vslider("11. B[midi:ctrl 11]", 1100, 1080, 1200, 20))
  );

//////////////////////////////////////
// Tuning algorithm
//////////////////////////////////////
zeroNote = 8.1758;				
centRatio = 1.00057778951;		// 2^(1/1200), i.e. one hundredth of a semitone
tunePitch(f) =  zeroNote * pow(2, floor(ba.hz2midikey(f) / 12)) * pow(centRatio, (tunings : ba.selectn(12,  (ba.hz2midikey(f) % 12))));
gFreq = tunePitch(freq) * pitchwheel;

//////////////////////////////////////
// Timbre
//////////////////////////////////////
numPartials = 10;

partialsGroup(x) = hgroup("3. Timbre", x);
partials = par(z,numPartials,
		   partialsGroup(vslider("%z",(numPartials - z)/numPartials, 0, 1, 0.01))
		  );

timbre(f) = par(z,numPartials, 
				os.osc( tunePitch(freq * (z + 1)) * pitchwheel) 
				* (partials:  ba.selectn(numPartials, z))
				):> _ /  numPartials;


process = gate * timbre(freq) * gain * baseLevel : fi.resonlp(filtFreq,filtRez,0.5) <: _, _;
effect = dm.freeverb_demo;


