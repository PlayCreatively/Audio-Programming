/*
 * DX7 Logic in SuperCollider
 *
 * This file implements the synthesis engine. It relies on OSC messages to update
 * its internal calibration data (modulation indices, matrix, envelopes) which are
 * derived from the Python parsing script.
 *
 * Architecture:
 * - \subSynth: A single DX7 voice (monophonic in this context, but the engine allows polyphony if instantiated multiple times)
 * - OSCdef(\pyListener): Listens for parsed batch data from Python.
 */

(
s.options.blockSize = 1; // Default is 64. Lower block size needed for tight feedback loops in FM.
s.reboot;
)

(
SynthDef(\subSynth, { | baseFreq = 220, gate = 1 |
	var opCount = 6;

    // --- INPUTS ---
	// 6x6 Matrix (Contains the Volumes/ModIndices calculated in Python)
	// Flattened 36-element array. Row=Dest, Col=Src.
	var opWiringMatrix = \opWiringMatrix.kr(0!(opCount*opCount));
	// 1 if Operator goes to audio out, 0 otherwise
	var opOutMixer     = \opOutMixer.kr(0!opCount);
	// Frequency ratios (e.g. 1.0, 2.0, 0.5)
	var opRatios       = \opRatios.kr(1!opCount);

    // ENVELOPES: Flattened arrays (6 ops * 4 stages = 24 values)
    // Format: [Op1_L1, Op1_L2, Op1_L3, Op1_L4, Op2_L1...]
    var opEnvLevels    = \opEnvLevels.kr(0!(opCount*4));
    var opEnvTimes     = \opEnvTimes.kr(1!(opCount*4));

	// Feedback container: Reads audio from the end of the previous cycle
	var opCtrlOutBank = LocalIn.ar(opCount);

    // --- HELPER: Create Envelope for Operator i ---
    var makeOpEnv = { |opIndex|
		var start = opIndex * 4;
		// Slice the flat arrays to get data for this specific operator
		var levels = opEnvLevels[start .. start+3]; // [L1, L2, L3, L4]
		var times  = opEnvTimes[start .. start+3];  // [R1, R2, R3, R4]

		// DX7 Envelope Topology vs SuperCollider Env:
		// DX7: Starts at L4 (previous level), goes to L1 in Time1.
		// SC Env: defined by points and durations between them.

		EnvGen.ar(
			Env(
				// Levels: [Start(L4), Target1(L1), Target2(L2), Sus(L3), End(L4)]
				// Note: DX7 envelope behavior is complex. This is an approximation.
				[levels[3], levels[0], levels[1], levels[2], levels[3]],
				// Times: [T1, T2, T3, T4]
				[times[0], times[1], times[2], times[3]],
				-4, // Curve type (Exp)
				3    // Release Node: The envelope stays at index 3 (levels[2]/L3) while gate is 1.
				),
				gate
			)
    };

	// Helper to access flattened matrix
	var indexOpWiringMatrix = { |r, c|
		opWiringMatrix[(r * opCount) + c];
	};

    // Calculate FM Input for Operator i
	var getOpInput = {|op_i|
		var sum = 0;
		opCount.do{|op_o|
            // op_o is the Modulator, op_i is the Carrier.
            // The matrix stores the Modulation Index (depth).
			var gain = indexOpWiringMatrix.(op_i, op_o);

			// Add the output of the modulator specific gain
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
		// Sine Oscillator
		// - Freq: Base Pitch * Ratio
		// - Phase: Modulated by input signal (FM)
		// - Amp: Controlled by Envelope
		SinOsc.ar((baseFreq * ratio), phase: in) * env
    };

	var newOpCtrlOutBank = Array.newClear(opCount);
	var opOut = Array.newClear(opCount);
	var mixerUnitSum = getOpOutMixerSum.();

    // Generate all 6 operators
	opCount.do{|i|
		var opInput = getOpInput.(i); // Sum of all modulators
        var adsr = makeOpEnv.(i);     // Current Envelope Value (0-1)

		var op = makeOp.(baseFreq, adsr, opRatios[i], opInput);

		newOpCtrlOutBank[i] = op;     // Store for Feedback/Next Cycle
		opOut[i] = op * opOutMixer[i]; // Send to main out if active
	};

    // Normalize output to prevent clipping if multiple ops sum up
	opOut =	if(mixerUnitSum != 0, {Mix(opOut) /  mixerUnitSum}, {0});

    // Write internal signals to Local loop for next audio block
	LocalOut.ar(newOpCtrlOutBank);

	Out.ar(0, opOut !2); // Stereo out

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
	// msg[53..76] = 4*6 floats (Envs/Levels)

	var matrix = msg[2..37];
	var mixer  = msg[39..44];
	var ratios = msg[46..51];
	var envLevels = msg[53..76];
    var envTimes = msg[78..101];


	var roundArray = { |arrayToRound, resolution = 1|
    arrayToRound.collect { |number|
        number.round(resolution);
    };
};

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


	"level: ".post;
	roundArray.(envLevels, 0.01).postln;

	"time: ".post;
	roundArray.(envTimes, 0.01).postln;

}, "/update_synth");
)
