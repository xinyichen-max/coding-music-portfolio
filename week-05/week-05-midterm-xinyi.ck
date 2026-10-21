// midterm1

136.0 => float bpm;
(60.0 / bpm)::second => dur beat;
beat / 4 => dur step;
beat * 4 => dur barTime;

Gain master => dac;
0.35 => master.gain;

// chords

[57, 53, 48, 55] @=> int roots[];
[45, 41, 36, 43] @=> int bassRoots[];
[1, 0, 0, 0] @=> int minor[];

fun int chordNote(int root, int isMinor, int n)
{
    if(n == 0) return root;

    if(n == 1)
    {
        if(isMinor == 1) return root + 3;
        return root + 4;
    }

    if(n == 2) return root + 7;
    if(n == 3) return root + 12;

    return root + 14;
}

// kick

fun void kick(float level)
{
    SinOsc s => ADSR e => Gain g => master;

    level => g.gain;
    e.set(1::ms, 50::ms, 0.0, 40::ms);
    e.keyOn();

    for(0 => int i; i < 40; i++)
    {
        160 - i * 3 => s.freq;
        2::ms => now;
    }

    e.keyOff();
    50::ms => now;
}

// snare

fun void snare(float level)
{
    Noise n => BPF f => ADSR e => Gain g => master;

    1800 => f.freq;
    0.9 => f.Q;
    level => g.gain;

    e.set(1::ms, 40::ms, 0.0, 65::ms);
    e.keyOn();

    55::ms => now;
    e.keyOff();
    70::ms => now;
}

// hat

fun void hat(float level)
{
    Noise n => HPF f => ADSR e => Gain g => master;

    7000 => f.freq;
    level => g.gain;

    e.set(1::ms, 12::ms, 0.0, 25::ms);
    e.keyOn();

    20::ms => now;
    e.keyOff();
    30::ms => now;
}

// bass

fun void bass(int pitch, dur length, float level)
{
    SinOsc a => LPF f => ADSR e => Gain g => master;
    TriOsc b => f;

    Std.mtof(pitch) => a.freq;
    Std.mtof(pitch) * 1.002 => b.freq;

    0.75 => a.gain;
    0.12 => b.gain;

    300 => f.freq;
    level => g.gain;

    e.set(5::ms, 70::ms, 0.45, 120::ms);
    e.keyOn();

    length => now;

    e.keyOff();
    130::ms => now;
}

// pad

fun void pad(int root, int isMinor, dur length, float level)
{
    SinOsc a => Gain mix => LPF f => ADSR e
        => Gain g => master;

    TriOsc b => mix;
    SinOsc c => mix;

    Std.mtof(root) => a.freq;
    Std.mtof(chordNote(root, isMinor, 1)) => b.freq;
    Std.mtof(chordNote(root, isMinor, 2)) => c.freq;

    0.25 => a.gain;
    0.12 => b.gain;
    0.20 => c.gain;

    level => g.gain;

    e.set(400::ms, 300::ms, 0.6, 800::ms);
    e.keyOn();

    for(0 => int i; i < 40; i++)
    {
        500 + i * 25 => f.freq;
        length / 40 => now;
    }

    e.keyOff();
    850::ms => now;
}

// sliding sound

fun void fish(int first, int last, dur length)
{
    SinOsc a => LPF f => ADSR e => Gain g => master;
    TriOsc b => f;

    0.65 => a.gain;
    0.10 => b.gain;

    1200 => f.freq;
    0.09 => g.gain;

    e.set(40::ms, 120::ms, 0.5, 400::ms);

    Std.mtof(first) => float f1;
    Std.mtof(last) => float f2;

    e.keyOn();

    for(0 => int i; i < 50; i++)
    {
        i / 49.0 => float t;

        f1 + (f2 - f1) * t => float freq;

        freq => a.freq;
        freq * 1.002 => b.freq;

        length / 50 => now;
    }

    e.keyOff();
    450::ms => now;
}

// short synth

fun void pluck(int pitch, dur length, float level)
{
    TriOsc a => LPF f => ADSR e => Gain g => master;
    SinOsc b => f;

    Std.mtof(pitch) => a.freq;
    Std.mtof(pitch) * 1.003 => b.freq;

    0.3 => a.gain;
    0.2 => b.gain;

    1400 => f.freq;
    level => g.gain;

    e.set(2::ms, 45::ms, 0.12, 80::ms);
    e.keyOn();

    length => now;

    e.keyOff();
    90::ms => now;
}

// rising arp

fun void arp(int root, int isMinor, float level)
{
    [0,1,2,3, 1,2,3,4,
     0,1,2,3, 1,2,3,4] @=> int order[];

    for(0 => int i; i < 16; i++)
    {
        chordNote(root, isMinor, order[i]) + 12
            => int pitch;

        if(i >= 8)
            12 +=> pitch;

        spork ~ pluck(pitch, step * 0.65, level);

        step => now;
    }
}

// random melody

fun void randomMelody(int root, int isMinor, int section)
{
    for(0 => int i; i < 16; i++)
    {
        Math.random2(0, 4) => int n;
        Math.random2(0, 5) => int chance;

        chordNote(root, isMinor, n) + 12 => int pitch;

        if(section == 3)
        {
            if(Math.random2(0, 1) == 1)
                12 +=> pitch;
        }

        if(chance != 0)
        {
            if(i % 2 == 0 || section == 3)
                spork ~ pluck(pitch, step * 0.8, 0.07);
        }

        step => now;
    }
}

// rising noise

fun void riser(dur length)
{
    Noise n => BPF f => ADSR e => Gain g => master;

    400 => f.freq;
    0.8 => f.Q;
    0.045 => g.gain;

    e.set(200::ms, 200::ms, 0.7, 300::ms);
    e.keyOn();

    for(0 => int i; i < 64; i++)
    {
        400 + i * 50 => f.freq;
        length / 64 => now;
    }

    e.keyOff();
    350::ms => now;
}

// drums

fun void drums(int section, int bar)
{
    for(0 => int i; i < 16; i++)
    {
        if(section == 1)
        {
            if(i == 0 || i == 6 || i == 10)
                spork ~ kick(0.35);

            if(i == 4 || i == 12)
                spork ~ snare(0.13);

            if(i % 4 == 2)
                spork ~ hat(0.025);
        }

        if(section == 2)
        {
            if(i == 0)
                spork ~ kick(0.3);

            if(i == 12)
                spork ~ hat(0.02);
        }

        if(section == 3)
        {
            if(i == 0 || i == 4 || i == 8 || i == 12)
                spork ~ kick(0.38);

            if(i == 4 || i == 12)
                spork ~ snare(0.15);

            if(i % 2 == 0)
                spork ~ hat(0.03);

            if(bar >= 18 && i % 2 == 1)
                spork ~ snare(0.045);

            if(bar == 19 && i % 2 == 0)
                spork ~ snare(0.07);
        }

        if(section == 4)
        {
            if(i == 0 || i == 4 || i == 8 ||
               i == 11 || i == 14)
                spork ~ kick(0.42);

            if(i == 4 || i == 12)
                spork ~ snare(0.17);

            if(i % 2 == 0)
                spork ~ hat(0.04);

            if(i == 3 || i == 7 || i == 15)
                spork ~ hat(0.025);
        }

        step => now;
    }
}

// bass pattern

fun void bassLine(int root, int section)
{
    [0,-1,7,-1, 0,-1,12,-1,
     0,-1,7,-1, 12,-1,7,-1] @=> int pattern[];

    for(0 => int i; i < 16; i++)
    {
        if(pattern[i] >= 0)
        {
            if(section == 4 || i % 4 == 0)
            {
                spork ~ bass(
                    root + pattern[i],
                    step * 1.2,
                    0.19
                );
            }
        }

        step => now;
    }
}

// main

for(0 => int bar; bar < 28; bar++)
{
    (bar / 2) % 4 => int chord;

    roots[chord] => int root;
    bassRoots[chord] => int low;
    minor[chord] => int quality;

    0 => int section;

    if(bar >= 4 && bar < 12)
        1 => section;
    else if(bar >= 12 && bar < 16)
        2 => section;
    else if(bar >= 16 && bar < 20)
        3 => section;
    else if(bar >= 20 && bar < 26)
        4 => section;
    else if(bar >= 26)
        5 => section;

    if(bar % 2 == 0)
    {
        if(section == 2 || section == 5)
            spork ~ pad(root, quality, barTime * 2, 0.12);
        else
            spork ~ pad(root, quality, barTime * 2, 0.17);
    }

    // intro

    if(section == 0)
    {
        if(bar == 2)
            spork ~ fish(
                root + 12,
                root + 19,
                beat * 2
            );
    }

    // groove

    if(section == 1)
    {
        spork ~ drums(1, bar);
        spork ~ bassLine(low, 1);

        if(bar % 2 == 0)
            spork ~ randomMelody(root, quality, 1);
    }

    // break

    if(section == 2)
    {
        spork ~ drums(2, bar);

        if(bar == 14)
            spork ~ fish(root + 12, root + 24, beat * 3);
    }

    // build up

    if(section == 3)
    {
        spork ~ drums(3, bar);
        spork ~ bassLine(low, 3);
        spork ~ arp(root, quality, 0.12);

        if(bar == 17)
            spork ~ riser(barTime * 3);
    }

    // drop

    if(section == 4)
    {
        spork ~ drums(4, bar);
        spork ~ bassLine(low, 4);
        spork ~ arp(root, quality, 0.14);
        spork ~ randomMelody(root, quality, 3);

        if(bar == 24)
            spork ~ fish(root + 12, root + 24, beat * 2);
    }

    // ending

    if(section == 5)
    {
        if(bar == 26)
            spork ~ fish(root + 12, root + 19, beat * 3);
    }

    barTime => now;
}

// fade out

for(35 => int i; i >= 0; i--)
{
    i / 100.0 => master.gain;
    25::ms => now;
}

1::second => now;