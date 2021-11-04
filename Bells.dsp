import("stdfaust.lib");

/**
	Plays a bell sound that changes timbre depending on the MIDI note
**/

junkGroup(x) = tgroup("Junk",x);  // This hides controls we don't need.
gain = junkGroup(nentry("gain", 1, 0, 1, 0.01));
freq = junkGroup(hslider("freq", 440, 50, 1000, 0.01));
gate = junkGroup(button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1));
pitchwheel = junkGroup(hslider("bend [midi:pitchwheel]",1,0.9,1.1,0.001));

a = vslider("Param A", 10, 3, 100, 1);
b = floor((ba.hz2midikey(freq) +1)/(100 * (inharm + 1)));

sustain = hslider("Sustain", 1, 1, 10, 0.1);
inharm = hslider("Inharmonicty", 1, 0, 1, 0.01);
lpc = hslider("Lowpass", 10000, 1, 10000, 1);
fmAmount = hslider("FM Amount", 1, 0, 1, 0.01);

numPartials = 10;
baseFreq = freq; //220; //sqrt(freq)*100; //vslider("Base Freq", 5000, 20, 20000, 1);

partials = par(z,numPartials,
		   		(ma.modulo(freq * z, numPartials)/numPartials)	// The level of the partial
		  );

envAs = par(z,numPartials,
		   pow(100 / freq, 2)*(ma.modulo(freq * z, numPartials * (z + 1))/numPartials * (z + 1)) - (fmod(freq + z, 5))/4	// The level of the partial
		  );
envDs = par(z,numPartials,
		   (ma.modulo(freq * z, numPartials)/numPartials)/5 +  log10((1/freq) *10000)	// The level of the partial
		  );

tunePitch(f, z) = baseFreq * (z + pow((z-1) * inharm *  fmod(f, ((z + 1) + b))/(numPartials + b) + 1, 0.5));

fmAmt = par(z,numPartials,
		   		ma.modulo(freq + z*1000, 50) * pow(floor(fmod(freq + z * z * b, 4))/3, 4)
		  );
fmFreq = par(z,numPartials,
		   		(ma.modulo(freq + z*976, numPartials)/numPartials)*(ma.modulo(freq, 10)) + 0.1
		  );

timbre(f) = par(z,numPartials, 
				os.osc(tunePitch(f * (z + 1), z + 1) + fmAmount * (
					os.osc(fmFreq  :  ba.selectn(numPartials, z)) *  (fmAmt :  ba.selectn(numPartials, z))	// FM
				)
				)
				* (partials :  ba.selectn(numPartials, z) * 
				   ( ( 
					 	(envAs : ba.selectn(numPartials, z)) * sustain, 
					 	(envDs : ba.selectn(numPartials, z)) * sustain, 
					 	0, 0, gate
				   	 )
					 : en.adsr
					)
				   )
				):> _ /  numPartials;

gainCorrect = 1/(partials :> +);

process = gate * timbre(baseFreq) * gain * gainCorrect: fi.lowpass6e(min(20000, freq + lpc)) <: _, _;
effect = dm.freeverb_demo;

			