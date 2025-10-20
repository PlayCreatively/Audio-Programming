// Boot the server
// The global variable 's' is always used for the server
s.boot;

// Add an audio file to the buffer 's', and assign it the global varable 'p'
// For now, copy the path to a PCM audio file and add it to your code:
p = Buffer.read(s, "/Users/mattb/Desktop/amen.wav");

~rootDir = thisProcess.nowExecutingPath.dirname +/+ "Audio files/";

~adultFemSpeech = "vocal.wav";

p = Buffer.read(s, ~rootDir +/+ ~adultFemSpeech);


// Let's play it
(
{
	PlayBuf.ar(
		2, // number of channels - in this case, stereo
		p.bufnum, // which buffer to play
		BufRateScale.kr(p.bufnum), // play at the recorded rate
		loop: 1 // loop the file
	)
}.play
)

// Try adding some real-time controls to parameters
(
{
	var rate = 1;

	PlayBuf.ar(
		2,
		p.bufnum,
		BufRateScale.kr(p.bufnum)*rate,
		loop: 1
	)
}.play
)


// Tape-stop example, with a sustained press on the mouse button to play
(
SynthDef(\sound, { arg attack, release;

var env = EnvGen.kr(Env.adsr(attack, 0, 1, release), gate: MouseButton.kr(0, 1, 0));
var out = PlayBuf.ar(2, p.bufnum, BufRateScale.kr(p.bufnum) * env, loop:1);

Out.ar(0, out)
}).send(s)
)

a = Synth(\sound, [\attack, 0.5, \release, 0.8]);
a.set(\release, 0.5);
a.set(\attack, 0.2, \release, 0.2);
a.set(\attack, 0.2, \release, 10);
a.free;


// nasty am!
(
{

var amp = PlayBuf.ar(2, p.bufnum, BufRateScale.kr(p.bufnum)*MouseX.kr(0.001, 1), loop:1);

SinOsc.ar(MouseY.kr(100, 1000, 1), 0, amp)
}.play;
)

//////////////

// nasty fm!
(
{
var modder = PlayBuf.ar(2, p.bufnum, BufRateScale.kr(p.bufnum)*MouseX.kr(0.001, 1, 1), loop:1);

SinOsc.ar(MouseY.kr(1000, 10000, 1) * modder, 0, 0.5)
}.play;
)

////////////////////

// buffer glitch tool, written on one line

({var trig = Impulse.kr(MouseY.kr(0.5,200,1)); PlayBuf.ar(2,p.bufnum,BufRateScale.kr(p.bufnum),trig,MouseX.kr(0,BufFrames.kr(p.bufnum)),1)}.play)

// The same glitch tool, laid out across multiple lines
// Much easier to read and work on!
(
{
	var trig = Impulse.kr(MouseY.kr(0.5,200,1));

	PlayBuf.ar(
		2,
		p.bufnum,
		BufRateScale.kr(p.bufnum),
		trig,
		MouseX.kr(
			0,
			BufFrames.kr(p.bufnum)
		),
		1
	)
}.play
)

// And again, but this time with comments
(
{
	var trig = Impulse.kr(MouseY.kr(0.5,200,1));

	PlayBuf.ar(
		2, // stereo
		p.bufnum, // play the same in buffer 'p'
		BufRateScale.kr(p.bufnum), // sample rate
		trig, // how frequently to retrigger playback
		MouseX.kr(
			0,
			BufFrames.kr(p.bufnum) // where to start playback
		),
		1 // loop playback
	)
}.play
)

////////////

// Local file path
// We can point to the local file path like this:

p = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "amen.wav");

////////////


(
SynthDef(\sampler, { arg rate = 1;
	Out.ar(0, PlayBuf.ar(2, p.bufnum, BufRateScale.kr(p.bufnum)*rate, loop: 1))
}).add
)

(
var w, slider1, spec1;
w = Window("I am a window", Rect(200, 200, 350, 140));

~playing = Synth(\sampler);

spec1 = ControlSpec(-1, 2, \lin, 0, 1);
slider1 = EZSlider(w, Rect(0, 20, 300, 50),
	label: "Rate", controlSpec: spec1, action: {~playing.set(\rate, slider1.value)}, initVal: 1);

w.front;
w.onClose = {~playing.free};
)


(
var w, slider1, spec1;
w = Window("I am a window", Rect(200, 200, 350, 140));

~playing = Synth(\sampler);

spec1 = ControlSpec(-1, 2, \lin, 0, 1);
slider1 = EZSlider(w, Rect(0, 20, 300, 50),
	label: "Rate", controlSpec: spec1, action: {~playing.set(\rate, slider1.value)}, initVal: 1);

Button(w, Rect(60, 80, 100, 30))
    .states_([
        ["Random rate", Color.white,  Color.red],
    ])
.mouseDownAction_({
	var rand = rrand(0.8, 1.2);
	slider1.valueAction_(rand);
            });

w.front;
w.onClose = {~playing.free};
)


(
var w, slider1, spec1;
w = Window("I am a window", Rect(200, 200, 350, 140));

spec1 = ControlSpec(-1, 2, \lin, 0, 1);
slider1 = EZSlider(w, Rect(0, 20, 300, 50),
	label: "Rate", controlSpec: spec1, action: {~playing.set(\rate, slider1.value)}, initVal: 1);

Button(w, Rect(170, 80, 100, 30))
    .states_([
        ["Random rate", Color.yellow,  Color.blue],
    ])
.mouseDownAction_({
	var rand = rrand(0.8, 1.2);
	slider1.valueAction_(rand);
            });

Button(w, Rect(60, 80, 100, 30))
        .states_([
            ["Stopped", Color.white, Color.red],
            ["Playing", Color.black, Color.green]
        ])
.action_({ arg obj;
	if(obj.value == 1)
	{
		~playing = Synth(\sampler);
		~playing.map(\rate, slider1.value);
}
	{
		~playing.free;
	}
});

w.front;
w.onClose = {~playing.free};
)