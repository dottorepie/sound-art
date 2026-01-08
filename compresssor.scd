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
~n=1.neg;~array=992.collect{~n=~n+1;2.pow(~n/992)};
~a=(0-(pi/496)); ~ph=992.collect{~a=~a+(pi/496);};
~bufferSize = 4096*8;
~signalSize = 2048*8;
);

(
			{
var steps = 64;

~nVals = steps.collect { |i|
    i.linexp(0, steps-1, 1, 64)
};
			~nVals;
			}.value;
		)

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


(
{
var sig,freq=440,low=1;

sig=(LPF.ar((Osc.ar(~w1.bufnum,freq,phase:0,mul:100).abs*SinOsc.ar(freq,phase:0)),freq*));


sig=HPF.ar(sig,50);
sig=Compander.ar(sig,sig,-24.dbamp,1,0.3,0.015,0.3);
sig=tanh(sig*1);
sig=Limiter.ar(sig,1,0.01);
}.play)
