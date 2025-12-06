
(
(
s.options.numWireBufs = 1024*2;
s.options.numOutputBusChannels=8;
s.options.numInputBusChannels=0;
s.options.memSize = 8192*4;
s.options.blockSize = 64;
s.options.maxNodes = 1024 * 2;
s.makeGui(w);
//s.options.sampleRate= 44100;
//s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
//s.recChannels = 8;
//s.boot;
);

//
(
s.waitForBoot{
MIDIClient.init;
MIDIIn.connectAll;
MIDIClient.destinations;
s.meter;
s.freqscope;
s.scope;
	Tdef(\drone, {
	Buffer.freeAll;

		///cube
		(
~a = VBAPSpeakerArray.new(3,
				[[0, 90.neg],[0, 0],[90, 0],[180,0],[90.neg,0],[0,90]]);
	 ~b = Buffer.loadCollection(s, ~a.getSetsAndMatrices);
);
/////////////osc polytope
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
		/*(
{
var  sph1,sph2,sph3,az1=0,el1=0,az2=0,el2=0;
var azimuth,elevation,angle=0,n=12,ellipsis=[1,1,1];
var mag1=1,mag2=1,mag3=1,mag4=1,mag5=1,mag6=1,mag7=1;
	~az=[];~el=[];

	360.do{
azimuth=90.collect{
			az1 = (az1+((180*2.pow(n/12))-((180*2.pow(n/12))/1.6180339887499))).wrap((90*2.pow(n/12)).neg,(90*2.pow(n/12)));
		   el1 = (el1+((90*2.pow(n/12))-((90*2.pow(n/12))/1.6180339887499))).wrap((45*2.pow(n/12)).neg,(45*2.pow(n/12)));
sph1=(Spherical(mag1,(az1.degrad+angle.degrad).wrap(pi.neg,pi),(el1.degrad+angle.degrad).wrap((pi/2).neg,(pi/2)))).theta.round(0.000000000001);
	};

elevation=90.collect{
				az2 = (az2+((180*2.pow(n/12))-((180*2.pow(n/12))/1.6180339887499))).wrap((90*2.pow(n/12)).neg,(90*2.pow(n/12)));
			el2 = (el2+((90*2.pow(n/12))-((90*2.pow(n/12))/1.6180339887499))).wrap((45*2.pow(n/12)).neg,(45*2.pow(n/12)));
sph2=(Spherical(mag2,(az2.degrad+angle.degrad).wrap(pi.neg,pi),(el2.degrad+angle.degrad).wrap((pi/2).neg,(pi/2)))).phi.round(0.000000000001);
	};


angle=(angle+((180*2.pow(n/12))-((180*2.pow(n/12))/1.6180339887499))).wrap(0,(180*2.pow(n/12)));
~az=~az++azimuth;~el=~el++elevation;
		az1=0;el1=0;az2=0;el2=0;
	}
}.value;
);*/
		/////check value range
		/*(var m,a,b,c; {m=MouseX.kr(0,32400).round(1).asInteger;
			a=Spherical(24,Select.kr(m,~az),Select.kr(m,~el)).z.abs;
			b=Spherical(24,Select.kr(m,~az),Select.kr(m,~el)).x.abs;
			c=Spherical(24,Select.kr(m,~az),Select.kr(m,~el)).y.abs;
			2.pow(a/12).poll;
			2.pow(b/12).poll;
			2.pow(c/12).poll;
		}.play
		)*/

//////saw wavetable
		~w= Buffer.alloc(s,2048);
		{
var signal,wt,m=0,amp,ph=0;

~level=32.collect{m=m+1;amp=m.reciprocal};
		signal=Signal.sineFill(1024,~level,[0]);

wt = signal.asWavetable;
~w.loadCollection(wt);
//signal.plot;
		}.value;


(
SynthDef.new(\synth,{

	arg gain=1,low=7168,high=0,tone=0,band=1,lamdoma=1,brain=1,pan_speed=1;
	var gold=45,silver1=0,silver2=180,gold_r=((1+5.sqrt)/2),silver_r=(1+2.sqrt),room=0.8,mix=0.6;
	var freq,fund,n=0,m,phase,interval,alpha,cell_az,cell_el,num=5;
	var sig1,sig2,first=28,bank=6,out1,out2,fm,band_osc1,band_osc2,amp,ton;
	var linex,liney,silver3=45,cell_l,cell_r,band_osc3,band_osc4;
	var octahedron,sig3,out3,cell_tria,b_x,b_y,b_z,mout;
	var xyz=[1,1,1].normalizeSum.sqrt,axis,q,rotor,rotation;
    var i=Quaternion(0, xyz.[0], 0, 0),j=Quaternion(0, 0, xyz.[1], 0),k=Quaternion(0, 0, 0, xyz.[2]);

axis=i+j+k;

octahedron=Spherical(lamdoma.lag(0.1),Select.kr(brain.lag(0.1),~az),Select.kr(brain.lag(0.1),~el));


b_x=2.pow(octahedron.x.abs/12);
b_y=2.pow(octahedron.y.abs/12);
b_z=2.pow(octahedron.z.abs/12);


bank.do{

ton=2.pow((tone.lag(0.1))/992).round(0.0001);

fund=(first.lag(0.1))*ton;

n=n+1;

interval=pi/2;
m=n*interval;
freq=fund*m;

amp=m.reciprocal*ton.reciprocal;
phase=gold.degrad;

					fm=LFNoise1.ar(amp,m);
freq=freq+fm;

band_osc1=SinOsc.kr(freq.reciprocal*2.pow(band.lag(0.1)/992),phase:90.degrad).range(56*2,16256);
band_osc2=SinOsc.kr(freq.reciprocal*2.pow(band.lag(0.1)/992),phase:90.degrad).range(56*2,16256);
band_osc3=SinOsc.kr(freq.reciprocal*2.pow(band.lag(0.1)/992),phase:90.degrad.neg).range(56*2,16256);
band_osc4=SinOsc.kr(freq.reciprocal*2.pow(band.lag(0.1)/992),phase:90.degrad.neg).range(56*2,16256);

linex=exp(Complex(0,1)*silver3.degrad).real.abs;
liney=exp(Complex(0,1)*silver3.degrad).imag.abs.neg;

mout=MIDIOut.new(0);
mout.latency = 0.1;
mout.noteOn(0,freq.cpsmidi,30);

/*sig1=BPF.ar(BRF.ar(
(LPF.ar(Saw.ar((freq),mul:amp).abs,low/16)*SinOsc.ar(freq/(b_x),phase,amp)),
band_osc3.lag(0.1),2.sqrt.reciprocal),band_osc1.lag(0.1),2.sqrt.reciprocal);
sig2=BPF.ar(BRF.ar(
(LPF.ar(Saw.ar((freq),mul:amp).abs,low/16)*SinOsc.ar(freq/(b_y),phase,amp)),
band_osc4.lag(0.1),2.sqrt.reciprocal),band_osc2.lag(0.1),2.sqrt.reciprocal);
sig3=BPF.ar(BRF.ar(
(LPF.ar(Saw.ar((freq),mul:amp).abs,low/16)*SinOsc.ar(freq/(b_z),phase,amp)),
band_osc4.lag(0.1),2.sqrt.reciprocal),band_osc2.lag(0.1),2.sqrt.reciprocal);*/


sig1=BPF.ar(BRF.ar(
(LPF.ar(SoundIn.ar(0,mul:amp).abs,low/16)*SinOsc.ar(freq/(b_x),phase,amp)),
band_osc3.lag(0.1),2.sqrt.reciprocal),band_osc1.lag(0.1),2.sqrt.reciprocal);
sig2=BPF.ar(BRF.ar(
(LPF.ar(SoundIn.ar(0,mul:amp).abs,low/16)*SinOsc.ar(freq/(b_y),phase,amp)),
band_osc4.lag(0.1),2.sqrt.reciprocal),band_osc2.lag(0.1),2.sqrt.reciprocal);
sig3=BPF.ar(BRF.ar(
(LPF.ar(SoundIn.ar(0,mul:amp).abs,low/16)*SinOsc.ar(freq/(b_z),phase,amp)),
band_osc4.lag(0.1),2.sqrt.reciprocal),band_osc2.lag(0.1),2.sqrt.reciprocal);

/*sig1=BPF.ar(BRF.ar(
(LPF.ar(LFTri.ar((freq),mul:amp),low/4)*SinOsc.ar(freq/(b_x),phase,amp)),
	band_osc3.lag(0.1),2.sqrt.reciprocal),band_osc1.lag(0.1),2.sqrt.reciprocal);
sig2=BPF.ar(BRF.ar(
(LPF.ar(LFTri.ar((freq),mul:amp),low/4)*SinOsc.ar(freq/(b_y),phase,amp)),
band_osc4.lag(0.1),2.sqrt.reciprocal),band_osc2.lag(0.1),2.sqrt.reciprocal);
sig3=BPF.ar(BRF.ar(
(LPF.ar(LFTri.ar((freq),mul:amp),low/4)*SinOsc.ar(freq/(b_z),phase,amp)),
band_osc4.lag(0.1),2.sqrt.reciprocal),band_osc2.lag(0.1),2.sqrt.reciprocal);*/

sig1=LPF.ar(sig1,2.pow(low.lag(0.1)/992)); sig2=LPF.ar(sig2,2.pow(low.lag(0.1)/992)); sig3=LPF.ar(sig3,2.pow(low.lag(0.1)/992));
sig1=HPF.ar(sig1,2.pow(high.lag(0.1)/992)); sig2=HPF.ar(sig2,2.pow(high.lag(0.1)/992)); sig3=HPF.ar(sig3,2.pow(high.lag(0.1)/992));

cell_az=Osc.kr(~w.bufnum,2.pow(pan_speed.lag(0.1)/992),phase:0.degrad).range(180.neg,180);
cell_el=SinOsc.kr(2.pow(pan_speed.lag(0.1)/992),phase:90.degrad).range(90.neg,90);

cell_l=SinOsc.kr(2.pow(pan_speed.lag(0.1)/992),phase:0.degrad);
cell_r=SinOsc.kr(2.pow(pan_speed.lag(0.1)/992),phase:180.degrad);
cell_tria=SinOsc.kr(2.pow(pan_speed.lag(0.1)/992),phase:90.degrad);

out1=VBAP.ar(6,FreeVerb.ar(sig1,mix,room,mul:1),~b.bufnum,(silver1+cell_az.lag(0.1)).wrap(180.neg,180),
(silver1.wrap(90.neg,90)+cell_el.lag(0.1)).wrap(90.neg,90));

out2=VBAP.ar(6,FreeVerb.ar(sig2,mix,room,mul:1),~b.bufnum,(silver2+cell_az.lag(0.1)).wrap(180.neg,180),
(silver2.wrap(90.neg,90)+cell_el.lag(0.1)).wrap(90.neg,90));

out3=VBAP.ar(6,FreeVerb.ar(sig3,mix,room,mul:1),~b.bufnum,(silver3+cell_az.lag(0.1)).wrap(180.neg,180),
(silver2.wrap(90.neg,90)+cell_el.lag(0.1)).wrap(90.neg,90));


Out.ar(2,Limiter.ar(LeakDC.ar(out1,mul:2)*gain,0.1));
Out.ar(2,Limiter.ar(LeakDC.ar(out2,mul:2)*gain,0.1));
Out.ar(2,Limiter.ar(LeakDC.ar(out3,mul:2)*gain,0.1));

Out.ar(0,Pan2.ar(Limiter.ar(LeakDC.ar(FreeVerb.ar(sig1,mix,room,mul:2),mul:1)*gain,0.1),(linex+cell_l.lag(0.1)).wrap(1.neg,1)));
Out.ar(0,Pan2.ar(Limiter.ar(LeakDC.ar(FreeVerb.ar(sig2,mix,room,mul:2),mul:1)*gain,0.1),(liney+cell_r.lag(0.1)).wrap(1.neg,1)));
Out.ar(0,Pan2.ar(Limiter.ar(LeakDC.ar(FreeVerb.ar(sig3,mix,room,mul:2),mul:1)*gain,0.1),0+cell_tria.lag(0.1)));


gold=(gold+(360-gold_r)).wrap(180.neg,180).round(0.0001);
silver1=(silver1+(360-silver_r)).wrap(180.neg,180).round(0.0001);
silver2=(silver2+(360-silver_r)).wrap(180.neg,180).round(0.0001);
silver3=(silver3+(360-silver_r)).wrap(180.neg,180).round(0.0001);
			}
}).add;);

1.wait;
~synth=Synth.new(\synth,[\gain,100,\tone,0,\low,(496*16*(7/4)),\high,(496*8*(6/5)),\pan_speed,(496*16).neg,\band,(56*8).neg,\lamdoma,10,\brain,4]).register;//s.record
1.wait;

	(
		(
MIDIdef.cc(\midi_pot1,{ |val, num, chan, src|
		var gain;
	//[val, num, chan, src].postln;
	gain=val.linlin(0,127,0,1000).round(0.000001);
		gain.postln;
		if(~synth.isPlaying,{~synth.set(\gain,gain)});
},26);
	);
			////note//2.pow((496*8*(6/5))/992)
			////note//2.pow((56*32)/56).round(000.1)
	(
MIDIdef.cc(\midi_pot2,{ |val, num, chan, src|
		 var high;
	high=val.linlin(0,127,(496*8*(6/5)),(496*16*(7/4))).round(0.00001);
		high.postln;
		if(~synth.isPlaying,{~synth.set(\high,high)});
},27);
	);
		(
MIDIdef.cc(\midi_pot3,{ |val, num, chan, src|
		var pan;
		pan=val.linlin(0,127,(496*16).neg,496*4).round(0.00001).round(1).asInteger;
		pan.postln;
		if(~synth.isPlaying,{~synth.set(\pan_speed,pan)});
},28);
	);

	(
MIDIdef.cc(\midi_pot4,{ |val, num, chan, src|
         var low;
	low=val.linlin(0,127,(496*16*(7/4)),(496*8*(6/5))).round(1).asInteger;
		low.postln;
		if(~synth.isPlaying,{~synth.set(\low,low)});
},29);
	);

		(
MIDIdef.cc(\midi_pot5,{ |val, num, chan, src|
		var band;
	band=val.linlin(0,127,(496*8).neg,496*32).round(1).asInteger;
		band.postln;
		if(~synth.isPlaying,{~synth.set(\band,band)});
},30);
	);
					(
MIDIdef.cc(\midi_pot6,{ |val, num, chan, src|
		var tone;
		tone=val.linlin(0,127,0,496*8).round(1).asInteger;
		tone.postln;
		if(~synth.isPlaying,{~synth.set(\tone,tone)});
},31);
	);
		(
MIDIdef.cc(\midi_switch1,{ |val, num, chan, src|
		var brain;
					if(val>0,brain=32400.rand,brain=32400.rand);
		brain.postln;
		if(~synth.isPlaying,{~synth.set(\brain,brain)});
},14);
	);
	(
MIDIdef.cc(\midi_switch2,{ |val, num, chan, src|
		 var brain;
					if(val>0,brain=32400.rand,brain=32400.rand);

		brain.postln;
		if(~synth.isPlaying,{~synth.set(\brain,brain)});
},15);
	);
		(
MIDIdef.cc(\midi_switch3,{ |val, num, chan, src|
		var brain;
					if(val>0,brain=32400.rand,brain=32400.rand);

		brain.postln;
		if(~synth.isPlaying,{~synth.set(\brain,brain)});
},16);
	);

	(
MIDIdef.cc(\midi_switch4,{ |val, num, chan, src|
         var brain;
					if(val>0,brain=32400.rand,brain=32400.rand);
		brain.postln;
		if(~synth.isPlaying,{~synth.set(\brain,brain)});
},17);
	);
		(
MIDIdef.cc(\midi_switch5,{ |val, num, chan, src|
		var brain;
				if(val>0,brain=32400.rand,brain=32400.rand);

		brain.postln;
		if(~synth.isPlaying,{~synth.set(\brain,brain)});
},18);
	);
					(
MIDIdef.cc(\midi_switch6,{ |val, num, chan, src|
		var brain;
				if(val>0,brain=32400.rand,brain=32400.rand);
		brain.postln;
		if(~synth.isPlaying,{~synth.set(\brain,brain)});
},19);
	);

	(
MIDIdef.cc(\midi_switch7,{ |val, num, chan, src|
		var lamdoma;
				if(val>0,lamdoma=12,lamdoma=12);
		lamdoma.postln;
		if(~synth.isPlaying,{~synth.set(\lamdoma,lamdoma)});
},20);
	);
	(
MIDIdef.cc(\midi_switch8,{ |val, num, chan, src|
		 var lamdoma;
				if(val>0,lamdoma=12*2,lamdoma=12*2);
		lamdoma.postln;
		if(~synth.isPlaying,{~synth.set(\lamdoma,lamdoma)});
},21);
	);
		(
MIDIdef.cc(\midi_switch9,{ |val, num, chan, src|
		var lamdoma;
					if(val>0,lamdoma=12*3,lamdoma=12*3);
		lamdoma.postln;
		if(~synth.isPlaying,{~synth.set(\lamdoma,lamdoma)});
},22);
	);

	(
MIDIdef.cc(\midi_switch10,{ |val, num, chan, src|
         var lamdoma;
				if(val>0,lamdoma=12*4,lamdoma=12*4);
		lamdoma.postln;
		if(~synth.isPlaying,{~synth.set(\lamdoma,lamdoma)});
},23);
	);
		(
MIDIdef.cc(\midi_switch11,{ |val, num, chan, src|
		var lamdoma;
				if(val>0,lamdoma=12*5,lamdoma=12*5);
		lamdoma.postln;
		if(~synth.isPlaying,{~synth.set(\lamdoma,lamdoma)});
},24);
	);
					(
MIDIdef.cc(\midi_switch12,{ |val, num, chan, src|
		var lamdoma;
				if(val>0,lamdoma=12*6,lamdoma=12*6);
		lamdoma.postln;
		if(~synth.isPlaying,{~synth.set(\lamdoma,lamdoma)});
},25);
	);

)
});
	Tdef(\drone).play;
}
)
)





/*	r=val.linlin(0,127,(0.0001),1).round(0.0001);
		r.postln;
		if(~synth.isPlaying,{~synth.set(\room,r)});

	m=val.linlin(0,127,0.1,1).round(0.1);
		m.postln;
		if(~synth.isPlaying,{~synth.set(\mix,m)});*/

