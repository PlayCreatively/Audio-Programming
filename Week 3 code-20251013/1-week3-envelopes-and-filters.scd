// Audio Programming
// Workshop 3
// Monday 13th October 2025

// Here's the code from last week,
// updated with an envelope generator
// controlling the amplitude of both oscillators.

(
{
	var speed = 4;
	var pulse = Impulse.kr(speed);
	var env = Env.perc(0.01, 1/speed);
	var envlevel = EnvGen.kr(env, pulse);
	var freq = MouseX.kr(50, 200, 1);
	var osc1 = Pulse.ar(freq, 0.5, 0.5*envlevel) !2;
	var osc2 = Saw.ar(freq*1.501, 0.5*envlevel) !2;
	var cutoff = MouseY.kr(200, 12000, 1);

	LPF.ar(osc1 + osc2, cutoff)

}.play
)

// A version with an envelope generator
// controlling the cutoff frequency of
// a resonant low-pass filter
(
{
	var speed = 4;
	var pulse = Impulse.kr(speed);
	var env = Env.perc(0.08, 1/speed);
	var cutoff = MouseY.kr(200, 12000, 1);
	var envlevel = EnvGen.kr(env, pulse, cutoff);
	var freq = MouseX.kr(50, 200, 1);
	var osc1 = Pulse.ar(freq, 0.5, 0.5) !2;
	var osc2 = Saw.ar(freq*1.501, 0.5) !2;

	RLPF.ar(osc1 + osc2, envlevel, 0.3)

}.play
)


// A classic 808 kick, made from a single 60Hz sine wave
(
{

	var sound = SinOsc.ar(60);
	var env = EnvGen.kr(Env.perc(0.001, 0.8), Impulse.kr(2));

	sound * env
}.play
)


// Using triggered random numbers and MIDI-to-cylcles-per-second
// (cps = Hz) to make a nasty melody...
(
{
	var speed = 2;
	var pulse = Impulse.kr(speed);
	var env = Env.perc(0.08, 1/speed);
	var envlevel = EnvGen.kr(env, pulse, 2000, 60);
	var freq = TRand.kr(30, 42, pulse).midicps;
	var osc1 = Pulse.ar(freq, 0.5, 0.5) !2;
	var osc2 = Saw.ar(freq*1.501, 0.5) !2;
	var cutoff = MouseY.kr(200, 12000, 1);

	RLPF.ar(osc1 + osc2, envlevel, 0.6)

}.play
)

// A slightly different version in response to a question
// about arpeggiators; this selects a note at random from
// the 'notes' array
(
{
	var speed = 4;
	var pulse = Impulse.kr(speed);
	var env = Env.perc(0.08, 1/speed);
	var envlevel = EnvGen.kr(env, pulse, 2000, 60);
	var notes = [40, 42, 43];
	var freq = TChoose.kr(pulse, notes.midicps);
	var osc1 = Pulse.ar(freq, 0.5, 0.5) !2;
	var osc2 = Saw.ar(freq*1.501, 0.5) !2;
	var cutoff = MouseY.kr(200, 12000, 1);

	RLPF.ar(osc1 + osc2, envlevel, 0.6)

}.play
)


// A quick wind emulator
(
{
	var freq = LFNoise1.ar(0.2, 150, 200);
	RLPF.ar(PinkNoise.ar, freq, 0.1)
}.play
)