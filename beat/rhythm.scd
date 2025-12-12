//array experiments

///tetrahedron
(
~az=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
)

////silver star
(
{
	var az=0,el1=0,sph,n=90,iter=90,rep=360,el,silver=(1+2.sqrt),w=((1+5.sqrt)/2);
	~az=[];~el=[];

rep.do{
el=iter.collect{
		el1 = 90/n;
			n=n-1;
sph=Spherical(1,az.degrad,el1.degrad).phi.round(0.000000000001);
	};
~az=~az++az.degrad;~el=~el++el;
//az = (az+1).wrap(0,360);
		az=(az+(360-(360/silver))).wrap(0,360);
el1=0;n=90;
	};
}.value;
);

/////sphere
		(
{
var  sph1,sph2,sph3,az1=0,el1=0,az2=0,el2=0,gold_r=((1+5.sqrt)/2),silver_r=(1+2.sqrt);
var azimuth,elevation,angle=0,n=12,ellipsis=[1,1,1];
var mag1=1,mag2=1,mag3=1,mag4=1,mag5=1,mag6=1,mag7=1;
	~az=[];~el=[];

	360.do{
azimuth=90.collect{
			az1 = (az1+((180*2.pow(n/12))-((180*2.pow(n/12))/silver_r))).wrap((90*2.pow(n/12)).neg,(90*2.pow(n/12)));
		   el1 = (el1+((90*2.pow(n/12))-((90*2.pow(n/12))/silver_r))).wrap((45*2.pow(n/12)).neg,(45*2.pow(n/12)));
sph1=(Spherical(mag1,(az1.degrad+angle.degrad).wrap(pi.neg,pi),(el1.degrad+angle.degrad).wrap((pi/2).neg,(pi/2)))).theta.round(0.000000000001);
	};

elevation=90.collect{
				az2 = (az2+((180*2.pow(n/12))-((180*2.pow(n/12))/silver_r))).wrap((90*2.pow(n/12)).neg,(90*2.pow(n/12)));
			el2 = (el2+((90*2.pow(n/12))-((90*2.pow(n/12))/silver_r))).wrap((45*2.pow(n/12)).neg,(45*2.pow(n/12)));
sph2=(Spherical(mag2,(az2.degrad+angle.degrad).wrap(pi.neg,pi),(el2.degrad+angle.degrad).wrap((pi/2).neg,(pi/2)))).phi.round(0.000000000001);
	};


angle=(angle+((180*2.pow(n/12))-((180*2.pow(n/12))/1.6180339887499))).wrap(0,(180*2.pow(n/12)));
~az=~az++azimuth;~el=~el++elevation;
		az1=0;el1=0;az2=0;el2=0;
	}
}.value;
);

///tetrahedron
(
~az=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
)
//////test array
(
~az=[90.degrad,0.degrad];
~el=[0.degrad,0.degrad];
)

////tester
(var m,a,b,c, beat=5, frame=32; {

m=MouseX.kr(0,1).round(1).asInteger;
	//m=MouseX.kr(0,32400).round(1).asInteger;
	//m=MouseX.kr(0,3).round(1).asInteger;
	b=Spherical(beat,Select.kr(m,~az),Select.kr(m,~el)).x.round(frame);
	c=Spherical(beat,Select.kr(m,~az),Select.kr(m,~el)).y.round(frame);
	d=Spherical(beat,Select.kr(m,~az),Select.kr(m,~el)).z.round(frame);
	//(2.pow(b/beat)).poll;
	//(2.pow(c/beat)).poll;
	//(2.pow(d/beat)).poll;
	2.pow(b).poll;
	2.pow(c).poll;
	2.pow(d).poll;
		}.play
		)
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

		Out.ar(2, Pan2.ar(sig,linex));
		Out.ar(2, Pan2.ar(sig,liney));

silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);
golden=(golden+(360-(360/((1+5.sqrt)/2)))).wrap(180.neg,180).round(0.0001);

	};
}).add;
)

	(
		~kick=Pdef(\1, Pbind(\instrument, \kick,
			\dur,Pseq(~dur1,inf),
		))







TempoClock.default.tempo_(1/1);


~kick.play;
~kick.pause;
