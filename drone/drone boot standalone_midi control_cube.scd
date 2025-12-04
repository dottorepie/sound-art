
(
(
s.options.numWireBufs = 1024*4;
|
TempoClock.default.tempo_(1);
s.options.memSize = 8192*16;
s.options.blockSize = 64;
s.options.maxNodes = 1024 * 4;
//s.options.sampleRate= 44100;
//s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
//s.recChannels = 8;
s.boot;
MIDIClient.init;
MIDIIn.connectAll;
s.meter;
s.freqscope;
);


//// two same oscillator with as many partials as possible and tone range 2.pow(n/16256)
////binaural brain waves interval between oscillators 0.7Hz to 150Hz according to alertness level
////fm noise modulator randomness

/////// add tact switch (rotary switch knob) with lamdoma fundamentals (12 digital pins, pins the rotary knob has)
//// 6 switches can set different binaural intervals via second rotary switch knob (6 positions) for:
///1.rand value(0.5-3Hz), 2.rand value(4-7Hz), 3.rand value(8-12Hz), 4.rand value(12.5-15Hz), 5.(15-30Hz), 6.(30-110Hz)

///// analog knobs (6): 1.tone, 2.master gain, 3.bandpass modulator speed (static rq) 4.pan speed for pan modulator (elevation), 5.lowpass, 6.highpass
///highpass and reverb values static or random on every reboot along with fm noise modulator



(
s.waitForBoot{
	Tdef(\cmrc, {
	Buffer.freeAll;

		///cube
		(
~a = VBAPSpeakerArray.new(3,
[[45, 35.264390.neg], [135, 35.264390.neg], [45.neg, 35.264390.neg], [135.neg, 35.264390.neg],[45,35.264390],[135,35.264390],[45.neg,35.264390],[135.neg,35.264390]]);
	 ~b = Buffer.loadCollection(s, ~a.getSetsAndMatrices);
);

(
SynthDef.new(\drone,{

	arg gain=1,low=7168,high=0,tone=0,mix=0,room=0,band=1,lamdoma;
	var gold=45,silve=45,gold_r=((1+5.sqrt)/2),silver_r=(1+2.sqrt);
	var freq,fund,n=0,m,phase,linex,liney,interval,n1,n2,amp1,amp2,m1,m2,alpha,cell;
	var sig1,sig2,note=56,bank=3,out1,out2,out3,out4,fm,brain;


bank.do{

n=2.pow(tone/16256).round(0.0001);

fund=(note*lamdoma)*n;
n=n+1;
interval=gold_r
m=n*interval;
freq=funda*m;
amp=m.reciprocal*n.reciprocal;
phase=golden.degrad;

golden=(golden+(360-gold_r)).wrap(180.neg,180).round(0.0001);
silver=(silver+(360-silver_r)).wrap(180.neg,180).round(0.0001);
fm=LFNoise1.ar(amp,amp.reciprocal);

sig1=(LPF.ar(Pulse.ar((freqa*2)+fm,width:0.5,mul:amp1).abs,low/8)*SinOsc.ar(freqa+fm1,phase,amp1));
sig2=(LPF.ar(Pulse.ar((freqa*2)+fm+brain,width:0.5,mul:amp1).abs,low/8)*SinOsc.ar(freqa+fm1+alpha,phase,amp1));



sig1=LPF.ar(sig1,low);sig2=LPF.ar(sig2,low);
sig1=HPF.ar(sig1,high);sig2=HPF.ar(sig2,high);


cell_az=SinOsc.kr(pan,phase:0.degrad).range(180.neg,180);
cell_el=SinOsc.kr(pan,phase:90.degrad).range(90.neg,90);

out1=VBAP.ar(8,FreeVerb.ar(sig1,mix,room,mul:1),~b.bufnum,(goldenR).wrap(180.neg,180),
					(silver.wrap(90.neg,90)+cell).wrap(90.neg,90));
out2=VBAP.ar(8,FreeVerb.ar(sig2,mix,room,mul:1),~b.bufnum,(goldenR).wrap(180.neg,180),
					(silver.wrap(90.neg,90)+cell).wrap(90.neg,90));

	Out.ar(0,LeakDC.ar(out1)*gain);
	Out.ar(0,LeakDC.ar(out2)*gain);
			}
}).add;);

1.wait;
	~synth=Synth.new(\drone,[\gain,1,\tone,56*2,\low,16256/2,\high,56,\pan,0.5,\band,0.1]).register;//s.record
1.wait;

	(
MIDIClient.init;
MIDIIn.connectAll;
		(
MIDIdef.cc(\midi1,{ |val, num, chan, src|
		var g;
	//[val, num, chan, src].postln;
	g=val.linlin(0,127,0,2).round(0.0001);
		g.postln;
		if(~synth.isPlaying,{~synth.set(\gain,g)});
},26);
	);
	(
MIDIdef.cc(\midi2,{ |val, num, chan, src|
		 var h;
	h=val.linlin(0,127,56,992).round(0.0001);
		h.postln;
		if(~synth.isPlaying,{~synth.set(\high,h)});
},27);
	);
		(
MIDIdef.cc(\midi3,{ |val, num, chan, src|
		var g;
	g=val.linlin(0,127,0,2).round(0.0001);
		g.postln;
		if(~synth.isPlaying,{~synth.set(\gain,g)});
},28);
	);

	(
MIDIdef.cc(\midi4,{ |val, num, chan, src|
		var pan;
	pan=val.linlin(0,127,0.1,1).round(0.1);
		pan.postln;
		if(~synth.isPlaying,{~synth.set(\pan,pan)});
},29);
	);
		(
MIDIdef.cc(\midi5,{ |val, num, chan, src|
		var band;
	band=val.linlin(0,127,(0.0001),1).round(0.0001);
		band.postln;
		if(~synth.isPlaying,{~synth.set(\band,band)});
},30);
	);
					(
MIDIdef.cc(\midi6,{ |val, num, chan, src|
		var t;
		t=val.linlin(0,127,56*2,56*4).round(1).asInteger;
		t.postln;
		if(~synth.isPlaying,{~synth.set(\tone,t)});
},31);
	);

)
});
	Tdef(\cmrc).play;
}
)
)

	l=val.linlin(0,127,16256,56).round(0.0001);
		l.postln;
		if(~synth.isPlaying,{~synth.set(\low,l)});

	r=val.linlin(0,127,(0.0001),1).round(0.0001);
		r.postln;
		if(~synth.isPlaying,{~synth.set(\room,r)});

	m=val.linlin(0,127,0.1,1).round(0.1);
		m.postln;
		if(~synth.isPlaying,{~synth.set(\mix,m)});