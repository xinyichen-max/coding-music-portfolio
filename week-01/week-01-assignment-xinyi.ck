// osc 1
SinOsc s1;
s1 => dac;

0.25 => s1.gain;
200 => s1.freq;

1::second => now;


// change frequency
300 => s1.freq;
0.2 => s1.gain;

1::second => now;


// osc2
SinOsc s2;
s2 => dac;

0.15 => s2.gain;
300 => s2.freq;

2::second => now;


// change the second osc
0.1 => s2.gain;
150 => s2.freq;

2::second => now;