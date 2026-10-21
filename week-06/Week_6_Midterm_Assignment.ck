// BPM
136.0 => float bpm;
(60.0 / bpm)::second => dur beat;
beat / 4 => dur step;
2 => int variation;
0.13 => float leadLevel;
0.17 => float arpLevel;

// Output
Gain music => JCRev rev => dac;
Gain drums => dac;
0.38 => music.gain;
0.42 => drums.gain;
0.14 => rev.mix;

// Notes
[42,38,45,37] @=> int roots[];
[66,69,73,76,80, 62,66,69,73,80,
69,73,76,80,83, 61,66,68,71,75] @=> int chords[];
[2,-1,3,2,4,-1,3,1] @=> int motif[];
[1,0,1,0,0,1,0,1,1,0,0,1,0,1,0,0] @=> int rhythmA[];
[1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1] @=> int rhythmB[];
[0,-1,7,-1,10,-1,3,-1] @=> int bassNotes[];
[0,2,3,4,1,2,3,4] @=> int arpNotes[];

fun int chordNote(int chord, int degree)
{
    return chords[chord*5+degree];
}

// Synth
fun void synth(int pitch, dur length, float level, int sound)
{
    TriOsc a => LPF f => ADSR e => Pan2 p => music;
    SinOsc b => f;
    SawOsc c => f;
    Std.mtof(pitch) => a.freq;
    Std.mtof(pitch)*1.003 => b.freq;
    Std.mtof(pitch) => c.freq;
    
    if(sound == 0)
    {
        0.32 => a.gain;
        0.24 => b.gain;
        0.0 => c.gain;
        Math.random2f(650,1100) => f.freq;
    }
    else
    {
        0.12 => a.gain;
        0.20 => b.gain;
        0.18 => c.gain;
        Math.random2f(1300,2100) => f.freq;
    }
    Math.random2f(-0.5,0.5) => p.pan;
    level => e.gain;
    
    // ADSR
    e.set(5::ms,55::ms,0.3,200::ms);
    e.keyOn();
    length => now;
    e.keyOff();
    220::ms => now;
}

// Pad
fun void pad(int chord, float level)
{
    SinOsc a => Gain mix => LPF f => ADSR e => music;
    TriOsc b => mix;
    SinOsc c => mix;
    SinOsc d => mix;
    Std.mtof(chordNote(chord,0)-12) => a.freq;
    Std.mtof(chordNote(chord,2)-12) => b.freq;
    Std.mtof(chordNote(chord,3)-12) => c.freq;
    Std.mtof(chordNote(chord,4)-12) => d.freq;
    0.20 => a.gain;
    0.12 => b.gain;
    0.10 => c.gain;
    0.14 => d.gain;
    
    // ADSR
    level => e.gain;
    e.set(400::ms,300::ms,0.65,900::ms);
    e.keyOn();
    
    // Filter
    for(0 => int i; i < 48; i++)
    {
        550+950*Math.pow(Math.sin(i*0.09),2) => f.freq;
        (beat*8)/48 => now;
    }
    e.keyOff();
    950::ms => now;
}

// Kick
fun void kick()
{
    SinOsc s => ADSR e => drums;
    0.70 => e.gain;
    e.set(1::ms,60::ms,0.0,35::ms);
    e.keyOn();
    for(0 => int i; i < 30; i++)
    {
        45+110*Math.exp(-i*0.22) => s.freq;
        3::ms => now;
    }
    e.keyOff();
    40::ms => now;
}

// Snare and Hat
fun void drum(int type)
{
    Noise n => BPF f => ADSR e => drums;
    if(type == 0)
    {
        2100 => f.freq;
        0.23 => e.gain;
    }
    else
    {
        6500 => f.freq;
        0.06 => e.gain;
    }
    e.set(1::ms,25::ms,0.0,40::ms);
    e.keyOn();
    50::ms => now;
    e.keyOff();
    45::ms => now;
}

// Wind
fun void wind(float level)
{
    Noise n => LPF f => ADSR e => music;
    400 => f.freq;
    level => e.gain;
    e.set(800::ms,400::ms,0.5,900::ms);
    e.keyOn();
    
    for(0 => int i; i < 64; i++)
    {
        220+350*Math.pow(Math.sin(i*0.11),2) => f.freq;
        (beat*16)/64 => now;
    }
    e.keyOff();
    950::ms => now;
}

// Bird
fun void bird(int chord)
{
    SinOsc s => LPF f => ADSR e => Pan2 p => music;
    Math.random2f(-0.7,0.7) => p.pan;
    1800 => f.freq;
    0.045 => e.gain;
    e.set(10::ms,60::ms,0.4,300::ms);
    Std.mtof(chordNote(chord,Math.random2(1,3))) => float start;
    e.keyOn();
    
    for(0 => int i; i < 24; i++)
    {
        start*(1.0+0.25*Math.sin(i*0.12)) => s.freq;
        12::ms => now;
    }
    e.keyOff();
    350::ms => now;
}

// Random FX
fun void fx(int chord, int type)
{
    SinOsc s => Gain sg => Pan2 p => music;
    Noise n => BPF f => Gain ng => p;
    Math.random2f(-0.75,0.75) => p.pan;
    0.0 => sg.gain;
    0.0 => ng.gain;
    
    // Glitch
    if(type == 0)
    {
        for(0 => int i; i < Math.random2(3,7); i++)
        {
            Math.random2f(450,3000) => s.freq;
            Math.random2f(0.012,0.045) => sg.gain;
            Math.random2(12,35)::ms => now;
            0.0 => sg.gain;
            Math.random2(15,45)::ms => now;
        }
    }
    // Ghost
    else if(type == 1)
    {
        Std.mtof(chordNote(chord,Math.random2(1,4))) => float freq;
        for(0 => int i; i < 3; i++)
        {
            freq*(1.0+i*0.12) => s.freq;
            0.065*Math.pow(0.45,i) => sg.gain;
            45::ms => now;
            0.0 => sg.gain;
            100::ms => now;
        }
    }
    // Riser
    else
    {
        0.0 => p.pan;
        for(0 => int i; i < 40; i++)
        {
            i/39.0 => float t;
            350+1800*t*t => f.freq;
            0.018*t*t => ng.gain;
            20::ms => now;
        }
    }
    0.0 => sg.gain;
    0.0 => ng.gain;
}

// Main Melody
fun void mainMelody(int chord, int bar, int s, int change)
{
    motif[(s/2)%motif.cap()] => int degree;
    if(degree < 0)
        Math.random2(0,4) => degree;
    if(change == 1 && s >= 12)
        Math.random2(2,4) => degree;
    if(Math.random2(0,10) < variation)
        return;
    
    chordNote(chord,degree) => int pitch;
    if(bar >= 32 && s >= 8)
        12 +=> pitch;
    
    if(bar >= 32)
        spork ~ synth(pitch,step*0.85,0.17,1);
    else if(bar >= 20)
        spork ~ synth(pitch,step*0.9,leadLevel,1);
    else
        spork ~ synth(pitch,step*1.1,leadLevel,0);
}

// Arpeggio
fun void arp(int chord)
{
    Math.random2(0,1) => int style;
    for(0 => int i; i < 16; i++)
    {
        arpNotes[i%8] => int degree;
        if(style == 1 && i%8 == 6)
            Math.random2(2,4) => degree;
        
        chordNote(chord,degree) => int pitch;
        if(i >= 8)
            12 +=> pitch;
        if(i%8 != 7)
            spork ~ synth(pitch,step*0.65,arpLevel,1);
        step => now;
    }
}

// Answer Synth
fun void answerSynth(int chord)
{
    step*8 => now;
    for(0 => int i; i < 8; i++)
    {
        chordNote(chord,arpNotes[i])+12 => int pitch;
        spork ~ synth(pitch,step*0.7,0.10,0);
        step => now;
    }
}

// Arrangement
for(0 => int bar; bar < 48; bar++)
{
    (bar/2)%4 => int chord;
    
    // Pad
    if(bar%2 == 0)
    {
        if(bar >= 32 && bar < 40)
            spork ~ pad(chord,0.18);
        else
            spork ~ pad(chord,0.12);
    }
    
    // Wind and Bird
    if(bar%4 == 0)
    {
        if(bar < 8 || bar >= 40)
            spork ~ wind(0.022);
        else
            spork ~ wind(0.008);
    }
    if((bar < 8 || bar >= 40) && bar%4 == 2)
        spork ~ bird(chord);
    
    // Chorus
    if(bar >= 32 && bar < 40)
    {
        spork ~ arp(chord);
        if(bar%2 == 0)
            spork ~ answerSynth(chord);
    }
    
    // FX
    if(bar == 23 || bar == 31)
        spork ~ fx(chord,2);
    
    Math.random2(0,1) => int rhythm;
    Math.random2(0,1) => int change;
    
    for(0 => int s; s < 16; s++)
    {
        // Drums and Bass
        if(bar >= 8 && bar < 44)
        {
            0 => int playKick;
            
            if(bar < 20 || bar >= 40)
            {
                if(s%4 == 0) 1 => playKick;
            }
            else if(bar < 32)
            {
                if(s==0 || s==6 || s==10 || s==14)
                    1 => playKick;
            }
            else
            {
                if(s==0 || s==4 || s==8 || s==11 || s==14)
                    1 => playKick;
            }
            
            if(playKick == 1) spork ~ kick();
            if(s==4 || s==12) spork ~ drum(0);
            if(s%4 == 2) spork ~ drum(1);
            
            if(s%2 == 0)
            {
                bassNotes[(s/2)%8] => int interval;
                if(interval >= 0)
                    spork ~ synth(roots[chord]+interval,step*1.2,0.20,0);
            }
        }
        
        // Melody
        0 => int play;
        if(rhythm == 0)
            rhythmA[s] => play;
        else
            rhythmB[s] => play;
        
        if(bar >= 4 && bar < 44 && play == 1)
            mainMelody(chord,bar,s,change);
        
        // FX
        if(Math.random2(0,110) < variation)
            spork ~ fx(chord,Math.random2(0,2));
        
        step => now;
    }
}
2::second => now;
