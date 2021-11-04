import("stdfaust.lib");

//gain = hslider("gain", 0.5, 0, 1, 0.01);
freq = hslider("freq", 440, 50, 1000, 0.01);
gate = button("gate") : en.adsr(0.01, 0.01, 0.9, 0.1);

gain = 0.1; //an.amp_follower_ar(0.001, 2.0) , 2 : pow, 2 : * ;

//freq = 440.0;


h1Level = hslider("Fundamental", 0.5, 0, 1, 0.01);
h2Level = hslider("Octave", 0.8, 0, 1, 0.01);
inharmonicity = nentry("Inharmonicity", 1.2, 0.5, 2, 0.01);

combRes = hslider("Comb Resonance", 0.004, 0.0001, 0.017, 0.00001);
combPower = hslider("Comb Power",0.01, 0.0001, 0.011, 0.00001);
feedbackAmount = -0.999;

oVal(f, level) = os.osc(f) * level : fi.fb_fcomb(256,combRes*(20000 - f)*pow((20000 - f), combPower),0.3,feedbackAmount );

timbre(f) = oVal(f,h1Level) + 
  oVal(f * 2 * inharmonicity, h2Level);

process = gate * timbre(freq) * gain <: _,_;
effect = dm.freeverb_demo;