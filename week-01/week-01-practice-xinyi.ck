SinOsc s1;
s1 => dac;

0.15 => s1.gain;
200 => s1.freq;

while(true)
{
    200 + Math.random2(0, 200) => s1.freq;
    0.1 + Math.random2f(0.0, 0.1) => s1.gain;
    
    1::second => now;
} 