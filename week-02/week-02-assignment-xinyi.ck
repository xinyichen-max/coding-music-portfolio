SinOsc s;
SqrOsc sq;

s => dac;
sq => dac;

0.18 => s.gain;
0 => sq.gain;

while (true)
{
261 => s.freq;
0.18::second => now;
    
329 => s.freq;
0.18::second => now;
    
392 => s.freq;
0.22::second => now;
    
311 => s.freq;
0.18::second => now;
    
247 => s.freq;
0.24::second => now;
    
0.12 => s.gain;
0.05 => sq.gain;
    
293 => s.freq;
523 => sq.freq;
0.18::second => now;
    
349 => s.freq;
466 => sq.freq;
0.18::second => now;
   
440 => s.freq;
587 => sq.freq;
0.22::second => now;
    
330 => s.freq;
494 => sq.freq;
0.18::second => now;
262 => s.freq;
392 => sq.freq;
0.24::second => now;
    
    
0 => sq.gain;
0.18 => s.gain;
    
220 => s.freq;
0.18::second => now;
    
277 => s.freq;
0.18::second => now;
    
370 => s.freq;
0.22::second => now;
    
330 => s.freq;
0.18::second => now;
    
247 => s.freq;
0.24::second => now;
}
