// Filters to experiment with:
HPF
LPF
BPF
BRF

// We can also use resonant filters, such as...
RLPF
RHPF

//////////////////////////

// Envelopes

// Some simple envelopes...

// A percussion envelope, which is an attack-release
// or 'AR' envelope
Env.perc(0.5, 1).plot;

// Try a different curve...
Env.perc(0.5, 1, 1, \sine).plot;
Env.perc(0.5, 1, 1, \welch).plot;
Env.perc(0.5, 1, 1, \lin).plot;


// An attach-sustain-release envelope,
// otherwise known as an ASR envelope
Env.linen(0.5, 1, 2).plot;

// Try differing levels and curves
Env.linen(0.5, 1, 2, 0.8, \sine).plot;
Env.linen(0.5, 1, 2, 0.6, \welch).plot;


// Envelopes need to be triggered - for now we will
// use the mouse button or a regular pulse

MouseButton // Look at the help file

Impulse // look at the help file

(
{
	var freq = 100;
	var vol = 0.5;
	var detune = 0.99;
	var trigger = Impulse.kr(1/2);
	var env = EnvGen.kr(Env.perc(0.01, 0.8), trigger);

	Saw.ar(
		[freq, freq*detune],
		vol * env;
	)
}.play
)

// Number selection
100.rand // 100, do this; pick a number between 0 and yourself

{100.rand}.dup(50) // random picking function, do this; repeat 50 times

[1.001, 45.827, 187.18].round(0.1) // collection of items; round to 0.1

rrand(20, 40); // pick a number between 20 and 40
rrand(0, 1); // pick an integer, or...
rrand(0.0, 1.0); // pick a fractional number
rrand(0.0, 1.0).round(0.1); // pick a number then round to one decimal place


// Try randomising values in the above example


// We can create a line from a start value to an end value
Line
XLine

// What is this example doing?
(
{

	var pulse = Impulse.kr(Line.kr(1, 10, 20));
	var env = EnvGen.kr(Env.perc(0.01, 0.5), pulse, 2000, 200);

	RLPF.ar(PinkNoise.ar([0.5, 0.5]), env, Line.kr(0.2, 0.02, 20))
}.play
)


// What if we want a new random value each time
// the trigger fires? We can use...

TRand
TExpRand

// Here's an example...
(
{
	var trigger = Impulse.kr(2);
	var release = TRand.kr(0.2, 1, trigger);
	var freq = TExpRand.kr(100, 600, trigger).round(100);
	var vol = TRand.kr(0.2, 0.6, trigger);
	var detune = 0.99;
	var env = EnvGen.kr(Env.perc(0.01, release), trigger);

	Saw.ar(
		[freq, freq*detune],
		vol * env;
	)
}.play
)

// As a SynthDef...
(
SynthDef(\test, {
    var freq = 100;
    var vol = 0.5;
    var detune = 0.99;
    var trigger = Impulse.kr(1/2);
    var env = EnvGen.kr(Env.perc(0.01, 0.8), trigger);
    var sig = Saw.ar([freq, freq * detune]) * vol * env;

	Out.ar(0, sig);
}).add;
)

Synth(\test);