(
s.options.numWireBufs = 1024*2;
s.options.numOutputBusChannels=2;
s.options.numInputBusChannels=0;
s.options.memSize = 8192*32;
s.options.blockSize = 64;
s.options.maxNodes = 1024 * 2;
//s.makeGui(w);
//s.options.sampleRate= 44100;
//s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
//s.recChannels = 8;
s.boot;
)

(
	Tdef(\m, {
	Buffer.freeAll;
/////array rhythm

////tetrahedron
(
~az1=[45.degrad,135.neg.degrad,45.neg.degrad,135.degrad];
~el1=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad];
);
///cube
/*(

~az=[45.degrad,135.degrad,45.neg.degrad,135.neg.degrad,45.degrad,135.degrad,45.neg.degrad,135.neg.degrad];
~el=[35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.neg.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad,35.264390.degrad];

)

/////octahedron

(

~az=[0.degrad,0.degrad,90.degrad,180.degrad,90.neg.degrad,0.degrad];
~el=[90.neg.degrad,0.degrad,0.degrad,0.degrad,0.degrad,90.degrad];

)*/
//////array tone
/*(
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
)*/
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

({
var m1=1.neg, m2=1.neg, m3=1.neg,a,b,c, beat=1, frame=32.reciprocal,n=0,bank=(1*3);

~dur=[];

~x=bank.collect{
m1=m1+1;
	b=Spherical(beat,~az1.[m1],~el1.[m1]).x.round(frame);
	2.pow(b).round(0.00001);
};
~y=bank.collect{
m2=m2+1;
	c=Spherical(beat,~az1.[m2],~el1.[m2]).y.round(frame);
	2.pow(c).round(0.00001);
};
~z=bank.collect{
m3=m3+1;
	d=Spherical(beat,~az1.[m3],~el1.[m3]).z.round(frame);
	2.pow(d).round(0.00001);
};
	bank.do{ ~dur=~dur++~x.[n]++~y.[n]++~z.[n]; n=n+1;};}.value;
);

1.wait;
(
SynthDef(\kick, {
    var env,silver=45,bank=9,linex=0,liney=0,sig;
	var phs,golden=0,ton=8,freq,decay=2,rq=0.1;

	freq = EnvGen.kr(Env([56*ton, 56],  [decay/4], curve: -4)); // pitch drop
	env= EnvGen.kr(Env.perc(0.0001, decay, curve: -4),doneAction:2,levelScale:8);
	//sig = SinOsc.ar(freq,freq/56) * env;

	bank.do{

linex=exp(Complex(0,1)*silver.degrad).real.round(0.00001).abs;
liney=exp(Complex(0,1)*silver.degrad).imag.round(0.00001).abs.neg;
phs=golden.degrad;

		sig=
BPF.ar(BRF.ar(
(LPF.ar(Saw.ar((freq),mul:ton.reciprocal).abs,freq/16)+SinOsc.ar(freq/5,phs,ton.reciprocal)),
	56,rq),56,rq);

sig = sig + (sig * BrownNoise.ar(0.0005)); // add slight noise for punch

		Out.ar(0, Pan2.ar((sig),linex,env));
		Out.ar(0, Pan2.ar((sig),liney,env));

silver=(silver+(360-(360/(1+2.sqrt)))).wrap(180.neg,180).round(0.00001);
golden=(golden+(360-(360/((1+5.sqrt)/2)))).wrap(180.neg,180).round(0.0001);

	};
}).add;
);
3.wait;
(
		~w= Buffer.alloc(s,2048);
		{
var signal,wt,m=0,amp,ph=0;

~level=32.collect{m=m+1;amp=m.reciprocal};
		signal=Signal.sineFill(1024,~level,[0]);

wt = signal.asWavetable;
~w.loadCollection(wt);
//signal.plot;
		}.value;
);

(

~w_function= Buffer.alloc(s,2048);
~function=Env([1.neg,1],[1],[0]).asSignal(1025);
~function=~function+(
	Signal.sineFill(1024,Array.fill(8, {20.rand}),[0])/4;
);
~function=~function.normalize;
//~function.plot;
~w_function.loadCollection(~function.asWavetableNoWrap);
//~w_function=Buffer.loadCollection(s,~function);

);

(
SynthDef(\chord, {
	arg m;
	var freq1,freq2,freq3,n1,n2,n3,fund=28,env,band,decay=4,mix=0.5,room=0.3333,gain=10;
	var b,c,d,interval=12,octave=4,osc1,osc2,osc3,cell_l,cell_r,cell_tria,linex,liney;
	var gold_r=((1+5.sqrt)/2),rq=0.1,silver=45,silver_r=(1+2.sqrt),l=1,bank=9;

	env= EnvGen.kr(Env.perc(0.01, decay),doneAction:2,levelScale:gain);
//env=0.05;
	b=Spherical(interval*octave,Select.kr(m.lag(0.1),~az),Select.kr(m.lag(0.1),~el)).x.round(1);
	c=Spherical(interval*octave,Select.kr(m.lag(0.1),~az),Select.kr(m.lag(0.1),~el)).y.round(1);
	d=Spherical(interval*octave,Select.kr(m.lag(0.1),~az),Select.kr(m.lag(0.1),~el)).z.round(1);
	n1=(2.pow(b/interval)).round(0.0001);
	n2=(2.pow(c/interval)).round(0.0001);
	n3=(2.pow(d/interval)).round(0.0001);

	freq1=(fund*l)*n1;
	freq2=(fund*l)*n2;
	freq3=(fund*l)*n3;

	band=SinOsc.kr(0.1,phase:2pi.rand2).range(28,496);
bank.do{
linex=exp(Complex(0,1)*silver.degrad).real.abs;
liney=exp(Complex(0,1)*silver.degrad).imag.abs.neg;

	osc1=BPF.ar(BRF.ar((Shaper.ar(~w_function.bufnum,
(LPF.ar(Saw.ar(freq1,(n1/50)).abs,fund/32))+SinOsc.ar(freq1-n1,0.degrad,(n1/50)),mul:n1.reciprocal)),
band,rq),band,rq);

	osc2=BPF.ar(BRF.ar((Shaper.ar(~w_function.bufnum,
(LPF.ar(Saw.ar(freq2,(n2/50)).abs,fund/32))+SinOsc.ar(freq2-n2,0.degrad,(n2/50)),mul:n2.reciprocal)),
band,rq),band,rq);

	osc3=BPF.ar(BRF.ar((Shaper.ar(~w_function.bufnum,
(LPF.ar(Saw.ar(freq3,(n3/50)).abs,fund/32))+SinOsc.ar(freq3-n3,0.degrad,(n3/50)),mul:n3.reciprocal)),
band,rq),band,rq);


cell_l=Saw.kr(rq).range(0,1);
cell_r=Saw.kr(rq).range(0,1.neg);
cell_tria=SinOsc.kr(rq,phase:90.degrad);

Out.ar(0,Pan2.ar(Limiter.ar(LeakDC.ar(FreeVerb.ar(osc1,mix,room,mul:1),mul:1)*env,1),(linex+cell_l.lag(0.1)).wrap(0,1)));
Out.ar(0,Pan2.ar(Limiter.ar(LeakDC.ar(FreeVerb.ar(osc2,mix,room,mul:1),mul:1)*env,1),(liney+cell_r.lag(0.1)).wrap(0,1.neg)));
Out.ar(0,Pan2.ar(Limiter.ar(LeakDC.ar(FreeVerb.ar(osc3,mix,room,mul:1),mul:1)*env,1),
cell_tria.lag(0.1)));

	silver=(silver+(360-silver_r)).wrap(180.neg,180).round(0.0001);
	l=l+1;
}

	};
).add;
);
10.wait;
	({
		var n=1.neg;
	~list=(90*360).collect{
		n=n+1;
		}
		}.value;
~list=~list.scramble
	);
(
(
		~chord=Pdef(\1, Pbind(\instrument, \chord,
			//\dur,Pseq(~dur1,inf);
		\dur,Pseq(~dur/2,inf),
	\m,Pseq(~list,inf);
		))
);



	(
		~kick=Pdef(\2, Pbind(\instrument, \kick,
			\dur,Pseq(~dur,inf);
		))
)
);



TempoClock.default.tempo_(220/120);
//TempoClock.default.tempo_(120/120);

~kick.play;
~chord.play;

});
	Tdef(\m).play;
)

~chord.pause;
~kick.pause;
