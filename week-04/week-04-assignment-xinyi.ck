124.0 => float bpm;
(60.0 / bpm)::second / 4 => dur stepLength;

Gain master => dac;
SndBuf deepKick => master;
SndBuf lightKick => master;
SndBuf snare => master;
SndBuf hat => master;
SndBuf2 air => dac;

me.dir() + "/audio/kick_04.wav" => deepKick.read;
me.dir() + "/audio/kick_03.wav" => lightKick.read;
me.dir() + "/audio/snare_03.wav" => snare.read;
me.dir() + "/audio/hihat_02.wav" => hat.read;

deepKick.samples() => deepKick.pos;
lightKick.samples() => lightKick.pos;
snare.samples() => snare.pos;
hat.samples() => hat.pos;

0.72 => master.gain;
0.66 => deepKick.gain;
0.16 => lightKick.gain;
0.24 => snare.gain;
0.08 => hat.gain;

0.78 => deepKick.rate;
0.96 => lightKick.rate;
0.88 => snare.rate;
0.94 => hat.rate;

//pad.
TriOsc padLow => Gain padBus => dac;
SinOsc padMid => padBus;
SinOsc padHigh => padBus;
0.24 => padLow.gain;
0.16 => padMid.gain;
0.10 => padHigh.gain;
0.0 => padBus.gain;

//melody
TriOsc lead => Gain leadBus => dac;
0.22 => lead.gain;
0.0 => leadBus.gain;
[62, 65, 69, 67] @=> int leadNotes[];
0 => int leadNote;

for (0 => int step; step < 248; step++)
{
    step % 16 => int place;
    step / 16 => int bar;

    // Keep the opening。
    if (step == 0)
    {
        me.dir() + "/audio/stereo_fx_04.wav" => air.read;
        0.80 => air.rate;
        0.10 => air.gain;
    }
    if (step == 176)
    {
        me.dir() + "/audio/stereo_fx_03.wav" => air.read;
        0.88 => air.rate;
        0.08 => air.gain;
    }
    if (step >= 224)
    {
        0.08 * (248 - step) / 24.0 => air.gain;
    }

    // Unstable bass drum before the stable beat begins.
    if ((step == 0) || (step == 9) || (step == 18) || (step == 29))
    {
        0 => deepKick.pos;
    }

    // Stable beat.
    if ((step >= 32) && (step < 224) && (place % 4 == 0))
    {
        0 => deepKick.pos;
    }

    // Small unstable details.
    if ((step >= 96) && (step < 208) && (bar % 2 == 1) && (place == 14))
    {
        0 => lightKick.pos;
    }
    if ((step >= 160) && (step < 208) && (bar % 4 == 2) && (place == 7))
    {
        0 => lightKick.pos;
    }

    // Regular snare.
    if ((step >= 64) && (step < 208) &&
        ((place == 4) || (place == 12)))
    {
        0 => snare.pos;
    }

    // Main off-beat hats.
    if ((step >= 48) && (step < 216) &&
        ((place == 2) || (place == 6) ||
         (place == 10) || (place == 14)))
    {
        0 => hat.pos;
    }

    // Every second bar gets four extra quiet hats near the end.
    if ((step >= 160) && (step < 208) && (bar % 2 == 1) &&
        ((place == 3) || (place == 7) ||
         (place == 11) || (place == 15)))
    {
        0 => hat.pos;
    }

    // The pad enters.
    if (step == 64)
    {
        Std.mtof(50) => padLow.freq;
        Std.mtof(57) => padMid.freq;
        Std.mtof(62) => padHigh.freq;
    }
    if (step == 144)
    {
        Std.mtof(48) => padLow.freq;
        Std.mtof(55) => padMid.freq;
        Std.mtof(60) => padHigh.freq;
    }

    if ((step >= 64) && (step < 80))
        0.055 * (step - 64) / 16.0 => padBus.gain;
    if ((step >= 80) && (step < 200))
        0.055 => padBus.gain;
    if ((step >= 200) && (step < 224))
        0.055 * (224 - step) / 24.0 => padBus.gain;
    if (step >= 224)
        0.0 => padBus.gain;

    // A small four-note loop. 
    if ((step >= 96) && (step < 216) &&
        ((place == 2) || (place == 6) ||
         (place == 10) || (place == 14)))
    {
        if (!((bar % 4 == 3) && (place == 10)))
        {
            Std.mtof(leadNotes[leadNote % leadNotes.cap()]) => lead.freq;
            0.065 => leadBus.gain;
            leadNote++;
        }
    }

    // room for the pad and drums.
    if ((place == 0) || (place == 4) ||
        (place == 8) || (place == 12))
    {
        0.0 => leadBus.gain;
    }

    stepLength => now;
}

