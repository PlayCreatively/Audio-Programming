( // SH-101
{
	var freq = MouseX.kr(200, 1000, 1);
	var width = 0.5;
	// percussion envelope
	var env = Env.perc(0.05, 1);
	var pulse = Impulse.kr(1);
	var envLevel = EnvGen.kr(env, pulse);

	// 0.5 because adding two oscillators sum up to 1; otherwise it would overload and clip
	var osc1 = Pulse.ar(freq, width, 0.2);
	var osc2 = Saw.ar(freq * 0.99, 0.3);
	var osc3 = Pulse.ar(freq/1.99, 0.5, 0.5);

	var cutoff = MouseY.kr(200, 12000, 1);
	var res = 0.4;

	RLPF.ar(osc1 + osc2 + osc3, cutoff, res, envLevel)!2
}.scope
)

(
{
	var freq = LFSaw.kr(2, 0, -100, 600);
    var width = 0.5;
    var cutoff = 1000;
    var q = 0.5;
    var amp = 0.5;
    var synth = Pulse.ar([freq, freq*0.99], width, amp);

    RLPF.ar(synth, cutoff, q);

}.play
)


(
{
    var freq = 100;
    var width = 0.5;
	var gate = Impulse.kr(1);
	var cutoff = EnvGen.kr(Env.perc(0.03, 0.5), gate, 4000, 200);
    var q = 0.5;
    var amp = 0.5;
    var synth = Pulse.ar([freq, freq*0.99], width, amp);

    RLPF.ar(synth, cutoff, q);

}.play
)


(
{
	var freq = SinOsc.kr(5, 0, 5, 100);
	var width = SinOsc.kr(0.5).range(0.1, 0.5);
	var gate = Impulse.kr(1);
	var cutoff = EnvGen.kr(Env.perc(0.03, 1), gate, 4000, 200);
    var q = 0.9;
    var amp = 0.5;
    var synth = Pulse.ar([freq, freq*0.99], width, amp);

    RLPF.ar(synth, cutoff, q);

}.play
)