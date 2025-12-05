




(
{Out.ar(0,BPF.ar(BrownNoise.ar(SinOsc.ar(1/2,0.degrad).range(0.1*10,0.1)),SinOsc.ar(1/2,0.degrad).range(110,110*100),0.5))}.play;
{Out.ar(1,BPF.ar(BrownNoise.ar(SinOsc.ar(1/2,0.degrad).range(0.1*10,0.1)),SinOsc.ar(1/2,0.degrad).range(110,110*100),0.5))}.play;
{Out.ar(0,BPF.ar(BrownNoise.ar(SinOsc.ar(1/2,90.degrad).range(0.1*10,0.1)),SinOsc.ar(1/2,90.degrad).range(110,110*100),0.5))}.play;
{Out.ar(1,BPF.ar(BrownNoise.ar(SinOsc.ar(1/2,90.degrad).range(0.1*10,0.1)),SinOsc.ar(1/2,90.degrad).range(110,110*100),0.5))}.play;
)

///BRF with 180.degrad oscillation for inverse bpf
