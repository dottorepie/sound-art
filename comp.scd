
(
var data;
var az=0,el=0,pl=0,pl1=0,iter=90,rep=45,sphcart;
var r1,harm1,r2,harm2,rad,sph,y=1,x=1;
var run = true,mag=1000,ot=0.degrad;

~data=[];

 iter.do{
data=rep.collect{
	el=~el.[pl];
	y=1/x;
	x=x+0.01;
	pl=pl+1;

		sph=Spherical(mag,az,el);
		sphcart=Cartesian(sph.x*y,sph.y*y,sph.z).asArray;
};

	az=~az.[pl1];
	pl1=pl1+1;
	y=1;x=1;mag=1000;
	~data=~data++data;
};

w = Window.new("3D Scatterplot", Rect(40,40, 1000, 800)).front;
a = ScatterView3d(w, Rect(0,0, 800,800), ~data, [-1000, 1000].asSpec,[-1000, 1000].asSpec,[-1000, 1000].asSpec);
a.drawMethod = \fillRect;
a.symbolSize = 1;
a.symbolColor = Color.white;
a.background = Color.black;

// Y Slider
Slider(w, Rect(820, 10, 10, 450)).action_{|me|
    a.rotY = me.value * 2pi;
    w.refresh;
};
// X Slider
Slider(w, Rect(870, 10, 10, 450)).action_{|me|
    a.rotX = me.value * 2pi;
    w.refresh;
};
// Z Slider
Slider(w, Rect(920, 10, 10, 450)).action_{|me|
    a.rotZ = me.value * 2pi;
    w.refresh;
};

)


(
var data;
var az=0,el=0,pl=0,pl1=0,iter=90,rep=45,sphcart;
var r1,harm1,r2,harm2,rad,sph,y=1,x=1;
var run = true,mag=1000,ot=0.degrad;

~data=[];

 iter.do{
data=rep.collect{
	el=~el.[pl];
	y=1/x;
	x=x+0.1;
	pl=pl+1;

		sph=Spherical(mag,az,el);
		sphcart=Cartesian(sph.x*y,sph.y*y,sph.z).asArray;
};

	az=~az.[pl1];
	pl1=pl1+1;
	y=1;x=1;mag=1000;
	~data=~data++data;
};

w = Window.new("3D Scatterplot", Rect(40,40, 800, 800)).front;

~v = UserView.new(w,Rect(0,0,800,800)).background_(Color.black);
a = ScatterView3d(~v, Rect(0,0, 800,800), ~data, [-1000, 1000].asSpec,[-1000, 1000].asSpec,[-1000, 1000].asSpec);
a.drawMethod = \fillRect;
a.symbolSize = 1;
a.symbolColor = Color.white;
a.background = Color.black;

~v.animate;
~v.drawFunc ={
Pen.translate(400,400);

		a.rot(ot,ot,ot);
    ~v.refresh;

		ot=ot+0.5.degrad;

};
{ while { run } {~v.background_(Color.black); ~v.refresh; (1/1000).wait } }.fork(AppClock);
)


/////////////
(
{
	var az=0,el1=0,sph,n=90,iter=45,rep=360,el,silver=(1+2.sqrt);
	~az=[];~el=[];

rep.do{
el=iter.collect{
		el1 = 90/n;
			n=n-2;
sph=Spherical(1,az.degrad,el1.degrad).phi.round(0.000000000001);
	};
~az=~az++az.degrad;~el=~el++el;
//az = (az+1).wrap(0,360);
		az=(az+(360-(360/silver))).wrap(0,360);
el1=0;n=90;
	};
}.value;
)
