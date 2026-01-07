///compression notes
//	slopeAbove:
//4" → 0.35–0.45
//5" → 0.45–0.60
//8" → 0.60–0.80
		///the larger the speaker cone the more relax time is possible and less difference between slopes, also less threshhold//Relax time ≈ 5–10× the attack time
//clampTime (attack)
//Fast attack → kills transients → fewer high-frequency spikes
//Slow attack → transients pass → brighter sound
//relaxTime (release)
//Fast release → pumping, rhythmic spectral motion
//Slow release → smoother, denser spectrum
//Relax too short (< 80 ms)
//Bass “breathes”
//Mids wobble
//Small speakers sound cheap
//Relax too long (> 300 ms)
//Bass dominates gain control
//Mix sounds flat, distant
//Quiet detail doesn’t recover fast enough
//tanh saturation mul less as speaker size increase

(
(
s.options.numWireBufs = 1024*2;
s.options.numOutputBusChannels=4;
s.options.numInputBusChannels=0;
s.options.memSize = 8192*4;
s.options.blockSize = 64;
s.options.maxNodes = 1024 * 2;
//s.makeGui(w);
s.options.sampleRate= 44100;
//s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
//s.recChannels = 8;
//s.boot;
);
(
s.waitForBoot{
(
(
~n=1.neg;~array=992.collect{~n=~n+1;2.pow(~n/992)};
~a=(0-(pi/496)); ~ph=992.collect{~a=~a+(pi/496);};
~bufferSize = 4096*8;
~signalSize = 2048*8;
);
(
~w1= Buffer.alloc(s,~bufferSize);
		{
	var signal,wt;
	signal=Signal.sineFill(~signalSize,~array,~ph);

wt = signal.asWavetable;
~w1.loadCollection(wt);
//signal.plot;
		}.value;
);
);


//////kick
 (
SynthDef(\kick, {
	var amp=3,fund=28,ton=4,pan=2,low=992,noise=0.001,decay=2,equlibrium;
    var env,linex,liney,sig1,sig2,freq,angle,angle1,angle2,pos1,pos2;
	var az,el,sph1,sph2,equlibrium,pan1,pan2,phase1,phase2,p_amp1=1,p_amp2=1;

	freq = EnvGen.kr(Env([fund*ton, fund], [decay/8], curve: -4)); // pitch drop
	env= EnvGen.kr(Env.perc(0.01, decay, curve: -4),doneAction:2,levelScale:amp);

equlibrium=pi;
phase1=0.degrad; phase2=(equlibrium-90.degrad).wrap2(pi);
pan1=SinOsc.ar(pan,phase:phase1,mul:p_amp1);
pan2=SinOsc.ar(pan/2,phase:phase2,mul:p_amp2);

	az=SinOsc.ar(1,0.degrad,pi);
	el=SinOsc.ar(1,90.degrad,pi/2);


sph1=Spherical(1,(az),(el));
sph2=Spherical(1,(az),(el+equlibrium).wrap2((pi/2)));

angle1=Complex(exp(Complex(0,1)*sph1.theta).real,exp(Complex(0,1)*sph1.phi).imag).theta;
angle2=Complex(exp(Complex(0,1)*sph2.theta).real,exp(Complex(0,1)*sph2.phi).imag).theta;

angle=Complex(exp(Complex(0,1)*angle1).real,exp(Complex(0,1)*angle2).imag).theta;

pos1=exp(Complex(0,1)*angle).real;
pos2=exp(Complex(0,1)*angle).imag;

//linex=exp(Complex(0,1)*pan.degrad).real.round(0.00001).abs;
//liney=exp(Complex(0,1)*pan.degrad).real.round(0.00001).abs.neg;
//phase=pan.degrad;

		sig1=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phase1,mul:100).abs*SinOsc.ar(freq,phase:phase1)),freq*2.pow(low.lag(0.01)/992)));
        sig2=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phase2,mul:100).abs*SinOsc.ar(freq,phase:phase2)),freq*2.pow(low.lag(0.01)/992)));

sig1 = sig1 + (sig1 * BrownNoise.ar(noise));
sig2 = sig2 + (sig2 * BrownNoise.ar(noise));

		sig2=HPF.ar(sig2,50); sig2=LPF.ar(sig2, 2000); sig1=HPF.ar(sig1,50); sig1=LPF.ar(sig1, 2000);
		sig2=Compander.ar(sig2,sig2,-24.dbamp,1,0.3,0.015,0.3); sig1=Compander.ar(sig1,sig1,-24.dbamp,1,0.3,0.015,0.3);
		sig1=tanh(sig1*2);sig2=tanh(sig2*2);sig1=Limiter.ar(sig1,1,0.01);sig2=Limiter.ar(sig2,1,0.01);


		Out.ar(2, Pan2.ar(sig1,pos1,env)*pan1);
		Out.ar(2, Pan2.ar(sig2,pos2,env)*pan2);

}).add;);

//Synth(\kick);

/////snare
(
SynthDef(\snare, {
 	var amp=3,fund=110,pan=2,low=0,noise=0.1,decay=2,snare=2000;
    var env,linex,liney,sig1,sig2,freq,angle,angle1,angle2,pos1,pos2;
	var az,el,sph1,sph2,equlibrium,pan1,pan2,phase1,phase2,p_amp1=1,p_amp2=1;

	toneEnv = EnvGen.kr(Env([fund*1/4, fund], [decay/8], curve: -4));
	env= EnvGen.kr(Env.perc(0.0001, decay),doneAction:2,levelScale:1/16);

equlibrium=pi;
phase1=0.degrad; phase2=(equlibrium-90.degrad).wrap2(pi);
pan1=SinOsc.ar(pan,phase:phase1,mul:p_amp1);
pan2=SinOsc.ar(pan/2,phase:phase2,mul:p_amp2);

	az=SinOsc.ar(1,0.degrad,pi);
	el=SinOsc.ar(1,90.degrad,pi/2);


sph1=Spherical(1,(az),(el));
sph2=Spherical(1,(az),(el+equlibrium).wrap2((pi/2)));

angle1=Complex(exp(Complex(0,1)*sph1.theta).real,exp(Complex(0,1)*sph1.phi).imag).theta;
angle2=Complex(exp(Complex(0,1)*sph2.theta).real,exp(Complex(0,1)*sph2.phi).imag).theta;

angle=Complex(exp(Complex(0,1)*angle1).real,exp(Complex(0,1)*angle2).imag).theta;

pos1=exp(Complex(0,1)*angle).real;
pos2=exp(Complex(0,1)*angle).imag;


		sig=LPF.ar(Pulse.ar((56*ton),width:0.5,mul:toneEnv).abs,56*16)*SinOsc.ar((56*ton)/2,phs,toneEnv);
	sig1=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phase1,mul:100).abs*SinOsc.ar(freq,phase:phase1)),freq*2.pow(low.lag(0.01)/992)));
        sig2=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phase2,mul:100).abs*SinOsc.ar(freq,phase:phase2)),freq*2.pow(low.lag(0.01)/992)));

		sig1 = (sig1 + HPF.ar(BrownNoise.ar(noise),snare)* Env.perc(0.001, 0.05).ar);
		sig2 = (sig2 + HPF.ar(BrownNoise.ar(noise),snare)* Env.perc(0.001, 0.05).ar);

	    sig2=HPF.ar(sig2,50); sig2=LPF.ar(sig2, 2000); sig1=HPF.ar(sig1,50); sig1=LPF.ar(sig1, 2000);
		sig2=Compander.ar(sig2,sig2,-24.dbamp,1,0.3,0.015,0.3); sig1=Compander.ar(sig1,sig1,-24.dbamp,1,0.3,0.015,0.3);
		sig1=tanh(sig1*2);sig2=tanh(sig2*2);sig1=Limiter.ar(sig1,1,0.01);sig2=Limiter.ar(sig2,1,0.01);

	Out.ar(2, Pan2.ar(sig1,pos1,env)*pan1);
	Out.ar(2, Pan2.ar(sig2,pos2,env)*pan2);
}).add;
);

Synth(\snare);
/*(
////hihat
(
SynthDef(\hihat, {
    var env,silver=45,bank=21,linex=0,liney=0,sig,noise,decay=0.2;


	env= EnvGen.kr(Env.perc(0.001, decay,-8),doneAction:2,levelScale:1/200);
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
);
///	Synth(\hihat);
	(
SynthDef(\ride, {
    var env,silver=45,bank=21,linex=0,liney=0,sig,noise,decay=0.2;


	env= EnvGen.kr(Env.perc(0.001, decay),doneAction:2,levelScale:1/200);
	noise = WhiteNoise.ar(env);
	sig = BPF.ar(noise, 56*128, 1);
	sig = HPF.ar(sig, 56* 128);

// ping (stick attack)
    ping = SinOsc.ar(bellFreq * 2, 0, 0.2) * env;

    // metallic wash
    wash = Mix.fill(6, {
        SinOsc.ar(exprand(2000, 9000), 0, 0.12)
    });
    wash = HPF.ar(wash, 3000);
    wash = wash * washEnv;

    // bell
    bell = SinOsc.ar(bellFreq, 0, 0.15) * Env.perc(0.001, decay * 0.6).ar;

    sig = (ping + wash + bell) * amp;

		Out.ar(0, Pan2.ar(sig,linex,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig,liney,bank.reciprocal));



silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);

	};
}).add;
);
	///	Synth(\ride);

	(
SynthDef(\crash, {
    var env,silver=45,bank=21,linex=0,liney=0,sig,noise,decay=0.2;


	env= EnvGen.kr(Env.perc(0.001, decay),doneAction:2,levelScale:1/200);
	noise = WhiteNoise.ar(env);
	sig = BPF.ar(noise, 56*128, 1);
	sig = HPF.ar(sig, 56* 128);

// metallic inharmonic cluster
    metal = Mix.fill(6, { |i|
        SinOsc.ar(exprand(3000, 12000), 0, 0.15)
    });

    // noisy wash
    noise = WhiteNoise.ar(0.4);
    noise = HPF.ar(noise, 4000);

    sig = (metal + noise) * env;
    sig = sig * amp;

    sig = (ping + wash + bell) * amp;

		Out.ar(0, Pan2.ar(sig,linex,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig,liney,bank.reciprocal));



silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);

	};
}).add;
);
	///	Synth(\crash);
(
SynthDef(\tom, {
	var amp=3,fund=28,ton=4,pan=2,low=992,noise=0.001,decay=2;
    var env,linex,liney,sig1,sig2,freq,angle,angle1,angle2,pos1,pos2;
	var az,el,sph1,sph2,equlibrium,pan1,pan2,phase1,phase2,p_amp1=1,p_amp2=1;

	freq = EnvGen.kr(Env([fund*ton, fund], [decay/8], curve: -4)); // pitch drop
	env= EnvGen.kr(Env.perc(0.01, decay, curve: -4),doneAction:2,levelScale:amp);

equlibrium=pi;
phase1=0.degrad; phase2=(equlibrium-90.degrad).wrap2(pi);
pan1=SinOsc.ar(pan,phase:phase1,mul:p_amp1);
pan2=SinOsc.ar(pan/2,phase:phase2,mul:p_amp2);

	az=SinOsc.ar(1,0.degrad,pi);
	el=SinOsc.ar(1,90.degrad,pi/2);


sph1=Spherical(1,(az),(el));
sph2=Spherical(1,(az),(el+equlibrium).wrap2((pi/2)));

angle1=Complex(exp(Complex(0,1)*sph1.theta).real,exp(Complex(0,1)*sph1.phi).imag).theta;
angle2=Complex(exp(Complex(0,1)*sph2.theta).real,exp(Complex(0,1)*sph2.phi).imag).theta;

angle=Complex(exp(Complex(0,1)*angle1).real,exp(Complex(0,1)*angle2).imag).theta;

pos1=exp(Complex(0,1)*angle).real;
pos2=exp(Complex(0,1)*angle).imag;

//linex=exp(Complex(0,1)*pan.degrad).real.round(0.00001).abs;
//liney=exp(Complex(0,1)*pan.degrad).real.round(0.00001).abs.neg;
//phase=pan.degrad;

		sig1=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phase1,mul:100).abs*SinOsc.ar(freq,phase:phase1)),freq*2.pow(low.lag(0.01)/992)));
        sig2=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phase2,mul:100).abs*SinOsc.ar(freq,phase:phase2)),freq*2.pow(low.lag(0.01)/992)));

sig1 = sig1 + (sig1 * BPF.ar(BrownNoise.ar(noise),freq*2)* Env.perc(0.001, 0.05).ar);
sig2 = sig2 + (sig2 * BPF.ar(BrownNoise.ar(noise),freq*2)* Env.perc(0.001, 0.05).ar);

	Delay1.ar(in: 0.0, mul: 1.0, add: 0.0, x1: 0.0)

		sig2=HPF.ar(sig2,50); sig2=LPF.ar(sig2, 2000); sig1=HPF.ar(sig1,50); sig1=LPF.ar(sig1, 2000);
		sig2=Compander.ar(sig2,sig2,-24.dbamp,1,0.3,0.015,0.3); sig1=Compander.ar(sig1,sig1,-24.dbamp,1,0.3,0.015,0.3);
		sig1=tanh(sig1*2);sig2=tanh(sig2*2);sig1=Limiter.ar(sig1,1,0.01);sig2=Limiter.ar(sig2,1,0.01);


		Out.ar(2, Pan2.ar(sig1,pos1,env)*pan1);
		Out.ar(2, Pan2.ar(sig2,pos2,env)*pan2);

}).add;);
	///	Synth(\tom);

// Test it:
Synth(\hihat);
Synth(\snare);
Synth(\kick);
)*/
	///tetrahedron
(
~az=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
);
//////////patterns
({var m1=1.neg, m2=1.neg, m3=1.neg,a,b,c, beat=1, frame=32.reciprocal,n=0,bank=6;

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
		bank.do{ ~dur=~dur++~x.[n]++~y.[n]++~z.[n]; n=n+1;};}.value
);

(
	(
		~kick=Pdef(\1, Pbind(\instrument, \kick,
			\dur,Pseq(~dur,inf),
		))
);

/*(
		~snare=Pdef(\2, Pbind(\instrument, \snare,
			\dur,Pseq(~dur,inf),
		))
);*/
/*(
		~hihat=Pdef(\3, Pbind(\instrument, \hihat,
			\dur,Pseq(~dur,inf),
		))
);*/
		/*(
		~ride=Pdef(\4, Pbind(\instrument, \ride,
			\dur,Pseq(~dur,inf),
		))
);*/
/*(
		~crash=Pdef(\5, Pbind(\instrument, \crash,
			\dur,Pseq(~dur,inf),
		))
);*/
		/*(
		~tom=Pdef(\6, Pbind(\instrument, \tom,
			\dur,Pseq(~dur,inf),
		))
);t*/
/*(
);




TempoClock.default.tempo_(4);

(
~kick.play;
//~snare.play;
//~hihat.play;
//~ride.play;
//~crash.play;
//~tom.play;
//~kick.pause;
//~snare.pause;
//~hihat.pause;
//~ride.pause;
//~crash.pause;
//~tom.pause;
)
}))



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