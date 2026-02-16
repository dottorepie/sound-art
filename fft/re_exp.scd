(
s.options.numWireBufs = 1024*8;
s.options.numOutputBusChannels=8;
s.options.numInputBusChannels=0;
TempoClock.default.tempo_(1);
s.options.memSize = 8192*32;
s.options.blockSize = 64;
s.options.maxNodes = 1024 * 4;
//s.options.sampleRate= 44100;
//s.recHeaderFormat="aiff";
//s.recSampleFormat ="int16";
//s.recChannels = 8;
s.boot;
~frames=1024;
)


Buffer.freeAll
(
~c1 = Buffer.readChannel(s,,channels:0 );
~c2 = Buffer.readChannel(s,,channels:1 );
)

////speaker setup

///cube

(
~a = VBAPSpeakerArray.new(3,
[[45, 35.264390.neg], [135, 35.264390.neg], [45.neg, 35.264390.neg], [135.neg, 35.264390.neg],[45,35.264390],[135,35.264390],[45.neg,35.264390],[135.neg,35.264390]]);
	 ~b = Buffer.loadCollection(s, ~a.getSetsAndMatrices);
)


(
			{
var steps = 8;

~nVals = steps.collect { |i|
    i.linexp(0, steps-1, 0.18, 463).round
};
			~nVals.asInteger;
			}.value;
		)

(
SynthDef.new(\re, {
	var chain1rl,chain2rl,chain3rl,chain4rl,chain5rl,chain6rl,chain7rl,chain8rl;
	var chain1rr,chain2rr,chain3rr,chain4rr,chain5rr,chain6rr,chain7rr,chain8rr;
    var sig1rl,sig2rl,sig3rl,sig4rl,sig5rl,sig6rl,sig7rl,sig8rl;
	var sig1rr,sig2rr,sig3rr,sig4rr,sig5rr,sig6rr,sig7rr,sig8rr;
	var sph, anglex,angley,anglez;
	var frames=~frames,silver=45,golden=45,g=((1+5.sqrt)/2),s=(1+2.sqrt);
	var in1,in2,az,el,pan;

     in1 = PlayBuf.ar(1, ~c1.bufnum, BufRateScale.kr(~c1.bufnum), loop: 0, doneAction:2);
	in2 = PlayBuf.ar(1, ~c2.bufnum, BufRateScale.kr(~c2.bufnum), loop: 0, doneAction:2);

	chain1 = FFT(LocalBuf(frames), in1);
	chain2 = FFT(LocalBuf(frames), in2);

chain1rl = chain1.pvcollect(frames,
						{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[0], tobin: ~nVals.[0], zeroothers: 1);
chain2rl = chain1.pvcollect(frames,
						{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[0]+1, tobin: ~nVals.[1], zeroothers: 1);
chain3rl = chain1.pvcollect(frames,
					{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[1]+1, tobin: ~nVals.[2], zeroothers: 1);
chain4rl = chain1.pvcollect(frames,
					{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[2]+1, tobin: ~nVals.[3], zeroothers: 1);
chain5rl = chain1.pvcollect(frames,
					{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[3]+1, tobin: ~nVals.[4], zeroothers: 1);
chain6rl = chain1.pvcollect(frames,
					{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[4]+1, tobin: ~nVals.[5], zeroothers: 1);
chain7rl = chain1.pvcollect(frames,
					{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[5]+1, tobin: ~nVals.[6], zeroothers: 1);
chain8rl = chain1.pvcollect(frames,
					{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[6]+1, tobin: ~nVals.[7], zeroothers: 1);

chain1rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; },  frombin: ~nVals.[0], tobin: ~nVals.[0], zeroothers: 1);
chain2rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; },  frombin: ~nVals.[0]+1, tobin: ~nVals.[1], zeroothers: 1);
chain3rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[1]+1, tobin: ~nVals.[2], zeroothers: 1);
chain4rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[2]+1, tobin: ~nVals.[3], zeroothers: 1);
chain5rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[3]+1, tobin: ~nVals.[4], zeroothers: 1);
chain6rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[4]+1, tobin: ~nVals.[5], zeroothers: 1);
chain7rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[5]+1, tobin: ~nVals.[6], zeroothers: 1);
chain8rr = chain2.pvcollect(frames,
			{|mag, phase, index| [mag, (phase)]; }, frombin: ~nVals.[6]+1, tobin: ~nVals.[7], zeroothers: 1);


	sig1rl=IFFT(chain1rl);sig2rl=IFFT(chain2rl);sig3rl=IFFT(chain3rl);sig4rl=IFFT(chain4rl);
sig5rl=IFFT(chain5rl);sig6rl=IFFT(chain6rl);sig7rl=IFFT(chain7rl);sig8rl=IFFT(chain8rl);

sig1rr=IFFT(chain1rr);sig2rr=IFFT(chain2rr);sig3rr=IFFT(chain3rr);sig4rr=IFFT(chain4rr);
sig5rr=IFFT(chain5rr);sig6rr=IFFT(chain6rr);sig7rr=IFFT(chain7rr);sig8rr=IFFT(chain8rr);

	az=LFNoise1.ar(0.1).range(pi,pi.neg);
	el=LFNoise1.ar(0.1).range((pi/2),(pi/2).neg);

			sph=Spherical.ar(1,az,el);


anglex=exp(Complex(0,1)*sph.theta).real*exp(Complex(0,1)*sph.phi).real;
angley=exp(Complex(0,1)*sph.theta).imag*exp(Complex(0,1)*sph.phi).real;
anglez=exp(Complex(0,1)*sph.phi).imag;

		pan=Cartesian(anglex,angley,anglez);


Out.ar(0,VBAP.ar(8,LeakDC.ar(sig1rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig2rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig3rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig4rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig5rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig6rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig7rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig8rl),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);

Out.ar(0,VBAP.ar(8,LeakDC.ar(sig1rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig2rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig3rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig4rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig5rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig6rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig7rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);
Out.ar(0,VBAP.ar(8,LeakDC.ar(sig8rr),~b.bufnum,pan.theta.raddeg,pan.phi.raddeg);

}).add;
)




(
Synth(\re);
s.record(numChannels:8,duration:(8*60));
)


