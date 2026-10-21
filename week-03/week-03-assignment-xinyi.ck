SqrOsc lead => Pan2 leadPan => dac;
SinOsc bass => Pan2 bassPan => dac;
SinOsc sky => Pan2 skyPan => dac;
SinOsc coin => Pan2 coinPan => dac;

[
64, -1, 67, 69, -1, 67, 64, -1,
-1, -1, 64, 67, -1, 71, 69, 67,
-1, -1, 64, -1, 67, 69, 71, -1,
69, 67, -1, 64, -1, -1, -1, -1
] @=> int melody[];

[
.13, 0, .11, .15, 0, .11, .13, 0,
0, 0, .12, .11, 0, .15, .12, .10,
0, 0, .12, 0, .11, .14, .16, 0,
.12, .10, 0, .12, 0, 0, 0, 0
] @=> float leadVolume[];

[40, 45, 43, 47] @=> int bassNotes[];

0.12::second => dur step;

Std.mtof(79) => sky.freq;

0.0 => sky.gain;
0.0 => bassPan.pan;
0.0 => coin.gain;

while(true)
{
    for(0 => int i; i < melody.cap(); i++)
    {
        if(melody[i] >= 0)
        {
            Std.mtof(melody[i]) => lead.freq;
            leadVolume[i] => lead.gain;
            Math.sin(i * 0.5) * 0.35 => leadPan.pan;
        }
        else
        {
            0.0 => lead.gain;
        }
        
        (i / 8) % bassNotes.cap() => int chord;
        
        if(i % 8 == 0)
        {
            Std.mtof(bassNotes[chord]) => bass.freq;
            0.16 => bass.gain;
        }
        else if(i % 8 == 4)
        {
            Std.mtof(bassNotes[chord] + 7) => bass.freq;
            0.09 => bass.gain;
        }
        else
        {
            0.0 => bass.gain;
        }
        
        if((i / 8) % 2 == 0)
        {
            0.04 + Math.sin(i * 0.18) * 0.012 => sky.gain;
            Math.sin(i * 0.12) * 0.7 => skyPan.pan;
        }
        else
        {
            0.0 => sky.gain;
        }
        
        if(i == 14)
        {
            Std.mtof(84) => coin.freq;
            0.20 => coin.gain;
            0.45 => coinPan.pan;
        }
        else if(i == 15)
        {
            Std.mtof(91) => coin.freq;
            0.14 => coin.gain;
            -0.35 => coinPan.pan;
        }
        else if(i == 28)
        {
            Std.mtof(86) => coin.freq;
            0.20 => coin.gain;
            -0.35 => coinPan.pan;
        }
        else if(i == 29)
        {
            Std.mtof(93) => coin.freq;
            0.14 => coin.gain;
            0.45 => coinPan.pan;
        }
        else
        {
            0.0 => coin.gain;
        }
        
        step => now;
    }
}