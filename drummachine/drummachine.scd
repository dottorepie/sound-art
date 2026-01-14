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
//tanh saturation mul less as speaker size increase///



(
(
s.options.numWireBufs = 1024*2;
s.options.numOutputBusChannels=2;
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
	//Buffer.freeAll;
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
	arg amp=20,n=12,pan=1,low=0,noise=0.001,decay=1,attack=0.01;
    var env,freq,anglex,angley,anglez,mod_anglex,mod_angley,mod_anglez,fund=28,mx,my,mz,magx,magz,magy;
	var sph,phase,threshold,ton=2.pow(n/12),az=pi,el=pi/2,m=2;
	var sig1,sig2,sig3,phasex,phasey,phasez,control1,control2,control3;

	freq = EnvGen.kr(Env([fund*ton, fund], [decay/8], curve: -4)); // pitch drop
	env= EnvGen.kr(Env.perc(attack, decay, curve: -4),doneAction:2,levelScale:amp);

			threshold=(((343/0.14)/freq).reciprocal.ampdb/2.sqrt).dbamp;

					az=SinOsc.ar(pan/2,0).range(pi,pi.neg);
			el=SinOsc.ar(pan/2,pi/2,pan.reciprocal).range((pi/2),(pi/2).neg);

		sph=Spherical(1,(az.lag(0.01)),(el.lag(0.01)));

anglex=exp(Complex(0,1)*sph.theta).real*exp(Complex(0,1)*sph.phi).real;
angley=exp(Complex(0,1)*sph.theta).imag*exp(Complex(0,1)*sph.phi).real;
anglez=exp(Complex(0,1)*sph.phi).imag;

phasex=Complex(0,anglex).theta;
phasey=Complex(0,angley).theta;
phasez=Complex(0,anglez).theta;

mod_anglex=SinOsc.ar(pan,Complex(anglex,angley).theta,pan.reciprocal).range(pi.neg,pi);
mod_angley=SinOsc.ar(pan,Complex(angley,anglex).theta,pan.reciprocal).range(pi.neg,pi);
mod_anglez=SinOsc.ar(pan,Complex(0,anglez).theta,pan.reciprocal).range((pi/2).neg,(pi/2));

magx=((Complex(cos(((sph.theta+mod_anglex).round(0.00001)*m).wrap(pi.neg,pi)),cos((((sph.theta+mod_anglex).round(0.00001)*m)).wrap(pi.neg,pi))).rho/(2.sqrt))*
	(Complex(cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2))),cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

magy=((Complex(sin(((sph.theta+mod_angley).round(0.00001)*m).wrap(pi.neg,pi)),sin(((sph.theta+mod_angley).round(0.00001)*m).wrap(pi.neg,pi))).rho/(2.sqrt))*
		(Complex(cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2))),cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

magz=((Complex(cos(((sph.phi+mod_anglez).round(0.00001)*m).wrap((pi/2).neg,(pi/2))),cos(((sph.phi).round(0.00001)*m).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

mx=(Cartesian(magx.value,0,0).rho);my=(Cartesian(0,magy.value,0).rho);mz=(Cartesian(0,0,magz.value).rho);



sig1=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasex,mul:100).abs*SinOsc.ar(freq,phase:phasex)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));
sig2=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasey,mul:100).abs*SinOsc.ar(freq,phase:phasey)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));
sig3=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasez,mul:100).abs*SinOsc.ar(freq,phase:phasez)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));

control1=SinOsc.ar(freq,phasex,ton.reciprocal);
control2=SinOsc.ar(freq,phasey,ton.reciprocal);
control3=SinOsc.ar(freq,phasez,ton.reciprocal);

sig1 = sig1 + (sig1 * BrownNoise.ar(noise)); sig2 = sig2 + (sig2 * BrownNoise.ar(noise)); sig3 = sig3 + (sig3 * BrownNoise.ar(noise));


		sig1=HPF.ar(sig1,50); sig2=HPF.ar(sig1, 50);sig3=HPF.ar(sig1, 50);
		sig1=Compander.ar(sig1,control1,threshold,1.2,1/3,0.03,0.15);
		sig2=Compander.ar(sig2,control2,threshold,1.2,1/3,0.03,0.15);
		sig3=Compander.ar(sig3,control3,threshold,1.2,1/3,0.03,0.15);
		sig1=tanh(sig1*1.5);sig2=tanh(sig2*1.5);sig3=tanh(sig2*1.5);


		Out.ar(0, Pan2.ar(sig1,anglex.round(0.0001)*mx,env));
		Out.ar(0, Pan2.ar(sig2,angley.round(0.0001)*my,env));
		Out.ar(0, Pan2.ar(sig3,anglez.round(0.0001)*mz,env));

}).add;);

Synth(\kick);

/////snare
(
SynthDef(\snare, {
	arg amp=1,n=48,pan=0.5,low=0,noise=0.1,decay=1,snare=8;
    var env,freq,anglex,angley,anglez,mod_anglex,mod_angley,mod_anglez,fund=28,mx,my,mz,magx,magz,magy;
	var sph,phase,threshold,ton=2.pow(n/12),az=pi,el=pi/2,m=2;
	var sig1,sig2,sig3,phasex,phasey,phasez,control1,control2,control3;

	freq = EnvGen.kr(Env([freq, fund], [decay/2], curve: -4));
	env= EnvGen.kr(Env.perc(0.01, decay),doneAction:2,levelScale:amp);

			threshold=(((343/0.14)/freq).reciprocal.ampdb/2.sqrt).dbamp;

					az=SinOsc.ar(pan,0).range(pi,pi.neg);
			el=SinOsc.ar(pan,pi/2,pan.reciprocal).range((pi/2),(pi/2).neg);

sph=Spherical(1,(az.lag(0.01)),(el.lag(0.01)));

anglex=exp(Complex(0,1)*sph.theta).real*exp(Complex(0,1)*sph.phi).real;
angley=exp(Complex(0,1)*sph.theta).imag*exp(Complex(0,1)*sph.phi).real;
anglez=exp(Complex(0,1)*sph.phi).imag;

phasex=Complex(0,anglex).theta;
phasey=Complex(0,angley).theta;
phasez=Complex(0,anglez).theta;

mod_anglex=SinOsc.ar(pan,Complex(anglex,angley).theta,pan.reciprocal).range(pi.neg,pi);
mod_angley=SinOsc.ar(pan,Complex(angley,anglex).theta,pan.reciprocal).range(pi.neg,pi);
mod_anglez=SinOsc.ar(pan,Complex(0,anglez).theta,pan.reciprocal).range((pi/2).neg,(pi/2));

magx=((Complex(cos(((sph.theta+mod_anglex).round(0.00001)*m).wrap(pi.neg,pi)),cos((((sph.theta+mod_anglex).round(0.00001)*m)).wrap(pi.neg,pi))).rho/(2.sqrt))*
	(Complex(cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2))),cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

magy=((Complex(sin(((sph.theta+mod_angley).round(0.00001)*m).wrap(pi.neg,pi)),sin(((sph.theta+mod_angley).round(0.00001)*m).wrap(pi.neg,pi))).rho/(2.sqrt))*
		(Complex(cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2))),cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

magz=((Complex(cos(((sph.phi+mod_anglez).round(0.00001)*m).wrap((pi/2).neg,(pi/2))),cos(((sph.phi).round(0.00001)*m).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

mx=(Cartesian(magx.value,0,0).rho);my=(Cartesian(0,magy.value,0).rho);mz=(Cartesian(0,0,magz.value).rho);



sig1=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasex,mul:100).abs*SinOsc.ar(freq,phase:phasex)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));
sig2=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasey,mul:100).abs*SinOsc.ar(freq,phase:phasey)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));
sig3=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasez,mul:100).abs*SinOsc.ar(freq,phase:phasez)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));

control1=SinOsc.ar(freq,phasex,ton.reciprocal);
control2=SinOsc.ar(freq,phasey,ton.reciprocal);
control3=SinOsc.ar(freq,phasez,ton.reciprocal);

	sig1 = (sig1+ (HPF.ar(BrownNoise.ar(noise),snare*fund)* Env.perc(0.01, 0.1).ar));
	sig2 = (sig2+ (HPF.ar(BrownNoise.ar(noise),snare*fund)* Env.perc(0.01, 0.1).ar));
	sig3 = (sig3+ (HPF.ar(BrownNoise.ar(noise),snare*fund)* Env.perc(0.01, 0.1).ar));

		sig1=HPF.ar(sig1,50); sig2=HPF.ar(sig1, 50);sig3=HPF.ar(sig1, 50);
		sig1=Compander.ar(sig1,control1,threshold,1.2,1/3,0.03,0.15);
		sig2=Compander.ar(sig2,control2,threshold,1.2,1/3,0.03,0.15);
		sig3=Compander.ar(sig3,control3,threshold,1.2,1/3,0.03,0.15);
		sig1=tanh(sig1*1.5);sig2=tanh(sig2*1.5);sig3=tanh(sig2*1.5);

	Out.ar(0, Pan2.ar(sig1,anglex.round(0.0001)*mx,env));
		Out.ar(0, Pan2.ar(sig2,angley.round(0.0001)*my,env));
		Out.ar(0, Pan2.ar(sig3,anglez.round(0.0001)*mz,env));
}).add;
);

//Synth(\snare);
////hihat
(
SynthDef(\hihat, {
	arg amp=1,decay=0.1,ton=128,pan=1;
    var env,silver=pi/4,bank=4,s1,s2,s3,fund=56,freq,threshold;
	var sph,anglex,angley,anglez,az,el,noise,sig,control;

freq=fund*ton;
threshold=(((343/0.14)/freq).reciprocal.ampdb/2.sqrt).dbamp;
	env= EnvGen.kr(Env.perc(0.001, decay,-8),doneAction:2,levelScale:amp);
	noise = BrownNoise.ar(env);
	sig = BPF.ar(noise, freq, 1);
	sig = HPF.ar(sig, freq);

	control=sig;

			az=SinOsc.ar(pan,0).range(pi,pi.neg);
			el=SinOsc.ar(pan,pi/2,pan.reciprocal).range((pi/2),(pi/2).neg);

sph=Spherical(1,(az.lag(0.01)),(el.lag(0.01)));

anglex=exp(Complex(0,1)*sph.theta).real*exp(Complex(0,1)*sph.phi).real;
angley=exp(Complex(0,1)*sph.theta).imag*exp(Complex(0,1)*sph.phi).real;
anglez=exp(Complex(0,1)*sph.phi).imag;



		sig=HPF.ar(sig,50);
		sig=Compander.ar(sig,control,threshold,1.2,1/3,0.03,0.15);
		sig=tanh(sig*1);

		bank.do{
				s1=silver-anglex; s2=silver-angley; s3=silver-anglez;

		Out.ar(0, Pan2.ar(sig,s1,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig,s2,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig,s3,bank.reciprocal));

silver=(silver+(2pi-(2pi/(1+2.sqrt)))).wrap(pi.neg,pi).round(0.00001);

	};
}).add;
);
	//Synth(\hihat);
(
SynthDef(\ride, {
	arg amp=0.2,decay=4,attack=0.01,ton=8,pan=1,az=pi/2,el=pi/4;
    var env,silver=45,bank=8,sig,wash,ping,noise;
	var sph,anglex,angley,anglez,control,freq;
	var s1,s2,s3,fund=56,threshold,bell1,bell2,bell3;
	var sig1,sig2,sig3,phasex,phasey,phasez,control1,control2,control3;


	env= EnvGen.kr(Env.perc(0.01, decay),doneAction:2,levelScale:1);
	noise = PinkNoise.ar(env);
freq=fund*ton;
	sig = BPF.ar(noise, freq, 1);
	sig = HPF.ar(sig, freq);

threshold=(((343/0.14)/freq).reciprocal.ampdb/2.sqrt).dbamp;

az=SinOsc.ar(pan,0).range(pi,pi.neg);
el=SinOsc.ar(pan,pi/2,pan.reciprocal).range((pi/2),(pi/2).neg);

sph=Spherical(1,(az.lag(0.01)),(el.lag(0.01)));

anglex=exp(Complex(0,1)*sph.theta).real*exp(Complex(0,1)*sph.phi).real;
angley=exp(Complex(0,1)*sph.theta).imag*exp(Complex(0,1)*sph.phi).real;
anglez=exp(Complex(0,1)*sph.phi).imag;

phasex=Complex(0,anglex).theta;
phasey=Complex(0,angley).theta;
phasez=Complex(0,anglez).theta;

// ping (stick attack)
    ping = SinOsc.ar(freq , 0, amp/2) * env;

    // metallic wash
    wash = Mix.fill(bank, {
        SinOsc.ar(exprand(100, 10000), 0, bank.reciprocal)
    });
    wash = HPF.ar(wash, 3000);
			wash = wash * EnvGen.ar(Env.perc(attack, decay/2));

    bell1 = SinOsc.ar(freq, phasex, amp/2) * EnvGen.ar(Env.perc(attack, decay/2));
	 bell2 = SinOsc.ar(freq, phasey, amp/2) * EnvGen.ar(Env.perc(attack, decay/2));
	 bell3 = SinOsc.ar(freq, phasez, amp/2) * EnvGen.ar(Env.perc(attack, decay/2));

    sig1 = (ping + wash + bell1)*amp;  sig2 = (ping + wash + bell2)*amp;   sig3 = (ping + wash + bell3)*amp;

control1=(ping + wash + bell1+noise)*amp;
control2=(ping + wash + bell2+noise)*amp;
control3=(ping + wash + bell3+noise)*amp;

	sig1=HPF.ar(sig1,50);sig2=HPF.ar(sig2,50);sig3=HPF.ar(sig3,50);
	sig1=Compander.ar(sig1,control1,threshold,1.2,1/3,0.03,0.15);
	sig2=Compander.ar(sig2,control2,threshold,1.2,1/3,0.03,0.15);
	sig3=Compander.ar(sig3,control3,threshold,1.2,1/3,0.03,0.15);
			sig1=tanh(sig1*1);sig2=tanh(sig2*1);sig3=tanh(sig3*1);

bank.do{

s1=silver-anglex; s2=silver-angley; s3=silver-anglez;

		Out.ar(0, Pan2.ar(sig1,s1,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig2,s2,bank.reciprocal));
		Out.ar(0, Pan2.ar(sig3,s3,bank.reciprocal));

silver=(silver+(2pi-(2pi/(1+2.sqrt)))).wrap(pi.neg,pi).round(0.00001);

			}
}).add;
);
	Synth(\ride);

	(
SynthDef(\crash, {
  	arg amp=0.2,decay=4,attack=0.01,ton=8,pan=1,az=pi/2,el=pi/4;
    var env,silver=45,bank=8,sig,wash,ping,noise;
	var sph,anglex,angley,anglez,control,freq;
	var s1,s2,s3,fund=56,threshold,bell1,bell2,bell3;
	var sig1,sig2,sig3,phasex,phasey,phasez,control1,control2,control3;


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
	Synth(\crash);
(
SynthDef(\tom, {
	arg amp=20,n=12,pan=1,low=0,noise=0.001,decay=1,m=1,passlow=2000;
    var env,sig,freq,anglex,angley,anglez,mod_anglex,mod_angley,mod_anglez,fund=28,mx,my,mz,magx,magz,magy;
	var sph,control,phase,threshold,ton=2.pow(n/12),az=pi,el=pi/2;
	var sig1,sig2,sig3,phasex,phasey,phasez,control1,control2,control3;

	freq = EnvGen.kr(Env([freq, fund], [decay/8], curve: -4)); // pitch drop
	env= EnvGen.kr(Env.perc(0.01, decay, curve: -4),doneAction:2,levelScale:amp);


		threshold=(((343/0.14)/freq).reciprocal.ampdb/2.sqrt).dbamp;

					az=SinOsc.ar(pan,0).range(pi,pi.neg);
			el=SinOsc.ar(pan,pi/2,pan.reciprocal).range((pi/2),(pi/2).neg);

sph=Spherical(1,(az.lag(0.01)),(el.lag(0.01)));

anglex=exp(Complex(0,1)*sph.theta).real*exp(Complex(0,1)*sph.phi).real;
angley=exp(Complex(0,1)*sph.theta).imag*exp(Complex(0,1)*sph.phi).real;
anglez=exp(Complex(0,1)*sph.phi).imag;

phasex=Complex(0,anglex).theta;
phasey=Complex(0,angley).theta;
phasez=Complex(0,anglez).theta;

mod_anglex=SinOsc.ar(pan,Complex(anglex,angley).theta,pan.reciprocal).range(pi.neg,pi);
mod_angley=SinOsc.ar(pan,Complex(angley,anglex).theta,pan.reciprocal).range(pi.neg,pi);
mod_anglez=SinOsc.ar(pan,Complex(0,anglez).theta,pan.reciprocal).range((pi/2).neg,(pi/2));

magx=((Complex(cos(((sph.theta+mod_anglex).round(0.00001)*m).wrap(pi.neg,pi)),cos((((sph.theta+mod_anglex).round(0.00001)*m)).wrap(pi.neg,pi))).rho/(2.sqrt))*
	(Complex(cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2))),cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

magy=((Complex(sin(((sph.theta+mod_angley).round(0.00001)*m).wrap(pi.neg,pi)),sin(((sph.theta+mod_angley).round(0.00001)*m).wrap(pi.neg,pi))).rho/(2.sqrt))*
		(Complex(cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2))),cos((sph.phi.round(0.00001)).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

magz=((Complex(cos(((sph.phi+mod_anglez).round(0.00001)*m).wrap((pi/2).neg,(pi/2))),cos(((sph.phi).round(0.00001)*m).wrap((pi/2).neg,(pi/2)))).rho/(2.sqrt)));

mx=(Cartesian(magx.value,0,0).rho);my=(Cartesian(0,magy.value,0).rho);mz=(Cartesian(0,0,magz.value).rho);

	sig1=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasex,mul:100).abs*SinOsc.ar(freq,phase:phasex)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));
sig2=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasey,mul:100).abs*SinOsc.ar(freq,phase:phasey)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));
sig3=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:phasez,mul:100).abs*SinOsc.ar(freq,phase:phasez)),freq*2.pow(low.lag(0.01)/992),ton.reciprocal));

control1=SinOsc.ar(freq,phasex,ton.reciprocal);
control2=SinOsc.ar(freq,phasey,ton.reciprocal);
control3=SinOsc.ar(freq,phasez,ton.reciprocal);


sig1 = sig1 + (sig1 * (BPF.ar(BrownNoise.ar(noise),freq*2)* Env.perc(0.001, 0.05).ar));
sig2 = sig2 + (sig2 * (BPF.ar(BrownNoise.ar(noise),freq*2)* Env.perc(0.001, 0.05).ar));
sig3 = sig3 + (sig3 * (BPF.ar(BrownNoise.ar(noise),freq*2)* Env.perc(0.001, 0.05).ar));

	///Delay1.ar(in: 0.0, mul: 1.0, add: 0.0, x1: 0.0)

	sig1=HPF.ar(sig1,50); sig2=HPF.ar(sig1, 50);sig3=HPF.ar(sig1, 50);
		sig1=Compander.ar(sig1,control1,threshold,1.2,1/3,0.03,0.15);
		sig2=Compander.ar(sig2,control2,threshold,1.2,1/3,0.03,0.15);
		sig3=Compander.ar(sig3,control3,threshold,1.2,1/3,0.03,0.15);
		sig1=tanh(sig1*1.5);sig2=tanh(sig2*1.5);sig3=tanh(sig2*1.5);

	    Out.ar(0, Pan2.ar(sig1,anglex.round(0.0001)*mx,env));
		Out.ar(0, Pan2.ar(sig2,angley.round(0.0001)*my,env));
		Out.ar(0, Pan2.ar(sig3,anglez.round(0.0001)*mz,env));

}).add;);
		Synth(\tom);

)
(
	/////solid
(
~az=[0.degrad,0.degrad,90.degrad,180.degrad,90.neg.degrad,0.degrad];
~el=[90.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,90.degrad];
);

///quaterion rhtyhm solid rotation
/*(var i=Quaternion(0, axis_xyz.[0], 0, 0),j=Quaternion(0, 0, axis_xyz.[1], 0),k=Quaternion(0, 0, 0, axis_xyz.[2]);

axis=i+j+k;
~x1=tetrahedron.collect{
	plx1=plx1+1;
	qx1=Quaternion(0,Spherical(1,~az1[plx1],~el1[plx1]).x.round(0.00001),Spherical(1,~az1[plx1],~el1[plx1]).y.round(0.00001),Spherical(1,~az1[plx1],~el1[plx1]).z.round(0.00001));
	rotor_a=((axis*exp(Complex(0,1)*angle_a.degrad).imag)+exp(Complex(0,1)*angle_a.degrad).real); ax=rotor_a*qx1*rotor_a.conjugate;
	ax.b.round(0.00001);
};
)*/
//////////patterns


	({var m1=1.neg, m2=1.neg, m3=1.neg,a,b,c,n=0,bank=6,time=16.reciprocal,beat=1;

~dur1=[];~dur2=[];~dur3=[];

~x=bank.collect{
m1=m1+1;
	b=Spherical(beat,~az.[m1],~el.[m1]).rotate(0.degrad).x.round(0.00001);
	2.pow(b).round(time);
};
~y=bank.collect{
m2=m2+1;
	c=Spherical(beat,~az.[m2],~el.[m2]).rotate(0.degrad).y.round(0.00001);
	2.pow(c).round(time);
};
~z=bank.collect{
m3=m3+1;
	d=Spherical(beat,~az.[m3],~el.[m3]).rotate(0.degrad).z.round(0.00001);
	2.pow(d).round(time);
};
		bank.do{ ~dur1=~dur1++~x.[n];n=n+1;};n=0;
		bank.do{ ~dur2=~dur2++~y.[n];n=n+1;};n=0;
		bank.do{ ~dur3=~dur3++~z.[n];n=n+1;};n=0;
	//	bank.do{~durs=~durs++~x.[n]++~y.[n]++~z.[n];n=n+1;}
//	~dur = ~duri.collect { |x|
  //  if (x == 0) { Rest(2) } { x }
//	}
}.value;
);
	({var m1=1.neg, m2=1.neg, m3=1.neg,a,b,c,n=0,bank=6,time=16.reciprocal,beat=1;

~dur4=[];~dur5=[];~dur6=[];

~x1=bank.collect{
m1=m1+1;
	b=Spherical(beat,~az.[m1],~el.[m1]).rotate(45.degrad).x.round(0.00001);
	2.pow(b).round(time);
};
~y1=bank.collect{
m2=m2+1;
	c=Spherical(beat,~az.[m2],~el.[m2]).rotate(45.degrad).y.round(0.00001);
	2.pow(c).round(time);
};
~z1=bank.collect{
m3=m3+1;
	d=Spherical(beat,~az.[m3],~el.[m3]).rotate(45.degrad).z.round(0.00001);
	2.pow(d).round(time);
};
		bank.do{ ~dur4=~dur4++~x1.[n];n=n+1;};n=0;
		bank.do{ ~dur5=~dur5++~y1.[n];n=n+1;};n=0;
		bank.do{ ~dur6=~dur6++~z1.[n];n=n+1;};n=0;
	//	bank.do{~durs=~durs++~x.[n]++~y.[n]++~z.[n];n=n+1;}
//	~dur = ~duri.collect { |x|
  //  if (x == 0) { Rest(2) } { x }
//	}
}.value;
)
	);
(
	(
		~kick=Pdef(\1, Pbind(\instrument, \kick,
			\dur,Pseq(~dur1,inf),
		))
);

(
		~snare=Pdef(\2, Pbind(\instrument, \snare,
			\dur,Pseq(~dur2,inf),
		))
);
(
		~hihat=Pdef(\3, Pbind(\instrument, \hihat,
			\dur,Pseq(~dur3,inf),
		))
);
		/(
		~ride=Pdef(\4, Pbind(\instrument, \ride,
			\dur,Pseq(~du4,inf),
		))
);
(
		~crash=Pdef(\5, Pbind(\instrument, \crash,
			\dur,Pseq(~du5,inf),
		))
);
		(
		~tom=Pdef(\6, Pbind(\instrument, \tom,
			\dur,Pseq(~du6,inf),
		))
);


);




TempoClock.default.tempo_(4);

(
~kick.play;
~snare.play;
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


(
var n=1.neg;
r = Routine {
	loop{ 6.do{n=n+1; Synth(\kick); ~dur1.[n].wait;};n=1.neg;
		2.wait;
};

}
);

r.play

	///tetrahedron
(
~az=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
);
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