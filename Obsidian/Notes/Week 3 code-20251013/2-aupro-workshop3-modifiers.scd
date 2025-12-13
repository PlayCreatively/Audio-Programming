// Audio Programming
// Workshop 3
// Monday 13th October 2025

(
{
	var freq = 100;
	var width = 0.5;
	var cutoff = 1000;
	var q = 0.5;
	var amp = 0.5;
	var synth = Pulse.ar([freq, freq*0.99], width, amp);

	RLPF.ar(synth, cutoff, q);

}.play
)


// Add an envelope generator for the filter cutoff:
(
{
	var freq = 100;
	var width = 0.5;
	var gate = Impulse.kr(1);
	var cutoff = EnvGen.kr(Env.perc(0.01, 0.5), gate, 2000, 200);
	var q = 0.2;
	var amp = 0.5;
	var synth = Pulse.ar([freq, freq*0.99], width, amp);

	RLPF.ar(synth, cutoff, q);

}.play
)


// Add an LFO to the frequency:
(
{
	var freq = SinOsc.kr(5, 0, 5, 100);
	var width = 0.5;
	var gate = Impulse.kr(1);
	var cutoff = EnvGen.kr(Env.perc(0.01, 0.5), gate, 2000, 200);
	var q = 0.2;
	var amp = 0.5;
	var synth = Pulse.ar([freq, freq*0.99], width, amp);

	RLPF.ar(synth, cutoff, q);

}.play
)


// Or, use an LFO to modulate the pulse width
// AKA pulse width modulation, or PWM
(
{
	var freq = 100;
	var width = SinOsc.kr(1, 0, 0.4, 0.5);
	var gate = Impulse.kr(1);
	var cutoff = EnvGen.kr(Env.perc(0.01, 0.5), gate, 2000, 200);
	var q = 0.2;
	var amp = 0.5;
	var synth = Pulse.ar([freq, freq*0.99], width, amp);

	RLPF.ar(synth, cutoff, q);

}.play
)

// Here is a wind emulator:
(
{
	var noise = PinkNoise.ar(1);
	var modulator = LFNoise1.kr(1, 50, 150);

	RLPF.ar(noise, modulator, 0.3) !2
}.play
)

// Finally, here are some more examples
// of frequency modulation:

(
{ //Saw
	var lfo = LFSaw.ar(freq: 2, mul: -100, add: 600);

	SinOsc.ar(lfo, mul: 0.5) !2
}.play
)

(
{ //Noise (computer)
	var lfo = LFNoise0.ar(freq: [28, 27], mul: 1000, add: 2000);

	SinOsc.ar(lfo, mul: 0.5) !2
}.play
)

(
{ //Noise (manic birds)
	var lfo = LFNoise1.ar(freq: [28, 27], mul: 400, add: 2000);

	SinOsc.ar(lfo, mul: 0.5)
}.play
)