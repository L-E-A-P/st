declare version "2.68.2";
declare compile_options "-double -scal -double -e ./abmodulex.dsp -o faust.2DP/abmodulex/abmodulex-exp.dsp";
declare library_path0 "/Users/master/Downloads/abmodulex/ST.lib";
declare library_path1 "/usr/local/share/faust/stdfaust.lib";
declare filename "abmodulex.dsp";
declare name "abmodulex";
process = \(x1).(\(x2).(\(x3).(\(x4).((0.5,(((x1,x2 : +),x3 : +),x4 : +) : *),(0.5,(((x1,x2 : -),x3 : -),x4 : +) : *),(0.5,(((x1,x2 : -),x3 : +),x4 : -) : *),(0.5,(((x1,x2 : +),x3 : -),x4 : -) : *)))));
