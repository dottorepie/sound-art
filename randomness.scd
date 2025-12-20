
(
var silver_ratio=(1+2.sqrt),gold_ratio=((1+5.sqrt)/2), copper_ratio=pi;

thisThread.randSeed = copper_ratio;

// create a function that returns a Routine

r = { Routine({
    loop({#[0,1,2,3,4,5,6,7,8,9].choose.yield })
}) };
Array.fill(10, r.value);
//r.play;
)