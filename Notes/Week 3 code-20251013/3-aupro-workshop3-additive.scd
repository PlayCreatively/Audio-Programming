// Audio Programming
// Workshop 3
// Monday 13th October 2025
// Additive synthesis
// matt.bellingham@port.ac.uk

// Additive synthesis

// Harmonic series
(
{

    var fundamental = 100;
	var harmonic = MouseX.kr(1, 8).round(1);
    var pitch = fundamental*harmonic;

    SinOsc.ar(pitch.poll, 0, 0.5) ! 2
}.scope
)


// See the first eight harmonics
// We can only hear the first two
(
{
    SinOsc.ar([100, 200, 300, 400, 500, 600, 700, 800], 0, 0.5)
}.scope
)


// Playing three frequencies at the same time
(
{
    var a = SinOsc.ar(200, 0, 0.25);
    var b = SinOsc.ar(300, 0, 0.25);
    var c = SinOsc.ar(400, 0, 0.25);

    a + b + c

}.scope
)


// Using Mix.ar to mix them together
// Also note that the amplitude of each frequency is also scaled
(
{
    var freqs = [100, 200, 300, 400, 500, 600, 700, 800];
    var amps = [1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8].normalizeSum;
    var sig = SinOsc.ar(freqs, 0, amps);

    Mix.ar(sig)

}.scope
)

// Another way - a simple sawtooth with four harmonics
(
{

    var fund = 100;
    var sine1 = SinOsc.ar(fund*1, 0, 0.5 * 1/1);
    var sine2 = SinOsc.ar(fund*2, 0, 0.5 * 1/2);
    var sine3 = SinOsc.ar(fund*3, 0, 0.5 * 1/3);
    var sine4 = SinOsc.ar(fund*4, 0, 0.5 * 1/4);

    (sine1 + sine2 + sine3 + sine4) ! 2

}.scope
)

// Sawtooth using an array
(
{
    var counter = Array.fill(10, {arg counter; counter});
    var partial = counter + 1;
    var sig = SinOsc.ar(partial*100, 0, 0.5*1/partial);

    Mix.ar(sig)

}.scope
)

// Square using an array
(
{
    var counter = Array.fill(8, {arg counter; counter*2});
    var partial = counter + 1;
    var sig = SinOsc.ar(partial*100, 0, 0.5*1/partial);

    Mix.ar(sig)

}.scope
)

// Frequencies from the harmonic series
// Random amplitudes, set when the synth is run
(
{
    var counter = Array.fill(8, {arg counter; counter});
    var partial = counter + 1;
    var amps = Array.fill(8, {arg counter; rrand(0.1, 1)});
    var sig = SinOsc.ar(partial*100, 0, amps.normalizeSum);

    Mix.ar(sig)

}.play
)

// Generative colour changes
(
{

    var pulse = Impulse.kr(4);
    var pitch = TRand.kr(36, 48, pulse).midicps;
    var pitches = [pitch*1, pitch*2, pitch*3, pitch*4, pitch*5, pitch*6, pitch*7, pitch*8];
    var amplitudes = [TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse), TRand.kr(0.1, 0.9, pulse)].normalizeSum;
    var sig = SinOsc.ar(pitches, 0, amplitudes);

    Mix.ar(sig) ! 2
}.play
)

// Individual EGs per partial
(
{
    var pulse = Impulse.kr(1);
    var fund = TRand.kr(36, 48, pulse).midicps;
    var freqs = [fund*1, fund*2, fund*3, fund*4, fund*5, fund*6, fund*7, fund*8];
    var env1 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env2 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env3 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env4 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env5 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env6 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env7 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var env8 = EnvGen.kr(Env.perc(TRand.kr(0.001, 0.5, pulse), TRand.kr(0.1, 1, pulse)), pulse, 0.5);
    var amps = [1*env1, 1/2*env2, 1/3*env3, 1/4*env4, 1/5*env5, 1/6*env6, 1/7*env7, 1/8*env8];
    var sig = SinOsc.ar(freqs, 0, amps);

    Mix.ar(sig) ! 2

}.scope
)

(
{
	var saw = Saw.ar(200);
	RLPF.ar(saw, MouseX.kr(20, 2000, 1), MouseY.kr(0,1))
}.play
)

// Random frequencies at random amplitudes
(
{
    var counter = Array.fill(8, {arg counter; exprand(200, 600)});
    var partial = counter + 1;
    var amps = Array.fill(8, {arg counter; rrand(0.1, 1)});
    var sig = SinOsc.ar(partial, 0, amps.normalizeSum*0.2);

    Mix.ar(sig) !2

}.play
)

// Bell Array
(
{
var trigger;
trigger = Dust.kr(3/7);
Pan2.ar(
    Mix.ar(
        {
        SinOsc.ar(rrand(50, 1000)) *
        EnvGen.kr(
            Env.perc(0, rrand(0.2, 3.0)),
            trigger,
            1.0.rand
            )
        }.dup(12)
    )*0.03,
    1.0.rand2
)
}.play
)

// Several bells
(
{
var bells, totalBells, totalHarm;
totalBells = 5;
totalHarm = 12;

bells = {
    var trigger;
    trigger = Dust.kr(2/7);
    Pan2.ar(
        Mix.ar(

                {
                SinOsc.ar(2000.linrand + 50) *
                EnvGen.kr(
                    Env.adsr(0, 0, 1.0, rrand(0.3, 2.0)),
                    trigger,
                    1.0.rand
                    )
            }.dup(totalHarm)
        )*0.03,
        1.0.rand2
    )
    }.dup(totalBells);
Mix.ar(bells)
}.play
)