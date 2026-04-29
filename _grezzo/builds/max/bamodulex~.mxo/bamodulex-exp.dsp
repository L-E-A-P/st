declare version "2.59.6";
declare compile_options "-double -omp -vec -double -e ./bamodulex.dsp -o faust.mlg/bamodulex/bamodulex-exp.dsp";
declare library_path0 "/Users/master/Documents/GitHub/st/src/faust/ST.lib";
declare library_path1 "/usr/local/share/faust/stdfaust.lib";
declare filename "bamodulex.dsp";
declare name "bamodulex";
declare vendor "Giuseppe Silvi";
process = \(x1).(\(x2).(\(x3).(\(x4).(((((x1,x2 : +),x3 : +),x4 : +),2 : /),((((x1,x2 : -),x3 : -),x4 : +),2 : /),((((x1,x2 : -),x3 : +),x4 : -),2 : /),((((x1,x2 : +),x3 : -),x4 : -),2 : /)))));
