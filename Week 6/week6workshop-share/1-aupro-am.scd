// Audio Programming week 6
// From tremolo to Amplitude Modulation (AM) synthesis
// matt.bellingham@port.ac.uk

// A bipolar wave outputs both positive and negative values
{ SinOsc.ar(1/2, 0, 1, 0) }.scope;

// A unipolar wave only outputs positive values
{ SinOsc.ar(1/2, 0, 0.5, 0.5) }.scope;


// Amplitude modulation (AM) uses a unipolar wave
// to modulate the amplitude of the carrier

// Tremolo - similar to AM but uses an LFO as a modulator
(
{
	var modulator = SinOsc.ar(2, 0, 0.5, 0.5);
	var carrier = SinOsc.ar(400, 0, modulator);

	carrier !2
}.scope
)


// With live audio input
(
{
	var modulator = SinOsc.ar(2, 0, 0.5, 0.5);
	var carrier = SoundIn.ar(0, modulator);

	carrier !2
}.scope
)


// A stereo version with offset modulation on the L and R channels
(
{
	var amp = SinOsc.kr(1, 0, 0.5, 0.5);
	var amp2 = SinOsc.kr(1, 1pi, 0.5, 0.5);

	SinOsc.ar([400,0], 0, amp) + SinOsc.ar([0,401], 0, amp2)
}.scope
)

// Same, with live audio input
(
{
	var amp = SinOsc.kr(1, 0, 0.5, 0.5);
	var amp2 = SinOsc.kr(1, 1pi, 0.5, 0.5);

	SoundIn.ar(0, [amp, amp2])
}.scope
)

// Another tremolo example
(
{
	var tremolo = SinOsc.kr(4, 0, 0.5, 0.5);
	var tremolo2 = SinOsc.kr(4, 1pi, 0.5, 0.5);
	var pulse = Impulse.kr(1);
	var pitch = TRand.kr(52, 60, pulse).round(1).midicps;
	var env = EnvGen.kr(Env.perc(0.01, 2), pulse);

	SinOsc.ar(pitch, 0, [tremolo*env, tremolo2*env])
}.scope
)


// Amplitude modulation
// Carrier frequency of 400Hz
// Sum is 500Hz (400+100)
// Difference is 300Hz (400-100)
(
{
	var modfreq = 100;
	var carrierfreq = 400;
	var modulator = SinOsc.ar(modfreq, 0, 0.5, 0.5);
	var carrier = SinOsc.ar(carrierfreq, 0, modulator);

	carrier !2
}.scope
)

// A more involved example!
// Use the mouse x plane to set the ratio
// between the carrier and modulator frequencies
(
{
	var speed = MouseY.kr(1/2, 5);
	var gate = Impulse.kr(speed);
	var note = TRand.kr(30, 50, gate).round(1);
	var carrierfreq = note.midicps;
	var ratio = MouseX.kr(1, 20).round(1).poll;
	var modfreq = carrierfreq*ratio;
	var env = EnvGen.kr(Env.perc(0.1, speed.reciprocal), gate);
	var modulator = SinOsc.ar(modfreq, 0, 0.5, 0.5);
	var carrier = SinOsc.ar(carrierfreq, 0, modulator*env);

	carrier !2
}.scope
)