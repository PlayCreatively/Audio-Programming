// Audio Programming week 6
// AM, RM, and FM
// matt.bellingham@port.ac.uk

// Frequency Modulation

// A slow modulation (under 30Hz-ish) is audible
// as vibrato
(
{
	var modulator = SinOsc.ar(10, 0, 100);
	var carrier = SinOsc.ar(400 + modulator, 0, 0.5);

	carrier ! 2

}.play
)


// A faster modulation frequency results in FM where we
// have multiple sidebands.
(
{
	var carrierfreq = 200;
	var modratio = MouseX.kr(0.5, 8).round(0.5).poll;
	var index = MouseY.kr(10, 1000);
	var modulator = SinOsc.ar(carrierfreq*modratio, 0, index);
	var carrier = SinOsc.ar(carrierfreq + modulator, 0, 0.5);

	carrier ! 2

}.play
)


// Make a simple sine wave with an AD envelope
(
{
	SinOsc.ar(400, 0, EnvGen.kr(Env.perc(0.01, 0.5), Impulse.kr(1)))
}.play
)


// Adding an envelope to the modulator
(
{
	var pulse = Impulse.kr(1);
	var cp = 100; // carrier frequency
	var mp = 200; // modulator frequency
	var envlevel = 2000; // index
	var env = EnvGen.kr(Env.perc(0.01, 0.8, envlevel), pulse);
	var mod = SinOsc.ar(mp) * env;

	SinOsc.ar(cp+mod, 0, 0.5) ! 2

}.play
)


// MouseY controlling index
// MouseX controlling the ratio between carrier and modulator frequencies
(
{
	var pulse = Impulse.kr(2);
	var cp = TRand.kr(40, 52, pulse).midicps;
	var mp = cp*MouseX.kr(0.5, 8).round(0.5);
	var env = EnvGen.kr(Env.perc(0.01, 0.5, MouseY.kr(20, 5000)), pulse);
	var mod = SinOsc.ar(mp) * env;

	SinOsc.ar(cp+mod, 0, 0.5) ! 2

}.play
)


// A creative example with two carriers (left and right),
// each being modulated by a separate modulator
(
{
	var mod = SinOsc.ar(100, 0, EnvGen.kr(Env.perc(0.01, 0.2, Line.kr(1,8, 10)), Impulse.kr(4)));
	var mod2 = SinOsc.ar(200, 0, EnvGen.kr(Env.perc(0.01, 0.2, Line.kr(1,8, 10)), Impulse.kr(3)));

	SinOsc.ar([400 * mod, 200*mod2], 0, 0.5) ! 2

}.play
)

// Multi FM, a la Aphex Twin
(
{
	var modfreq = MouseX.kr(1, 200, 1);
	var index = MouseY.kr(1, 1000);

	var modulator = SinOsc.ar(modfreq, 0, index);
	var carrier1  = SinOsc.ar(400 + modulator, 0, 0.5);
	var carrier2 = SinOsc.ar(800 + modulator, 0, 0.5);

	carrier1 + carrier2 ! 2
}.play
)