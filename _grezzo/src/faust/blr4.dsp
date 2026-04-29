declare name "BFormat linkwitz-riley LR4";
declare vendor "Giuseppe Silvi";

import("ST.lib");

//process = os.osc(1000) <: seq(i,2,fi.lowpass(2,1000)), seq(i,2,fi.highpass(2,1000)) : + ;

blr4(w,x,y,z,fc) =  (w : lr4(fc)),
            (x : lr4(fc) : !,_),
            (y : lr4(fc) : !,_),
            (z : lr4(fc) : !,_):
            ro.cross1n(4);

process = blr4;