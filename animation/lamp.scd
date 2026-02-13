(
var data,run = true,w,b,xx,yy,zz,r;
var ot=0.degrad;


~data = [];


w = Window.new("3D Scatterplot", Rect(40,40, 800, 800)).front;

~v = UserView.new(w,Rect(0,0,800,800)).background_(Color.black);
b = ScatterView3d(~v, Rect(0,0, 800,800), ~data, [-1000, 1000].asSpec,[-1000, 1000].asSpec,[-1000, 1000].asSpec);
b.drawMethod = \fillRect;
b.symbolSize = 2;
b.symbolColor = Color.white;
b.background = Color.black;

~v.animate;
~v.drawFunc ={
Pen.translate(400,400);

		b.rot(ot,ot,ot);
    ~v.refresh;
	ot=ot+(2pi/360);

};

{ while { run } {~v.background_(Color.black); ~v.refresh; (1/100).wait } }.fork(AppClock);

  r= Routine({loop{


	xx=~controlBus_1.getSynchronous*10;
	yy=~controlBus_2.getSynchronous*10;
	zz=~controlBus_3.getSynchronous*10;

	~data=[[0,0,zz],[0,yy,0],[xx,0,0]];


 	b.data = ~data;            // Update ScatterView3d
0.001.wait
};

});

r.play;
)