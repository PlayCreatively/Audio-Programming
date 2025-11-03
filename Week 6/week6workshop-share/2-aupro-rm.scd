// Audio Programming week 6
// AM, RM, and FM
// matt.bellingham@port.ac.uk

// Ring Modulation

// This is the same as one of the AM examples, but uses
// a bipolar rather than unipolar modulator
(
{
	var modfreq = 100;
	var carrierfreq = 400;
	var modulator = SinOsc.ar(modfreq, 0, 1);
	var carrier = SinOsc.ar(carrierfreq, 0, modulator);

	carrier !2
}.scope
)


// RM often uses an audio input as the modulator
// which creates other-worldly sounds as the original
// frequency is lost, leaving only the sum and the difference

// NOTE - either use headphones or mute your playback
// and record your voice, then listen to the recording
(
{
	var carrierfreq = 400; // change this, or make it variable
	var modulator = SoundIn.ar;
	var carrier = SinOsc.ar(carrierfreq, 0, modulator);

	carrier !2
}.scope
)


// Some examples using audio files - more on audio
// playback next week

v = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "vocal.wav");
g = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "guitar.wav");

(
{
	var carrier = SinOsc.ar(800);
	var modulator = PlayBuf.ar(2, v.bufnum, BufRateScale.kr(v.bufnum), loop:1) ! 2;

	carrier * modulator

}.scope
)


(
{
	var carrier = SinOsc.ar(MouseX.kr(100, 1000, 1));
	var modulator = PlayBuf.ar(2, g.bufnum, BufRateScale.kr(g.bufnum), loop:1) ! 2;

	carrier * modulator

}.scope
)
