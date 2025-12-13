// Recap - playing back audio files
// First, load them into the buffer
(
v = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "vocal.wav");
g = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "guitar.wav");
)

// Next, use PlayBuf to play them
(
{
	PlayBuf.ar(2, g.bufnum, BufRateScale.kr(g.bufnum), loop:1);
}.play
)




// A simple synth for us to experiment with
(
{
	SinOsc.ar(200, 0, 0.5) !2
}.play
)

(

SynthDef(\annoying, {
	arg freq = 200, vol = 0.5;
	var sound = SinOsc.ar(freq, 0, vol) !2;

	Out.ar(0, sound)
}).add

)

a = Synth(\annoying, [freq: 100, vol:0.1]);
a.set(\freq,600)
a.free

(
{
	var audi = (SoundIn.ar(0) + 0.5);
	SinOsc.ar(400) * audi
}.scope
)

(
{
	var modulator = SinOsc.ar(MouseX.kr(100, 3000, 1), 0, 0.5, 0.5);
	var carrier = SinOsc.ar(400) * modulator;

	carrier !2
}.scope
)

( // ring mod
{
	var carrierFreq = MouseX.kr(10, 1000, 1);
	var mod = PlayBuf.ar(2, v.bufnum, BufRateScale.kr(g.bufnum), loop:1);
	var carrier = SinOsc.ar(carrierFreq) * mod;

	carrier !2
}.scope
)

(
{
	var mod = SinOsc.ar(100, 0, 100);
	var carrier = SinOsc.ar(100 + mod);

	carrier !2
}.scope
)