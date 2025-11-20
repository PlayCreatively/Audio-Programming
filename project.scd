(
SynthDef(\subSynth, { | baseFreq = 220 |
	var opCount = 6;

	// Array arguments are defined here using NamedControl (.kr)
	// This allows us to use code like 0!36 to generate the defaults
	var opWiringMatrix = \opWiringMatrix.kr(0!(opCount*opCount)); //row = out, col = in
	// the wiring matrix also includes the amplitude of the input
	var opEnvs     = \opEnvs.kr(1!opCount);
	var opRatios   = \opRatios.kr(1!opCount);
	var opOutMixer = \opOutMixer.kr(1!opCount);

	// one sample old operator input bank
	var opCtrlOutBank = LocalIn.ar(opCount);

	var indexOpWiringMatrix = { |r, c|
		var i = (r * opCount) + c;

		opWiringMatrix[i]
	};


	var getOpInput = {|op_i|
		var sum = 0;
		opCount.do{|op_o|
			var in = indexOpWiringMatrix.(op_i, op_o);
			sum = sum + (in * opCtrlOutBank[op_o]);
		};
		sum
	};

	var getOpOutMixerSum = {
		var sum = 0;
			opCount.do{|i|
				sum = sum +	opOutMixer[i]
			};
		sum
	};

	// reusable operator function
    var makeOp = { |baseFreq, env, ratio, in|
		SinOsc.ar(
			(baseFreq * ratio), phase: in
			) * env
    };

	var newOpCtrlOutBank = Array.newClear(opCount);
	var opOut = Array.newClear(opCount);

	var mixerUnitSum = getOpOutMixerSum.();

	opCount.do{|i|
		var opInput = getOpInput.(i);
		var op = makeOp.(baseFreq, opEnvs[i], opRatios[i], opInput);
		newOpCtrlOutBank[i] = op;
		opOut[i] = op * opOutMixer[i];
	};

	opOut =	if(mixerUnitSum != 0, {Mix(opOut) /  mixerUnitSum}, {0}); // normalize the output

	LocalOut.ar(newOpCtrlOutBank);

	Out.ar(0, opOut !2);


}).add;
)


(
var wiringMatrix =
[
	0,0,0,0,0,0,
	1,0,0,0,0,0,
	0,0,0,0,0,0,
	0,0,0,0,0,0,
	0,0,0,0,0,0,
	0,0,0,0,0,0,
];

var outMix = [0,1,0,0,0,0];
var ratios = [2,2,0,0,0,0];

~synth = Synth.new("subSynth", [\baseFreq, 280, \opOutMixer, outMix, \opWiringMatrix, wiringMatrix, \opRatios, ratios]);

w = Window("control", Rect(100, 100, 300, 260)).front;

~text = StaticText(w, Rect(10, 80, 80, 200));
~text.string = wiringMatrix;

~slider = Slider(w, Rect(10, 10, 280, 20));
~slider.action = { |sl|
	wiringMatrix  =
[
	0,0,0,0,0,0,
	sl.value,0,0,0,0,0,
	0,0,0,0,0,0,
	0,0,0,0,0,0,
	0,0,0,0,0,0,
	0,0,0,0,0,0,
];
    ~synth.set(\opWiringMatrix, wiringMatrix);
	~text.string = wiringMatrix;
};

~slider2 = Slider(w, Rect(10, 30, 280, 20));
~slider2.action = { |sl|
	ratios  = [1,sl.value,0,0,0,0];
    ~synth.set(\opRatios, ratios);
};
)

(
SynthDef(\DX7, { |baseFreq = 220|
	var synthCount = 32;

	var subSynths = Synth.new("subSynth", [\freq, 220]) !synthCount;
}).add;
)