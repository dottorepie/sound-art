(
s.options.numWireBufs = 1024*2;
s.options.numOutputBusChannels=6;
s.options.numInputBusChannels=0;
s.options.memSize = 8192*4;
s.options.blockSize = 64;
s.options.maxNodes = 1024 * 2;
//s.makeGui(w);
//s.options.sampleRate= 44100;
//s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
//s.recChannels = 8;
//s.boot;
);


(
~n=1.neg;~array=992.collect{~n=~n+1;2.pow(~n/992)};
~a=(0-(pi/496)); ~ph=992.collect{~a=~a+(pi/496);};
~bufferSize = 4096*8;
~signalSize = 2048*8;
);
(
//////kick
(
SynthDef(\kick, {
    var env,silver=45,bank=9,linex=0,liney=0,sig;
	var phs,golden=90,ton=2,freq,decay=2;

	freq = EnvGen.kr(Env([56*ton, 28],  [0.5], curve: -4)); // pitch drop
	env= EnvGen.kr(Env.perc(0.01, decay, curve: -4),doneAction:2,levelScale:1/4);
	//sig = SinOsc.ar(freq,freq/56) * env;

	bank.do{

linex=exp(Complex(0,1)*silver.degrad).real.round(0.00001).abs;
liney=exp(Complex(0,1)*silver.degrad).imag.round(0.00001).abs.neg;
phs=golden.degrad;

		sig=(LPF.ar(Pulse.ar((freq),width:0.5,mul:freq/56).abs,56*4)*SinOsc.ar(freq/2,phs,freq/56))*env;

sig = sig + (sig * BrownNoise.ar(0.0001)); // add slight noise for punch

		Out.ar(0, Pan2.ar(sig,linex));
		Out.ar(0, Pan2.ar(sig,liney));

silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);
golden=(golden+(360-(360/((1+5.sqrt)/2)))).wrap(180.neg,180).round(0.0001);

	};
}).add;
);
//Synth(\kick);
/////snare
(
SynthDef(\snare, {
    var env,silver=45,golden=90,bank=9,linex=0,liney=0,sig,phs;
	var toneEnv,tone,noise,ton=3,decay=2;

	toneEnv = EnvGen.kr(Env.perc(0.0001, decay));
	env= EnvGen.kr(Env.perc(0.0001, decay),doneAction:2,levelScale:1/16);
	noise= BrownNoise.ar(0.01)*env;

	bank.do{


linex=exp(Complex(0,1)*silver.degrad).real.round(0.00001).abs;
liney=exp(Complex(0,1)*silver.degrad).imag.round(0.00001).abs.neg;
phs=golden.degrad;

		tone=LPF.ar(Pulse.ar((56*ton),width:0.5,mul:toneEnv).abs,56*16)*SinOsc.ar((56*ton)/2,phs,toneEnv);
		sig = (tone * 0.1) + (noise * 0.5);
	    sig = HPF.ar(sig, 56); // filter out low rumble

		Out.ar(0, Pan2.ar(sig,linex));
		Out.ar(0, Pan2.ar(sig,liney));

silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);
golden=(golden+(360-(360/((1+5.sqrt)/2)))).wrap(180.neg,180).round(0.0001);

	};
}).add;
);

//Synth(\snare);
////hihat
(
SynthDef(\hihat, {
    var env,silver=45,bank=21,linex=0,liney=0,sig,noise,decay=0.2;


	env= EnvGen.kr(Env.perc(0.001, decay),doneAction:2,levelScale:1/200);
	noise = WhiteNoise.ar(env);
	sig = BPF.ar(noise, 56*128, 1);
	sig = HPF.ar(sig, 56* 128);

	bank.do{

linex=exp(Complex(0,1)*silver.degrad).real.round(0.00001).abs;
liney=exp(Complex(0,1)*silver.degrad).imag.round(0.00001).abs.neg;

		sig = sig + (sig * bank.reciprocal * BrownNoise.ar(0.01)); // add slight noise for punch

		Out.ar(0, Pan2.ar(sig,linex,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig,liney,bank.reciprocal));

silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);

	};
}).add;
)
)

// Test it:
Synth(\hihat);
Synth(\snare);
Synth(\kick);

//////////patterns
(
	(
		~kick=Pdef(\1, Pbind(\instrument, \kick,
			\dur,Pseq(~dur1,inf),
		))
);

(
		~snare=Pdef(\2, Pbind(\instrument, \snare,
			\dur,Pseq(~dur1.reverse,inf),
		))
);
(
		~hihat=Pdef(\3, Pbind(\instrument, \hihat,
			\dur,Pseq(~dur1.reverse/4,inf),
		))
)
)



TempoClock.default.tempo_(120/152);

(
~kick.play;
~snare.play;
~hihat.play;
~kick.pause;
~snare.pause;
~hihat.pause;
)




(var m1=1.neg, m2=1.neg, m3=1.neg,a,b,c, beat=1, frame=32.reciprocal,n=0,bank=(1*5);

~dur=[];

~x=bank.collect{
m1=m1+1;
	b=Spherical(beat,~az.[m1],~el.[m1]).x.round(frame);
	2.pow(b).round(0.00001);
};
~y=bank.collect{
m2=m2+1;
	c=Spherical(beat,~az.[m2],~el.[m2]).y.round(frame);
	2.pow(c).round(0.00001);
};
~z=bank.collect{
m3=m3+1;
	d=Spherical(beat,~az.[m3],~el.[m3]).z.round(frame);
	2.pow(d).round(0.00001);
};
bank.do{ ~dur=~dur++~x.[n]++~y.[n]++~z.[n]; n=n+1;};





///tetrahedron
(
~az=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
)
//////cube
(

~az=[45.degrad,135.degrad,45.neg.degrad,135.neg.degrad,45.degrad,135.degrad,45.neg.degrad,135.neg.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad];

)

/////octahedron

(

~az=[0.degrad,0.degrad,90.degrad,180.degrad,90.neg.degrad,0.degrad];
~el=[90.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,90.degrad];

)
/////////////sun
//////icosahedron
(
~az=[90.degrad,90.neg.degrad,0.degrad,180.degrad,58.28.degrad,121.72.degrad,121.72.neg.degrad,58.neg.degrad,90.degrad,90.neg.degrad,0.degrad,180.degrad];
~el=[58.28.neg.degrad,58.28.neg.degrad,31.72.neg.degrad,31.72.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,58.28.degrad,58.28.degrad,31.72.degrad,31.72.degrad];
)

/////dodecahedron

(
~az=[45.degrad,135.neg.degrad,135.degrad,45.neg.degrad,90.degrad,90.neg.degrad,0.degrad,180.degrad,45.degrad,135.neg.degrad,135.degrad,45.neg.degrad,90.degrad,
	90.neg.degrad,69.09.degrad,110.91.degrad,110.91.neg.degrad,69.09.neg.degrad,0.degrad,180.degrad];

~el=[35.26.neg.degrad,35.26.neg.degrad,35.26.neg.degrad,35.26.neg.degrad,69.09.neg.degrad,69.09.neg.degrad,20.91.neg.degrad,20.91.neg.degrad,
	35.26.degrad,35.26.degrad,35.26.degrad,35.26.degrad,69.09.degrad,69.09.degrad,0.degrad,0.degrad,0.degrad,0.degrad,20.91.degrad,20.91.degrad]
)

////planet
/////Rhombic dodecahedron//// hull

(
~az=[0.degrad,45.degrad,135.neg.degrad,135.degrad,45.neg.degrad,0.degrad,180.degrad,90.degrad,90.neg.degrad,0.degrad,
	45.degrad,135.neg.degrad,135.degrad,45.neg.degrad];
~el=[90.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,0.degrad
	,0.degrad,0.degrad,0.degrad,90.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad];
)

/////cuboctahedron//// core

(
~az=[0.degrad,90.degrad,180.degrad,90.neg.degrad,45.degrad,135.degrad,45.neg.degrad,135.neg.degrad,
	0.degrad,90.degrad,180.degrad,90.neg.degrad];
~el=[45.neg.degrad,45.neg.degrad,45.neg.degrad,45.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,
	45.degrad,45.degrad,45.degrad,45.degrad];
)


///////////////Rhombic Triacontahedron//// hull
(
~az=[0.degrad,0.degrad,72.degrad,144.degrad,144.neg.degrad,72.neg.degrad,36.degrad,108.degrad,180.degrad,108.neg.degrad,36.neg.degrad,
	0.degrad,72.degrad,144.degrad,144.neg.degrad,72.neg.degrad,36.degrad,108.degrad,180.degrad,108.neg.degrad,36.neg.degrad,
	0.degrad,72.degrad,144.degrad,144.neg.degrad,72.neg.degrad,36.degrad,108.degrad,180.degrad,108.neg.degrad,36.neg.degrad,0.degrad];

~el=[90.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,52.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,26.6.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,10.8.neg.degrad,52.6.degrad,52.6.degrad,52.6.degrad,52.6.degrad,52.6.degrad,26.6.degrad,26.6.degrad,26.6.degrad,26.6.degrad,26.6.degrad,10.8.degrad,10.8.degrad,10.8.degrad,10.8.degrad,10.8.degrad,90.degrad];

)

///////icosidodecahedron//// core
(
~az=[18.degrad,90.degrad,162.degrad,126.neg.degrad,54.neg.degrad,54.degrad,126.degrad,162.neg.degrad,90.neg.degrad,18.neg.degrad,
	0.degrad,36.degrad,72.degrad,108.degrad,144.degrad,180.degrad,144.neg.degrad,108.neg.degrad,72.neg.degrad,36.neg.degrad,
	54.degrad,126.degrad,162.neg.degrad,90.neg.degrad,18.neg.degrad,18.degrad,90.degrad,162.degrad,126.neg.degrad,54.neg.degrad];

~el=[58.283.degrad,58.283.degrad,58.283.degrad,58.283.degrad,58.283.degrad,58.283.neg.degrad,58.283.neg.degrad,58.283.neg.degrad,58.283.neg.degrad,58.283.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,0.degrad,
37.717.degrad,37.717.degrad,37.717.degrad,37.717.degrad,37.717.degrad,37.717.neg.degrad,37.717.neg.degrad,37.717.neg.degrad,37.717.neg.degrad,37.717.neg.degrad];

)