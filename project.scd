(
s.options.blockSize = 1; // Default is 64
s.reboot;
)

(
SynthDef(\subSynth, { | baseFreq = 220, gate = 1 |
	var opCount = 6;

    // --- INPUTS ---
	// 6x6 Matrix (Contains the Volumes/ModIndices calculated in Python)
	var opWiringMatrix = \opWiringMatrix.kr(0!(opCount*opCount));
	var opOutMixer     = \opOutMixer.kr(0!opCount);
	var opRatios       = \opRatios.kr(1!opCount);

    // ENVELOPES: Flattened arrays (6 ops * 4 stages = 24 values)
    // [Op1_L1, Op1_L2... Op1_L4, Op2_L1...]
    var opEnvLevels    = \opEnvLevels.kr(0!(opCount*4));
    var opEnvTimes     = \opEnvTimes.kr(1!(opCount*4));

	var opCtrlOutBank = LocalIn.ar(opCount);

    // --- HELPER: Create Envelope for Operator i ---
    var makeOpEnv = { |opIndex|
    var start = opIndex * 4;
    // Slice the flat arrays
    var levels = opEnvLevels[start .. start+3]; // [L1, L2, L3, L4]
    var times  = opEnvTimes[start .. start+3];  // [R1, R2, R3, R4]

    // DX7 Topology:
    // Start at L4 (usually 0, but can be non-zero).
    // Time1 -> L1
    // Time2 -> L2
    // Time3 -> L3 (SUSTAIN POINT)
    // Time4 -> L4 (Release Phase)

    EnvGen.ar(
		Env(
            [levels[3], levels[0], levels[1], levels[2], levels[3]], // Points
            [times[0], times[1], times[2], times[3]], // Durations
            -4, // Curve type (DX7 is roughly exp/linear mix, exp sounds better)
            3 // Release Node: Index 3 corresponds to 'levels[2]' (L3) in the levels array above
            ),
            gate
        )
    };

	var indexOpWiringMatrix = { |r, c|
		opWiringMatrix[(r * opCount) + c];
	};

	var getOpInput = {|op_i|
		var sum = 0;
		opCount.do{|op_o|
            // The matrix value here ALREADY includes the Operator's Output Level (Radians)
            // calculated in Python.
			var gain = indexOpWiringMatrix.(op_i, op_o);
			sum = sum + (gain * opCtrlOutBank[op_o]);
		};
		sum
	};

	var getOpOutMixerSum = {
		var sum = 0;
		opCount.do{|i| sum = sum + opOutMixer[i] };
		sum
	};

    // --- OSCILLATOR GENERATION ---
    var makeOp = { |baseFreq, env, ratio, in|
		// Note: 'env' is the time-varying ADSR (0.0 to 1.0)
        // 'in' is the Phase Modulation from the matrix (0.0 to 12.57)
		SinOsc.ar((baseFreq * ratio), phase: in) * env
    };

	var newOpCtrlOutBank = Array.newClear(opCount);
	var opOut = Array.newClear(opCount);
	var mixerUnitSum = getOpOutMixerSum.();

	opCount.do{|i|
		var opInput = getOpInput.(i);
        // Generate the unique envelope for this operator
        var adsr = makeOpEnv.(i);

		var op = makeOp.(baseFreq, adsr, opRatios[i], opInput);
		newOpCtrlOutBank[i] = op;
		opOut[i] = op * opOutMixer[i];
	};

    // Normalize output
	opOut =	if(mixerUnitSum != 0, {Mix(opOut) /  mixerUnitSum}, {0});

	LocalOut.ar(newOpCtrlOutBank);

	Out.ar(0, opOut !2);

}).add;
)

(
// 2. Initialize Singleton
var wiringMatrix = 0!36;
var outMix = 0!6;
var ratios = 1!6;
var envLevels = 0!24;
var envTimes = 1!24;

// Create synth with gate=0 initially (silent)
~mySynth = Synth.new("subSynth", [
	\opWiringMatrix, wiringMatrix,
	\opOutMixer, outMix,
	\opRatios, ratios,
    \opEnvLevels, envLevels,
    \opEnvTimes, envTimes,
    \gate, 0
]);

// 4. NEW Listener for Gate (Note On/Off)
OSCdef(\gateListener, { |msg|
    var state = msg[1]; // 1.0 or 0.0
    ~mySynth.set(\gate, state);
    ("Gate set to: " ++ state).postln;
}, "/gate");


OSCdef(\pyListener, { |msg|
	// msg[0] is address path
	// msg[1] is "opWiringMatrix" string (we can skip if we know order)
	// format from python: ["/update_synth", "opWiringMatrix", val1..36, "opOutMixer", val1..6, ...]

	// We have to carefully pick indices because *wiring_matrix unpacked the array.
	// Structure:
	// msg[1] = "opWiringMatrix"
	// msg[2..37] = 36 floats (Matrix)
	// msg[38] = "opOutMixer"
	// msg[39..44] = 6 floats (Mixer)
	// msg[45] = "opRatios"
	// msg[46..51] = 6 floats (Ratios)
	// msg[52] = "opEnvs"
	// msg[53..58] = 6 floats (Envs/Levels)

	var matrix = msg[2..37];
	var mixer  = msg[39..44];
	var ratios = msg[46..51];
	var envLevels = msg[53..76];
    var envTimes = msg[79..102];

	~mySynth.set(
		\opWiringMatrix, matrix,
		\opOutMixer, mixer,
		\opRatios, ratios,
		\opEnvLevels, envLevels,
        \opEnvTimes, envTimes
	);

	matrix[0..5].postln;
	matrix[6..11].postln;
    matrix[12..17].postln;
    matrix[18..23].postln;
    matrix[24..29].postln;
    matrix[30..35].postln;
	"".postln;

	envLevels.postln;
	envTimes.postln;

}, "/update_synth");
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