



(
{
    var w, x, y, z, p;

	w=(InFeedback.ar(2)+InFeedback.ar(3)++InFeedback.ar(4))/2.sqrt;

	x=InFeedback.ar(2);

	y=InFeedback.ar(3);

	z=InFeedback.ar(4);

    // B-format decode to stereo with speakers at different distances
    BFDecode1.ar1(w, x, y, z, [0.degrad, 90.degrad], 0,4 ]);

}.scope(2);
)