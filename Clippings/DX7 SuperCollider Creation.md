---
title: DX7 SuperCollider Creation
source: https://chatgpt.com/g/g-p-68f92068f498819190db2525b924d7b8-audio-programming/c/691cd218-2200-8325-b259-dd1fbe076d4f
author:
  - "[[chatGPT]]"
published:
created: 2025-12-08
description: ChatGPT is your AI chatbot for everyday use. Chat with the most advanced AI to explore ideas, solve problems, and learn faster.
tags:
  - clippings
---
Short answer: yeah, there’s more. What you listed is the *core*, but a DX7 is basically a small FM ecosystem, not just “6 sines + envelopes”.

Before we dive in, two paths you can take:

- **Path A – DX7-ish 6-op FM synth**  
	Keep the structure (6 ops, a few algorithms, envelopes) but don’t chase every tiny parameter.
	- ✅ Much easier to finish for the module
	- ✅ Cleaner code, easier to understand and demo
	- ❌ Won’t perfectly match DX7 patches / SYX
- **Path B – Faithful-ish DX7 clone**  
	Try to match the real DX7 feature set, maybe even read SYX.
	- ✅ Nerd cred, better compatibility with real patches
	- ❌ A *lot* more work (UI, parameter mapping, scaling quirks, etc.)
	- ❌ Easy to drown in details instead of making a good artefact

I’d strongly recommend **Path A** for your project: *DX7-inspired 6-op FM synth* with a few iconic bits, rather than a museum-grade replica. You’ll learn the same DSP, but you’ll actually finish.

---

### What’s missing beyond “6 oscillators + 4-segment envs + rewiring”?

Here are the big chunks the DX7 has that you haven’t mentioned yet:

1. **Operator frequency controls**
	- Per-operator:
		- Ratio vs fixed frequency modes
		- Coarse/fine tuning or just “ratio + detune”
	- This is crucial for FM timbre design. In SC terms: each operator needs `baseFreq * ratio + detune`.
2. **Operator-level output controls**
	- Output level per operator (acts like “how much this operator contributes as carrier/modulator”).
	- Keyboard velocity sensitivity per operator (even if you simplify this to a global amount).
3. **Algorithms / routing structure**  
	You already hinted at “rewiring by bus”, but conceptually:
	- A set of algorithms that define who modulates who (the DX7 has 32; you can easily start with 3–5).
	- At least one algorithm with:
		- Pure stack (6→5→4→3→2→1)
		- Parallel carriers (e.g. 3+2+1 stacks
		- Feedback operator (see next point).
4. **Feedback**
	- On a DX7, one operator in each algorithm can feed its own output back into its input (self-FM).
	- In SC, that means:
		- Either using `LocalIn` / `LocalOut` to create a feedback loop, or
		- Approximate feedback by feeding a delayed version, or
		- Fake it with a waveshaper / distortion as a “feedback-ish” timbre control.
	- You *want* some feedback option; it’s a big part of the classic FM “bite”.
5. **Pitch envelope**
	- The DX7 has a global 4-segment pitch envelope separate from the operator amp envelopes.
	- You don’t *have* to fully replicate it, but:
		- A simple pitch EG (or even just one attack portion) adds a lot of “DX” character (e.g. brass/whoosh at the start).
6. **Global LFO / modulation**
	- At least one global LFO that can:
		- Modulate pitch (vibrato)
		- Maybe modulate amplitude (tremolo) or operator output levels a bit.
	- The original has multiple shapes etc.; you can get away with a single `SinOsc` or `LFTri` and a depth parameter for now.
7. **Keyboard tracking / scaling (optional but tasty)**
	- The DX7 lets envelopes and levels change over the keyboard:
		- E.g. brighter at the top of the keyboard, duller at the bottom.
	- For a scoped project:
		- You can implement a *simple* keyboard scaling: e.g. modulator level increases with MIDI note.
8. **Polyphony / voice architecture**
	- DX7 is a polysynth. For SuperCollider:
		- You need some kind of **voice allocator** or at least a simple way to create one Synth per note (via MIDI or GUI).
	- Could be as simple as:
		- A `SynthDef` that is “one voice”
		- A simple event or pattern system (`Pbind`) or a MIDI responder to create/destroy voices.
9. **Patch structure / parameter storage**
	- Even if you don’t aim for SYX compatibility, you want:
		- A data structure (e.g. a `Dictionary` or `Event`) that holds operator params + global params = “patch”.
	- This will make:
		- Saving/loading presets
		- Exposing parameters to a GUI  
			way more manageable.
10. **UI / control surface (for the artefact)**
- Sliders/knobs for:
	- Operator ratios / outputs
	- Algorithm select
	- LFO rate/depth
	- Global env times
- Nothing fancy, but enough to demonstrate you’re not just hardcoding a single sound.

---

### A practical “minimum DX7-ish” feature set

If we define a *realistic* scope that still feels like a DX7:

- 6 sine operators in a single `SynthDef`, each with:
	- `ratio`, `detune`, `outputLevel`
	- 4-segment amp envelope (simplified mapping from DX’s rate/level is fine)
- 3–5 hardcoded algorithms (routing matrices) selectable with an `alg` argument
- One operator in some algorithms gets a simple feedback parameter
- 1 global pitch envelope (even just 2–4 segments) applied to the base pitch
- 1 global LFO with depth to pitch and maybe overall amp
- Simple keyboard tracking:
	- Velocity → overall amp + maybe modulator level
- Polyphonic triggering via MIDI or patterns
- A few presets defined as dictionaries, maybe in a `.scd` file

That’s already a *really* strong artefact for your module: conceptually rich, technically meaty, and very show-off-able in a viva.

---

If you like, next step I’d propose is: design the data structure for **one operator** (what fields it has) and the structure for **one algorithm** (how we represent connections). Once those are nice and clean, the actual `SynthDef` wiring becomes much easier instead of turning into a spaghetti monster.

A bus in SuperCollider is a bit like a river: lots of things can pour water into it, and lots of things can scoop water out. The real trick is that the river only holds **one** number per channel at any given instant. It doesn’t magically mix multiple values unless *you* do the mixing.

Two approaches relevant for FM synthesis:

### Approach 1 — “Real” audio busses

You physically route signals through SC’s AudioBus system.

- Many UGens can **write** to the same audio bus using `Out.ar(bus, sig)` or `OffsetOut.ar`.
- If multiple UGens write to the same bus at the same moment, you’ll get **multiple writers**, which SC *does allow*, and the results are **summed**.
- Many UGens can then **read** the bus with `In.ar(bus, numChannels)`.

So yes:

- One output → many inputs? Absolutely, just read the bus from multiple places.
- Many outputs → one input? Also yes — they sum.

The catch:  
Audio busses introduce **one block of latency** (usually 64 samples), because SC processes audio in blocks. FM needs instantaneous, sample-accurate feedback unless you want a smeary, softened sound. With busses, feedback loops become unstable or “gummy.”

So for pure FM routing, global busses are awkward. They work, but the sound will not be DX7-tight.

---

### Approach 2 — Use SC’s graph-level wiring inside a single SynthDef

This is how most FM synths in SuperCollider are built.

Inside a SynthDef, every operator is just a signal variable, like:

You’re patching values directly by referencing variables. No buses, no latency.

Here:

- One operator’s output can feed multiple places:  
	Just use `op3` anywhere you want.
- Multiple operators can combine into one input:  
	Just add them: `modSignal = op2 + op4 + op6`.

Since this is just math in the DSP graph, it’s sample-accurate.

This is how you build FM algorithms: direct wiring in the SynthDef.

---

### Approach 3 — LocalIn / LocalOut (feedback-friendly busses inside a SynthDef)

SuperCollider includes a special trick for feedback loops:

This introduces *one sample* of delay—much tighter than an audio bus’s block delay. It’s decent for DX7-style feedback operators.

---

### So what’s the best strategy for your DX7 clone?

- For **operator → operator** FM routing, use **graph-level connections**, not audio busses.
- For **self-feedback**, use **LocalIn/LocalOut**.
- For **polyphony and voice management**, you can use node-level audio busses *outside* the SynthDef, but not inside the FM structure.

---

### TL;DR

Inputs don’t have “multiple inputs” and outputs don’t have “multiple outputs”—a bus is just a number. But you absolutely can have:

- multiple outputs writing to the same bus → they sum
- many readers reading the same bus → they all get the same signal

Technically everything you asked is allowed, but for a 6-op FM synth, **busses are the wrong tool for operator routing**. The FM graph should live inside a single SynthDef so you get clean, sharp FM like the DX7.

If you’re curious, next step can be: how to represent an algorithm as a data structure so the SynthDef wires itself automatically. That’s a fun bit of SuperCollider metaprogramming, and gets you closer to a modular DX7.

Self-feedback in FM is a tiny dance on a knife edge. The oscillator wants to eat its own tail, but direct recursion in a DSP graph is impossible: you can't define

because SC can’t compute `op` when `op` depends on itself. It needs at least one sample of breathing room.

There are two common ways to give it that breathing room:

### Option A — Audio bus feedback

You could do:

This *works* as a feedback loop, but the signal is delayed by **an entire block** (usually 64 samples), so the feedback gets mushy. Instead of the sharp, metallic “DX crunch”, you get a more resonant, blurry sound. Useful sometimes, but not for DX7-style FM.

### Option B — LocalIn/LocalOut

LocalIn/LocalOut create a **single-sample delay inside the same SynthDef**, which is the minimum delay SC can give you while staying stable.

This gives you a feedback loop that is tight, bright, and very much like the DX7’s internal feedback oscillator. The “bite” of feedback FM depends heavily on how short that delay is.

Why this matters:

• In FM, feedback effectively turns a sine wave into a sharper, more harmonic-rich wave.  
• With a long delay (audio bus), feedback behaves more like a resonant echo.  
• With a one-sample delay, it behaves like a nonlinear waveshaper — exactly the effect Yamaha exploited.

LocalIn/LocalOut give you the “good” kind of chaos without blowing up the graph.

If you want, I can describe how to wrap this into an operator function so you can switch feedback on/off per algorithm without duplicating code.

Nice, let’s engineer a tiny “DX7-ish operator” Lego brick.

First, two ways to integrate feedback:

1. **Global, single feedback loop (DX7-style)**
	- One `LocalIn` / `LocalOut` in the whole SynthDef.
	- Exactly one operator per algorithm taps that loop.
	- Pros: simple, matches DX7 (there’s only one feedback slot per algorithm), easy to reason about.
	- Cons: if you ever want *multiple* feedback ops, you have to refactor.
2. **Per-operator feedback loops**
	- An array of LocalIn/LocalOut pairs, one per operator, e.g. 6 channels.
	- Pros: super flexible; any op can self-feedback independently.
	- Cons: more wiring, more mental overhead, not how DX7 does it, and honestly overkill for your project.

For a DX7-inspired synth, **go with option 1**: single feedback loop, but make your **operator function** agnostic to whether it’s using feedback or not. The algorithm decides that.

---

### Step 1 – A reusable operator function

Inside your SynthDef, you define a function that builds one operator given:

- base frequency
- modulation input
- envelope value
- output level
- feedback input (defaults to 0 so you can ignore it for non-feedback ops)
```markdown
supercolliderSynthDef(\dx6, { |freq = 220, fbAmt = 0, fbOp = 6, gate = 1|
    var op, ops, fbSig;
    
    // one global feedback loop (1-channel)
    fbSig = LocalIn.ar(1);  // this is last-sample output of the feedback op

    // reusable operator function
    var makeOp = { |baseFreq, modIn, env, outLevel, fbIn = 0|
        var sig;
        sig = SinOsc.ar(
            baseFreq + modIn + fbIn   // fbIn is already scaled by fbAmt outside
        ) * env * outLevel;
        sig
    };

    // For demo, fake envelopes as simple constants (replace later with real 4-seg envs)
    var envs = Array.fill(6, { 1 }); // [env1, env2, ..., env6]
    var levels = [1, 1, 1, 1, 1, 1]; // output levels per operator

    // modulation structure example: algorithm 32-ish: 2→1, 4→3, 6→5, 1+3+5 are carriers
    ops = Array.newClear(6);

    // op indices are 0..5 internally, but fbOp is 1..6 for friendliness
    // define a helper: if this op is the feedback op, pass fbSig * fbAmt, else 0
    var fbFor = { |index|
        (index + 1) == fbOp.if(
            { fbSig * fbAmt },
            { 0 }
        )
    };

    // op2 modulates op1
    ops[1] = makeOp.(freq, 0, envs[1], levels[1], fbFor.(1));  // op2 (index 1)
    ops[0] = makeOp.(freq, ops[1], envs[0], levels[0], fbFor.(0));  // op1

    // op4 → op3
    ops[3] = makeOp.(freq, 0, envs[3], levels[3], fbFor.(3));
    ops[2] = makeOp.(freq, ops[3], envs[2], levels[2], fbFor.(2));

    // op6 → op5
    ops[5] = makeOp.(freq, 0, envs[5], levels[5], fbFor.(5));
    ops[4] = makeOp.(freq, ops[5], envs[4], levels[4], fbFor.(4));

    // carriers: op1, op3, op5
    var out = ops[0] + ops[2] + ops[4];

    // write the feedback operator’s output into the LocalOut
    // pick the signal of the feedback op; default to 0 if fbOp out of range
    var fbSigOut = ops.wrapAt(fbOp - 1);
    LocalOut.ar(fbSigOut);

    Out.ar(0, out.dup);  // stereo
}).add;
```

Key bits:

- `makeOp` is your **operator building block**. It knows nothing about “algorithms” or “who feeds who”; it just takes `modIn` and an optional `fbIn`.
- `fbFor.(index)` decides **per operator** whether to pass feedback or 0.
- The algorithm is encoded by how you compute `ops[...]` (which ops modulate which).

You’ll eventually replace:

- `envs[...]` with proper 4-segment envelopes per operator.
- `levels[...]` with operator output levels (and maybe velocity scaling).
- The specific wiring with a data-driven algorithm layout.

---

### Step 2 – Turning this into multiple algorithms

Now that the operator function is clean, you can change the **wiring only** to switch algorithm, instead of duplicating envelope/ratio logic.

For example, you could do:

```markdown
supercolliderSynthDef(\dx6, { |freq = 220, fbAmt = 0, fbOp = 6, alg = 1, gate = 1|
    var ops = Array.newClear(6);
    var fbSig = LocalIn.ar(1);

    var makeOp = { |idx, baseFreq, modIn|
        var env = 1;        // placeholder
        var level = 1;      // placeholder
        var fbIn = ((idx + 1) == fbOp).if({ fbSig * fbAmt }, { 0 });
        SinOsc.ar(baseFreq + modIn + fbIn) * env * level
    };

    switch(alg,
        1, {
            // Stack 6→5→4→3→2→1
            ops[5] = makeOp.(5, freq, 0);
            ops[4] = makeOp.(4, freq, ops[5]);
            ops[3] = makeOp.(3, freq, ops[4]);
            ops[2] = makeOp.(2, freq, ops[3]);
            ops[1] = makeOp.(1, freq, ops[2]);
            ops[0] = makeOp.(0, freq, ops[1]);
        },
        2, {
            // Parallel carriers etc...
            // different wiring but same makeOp usage
        }
        // add more algorithms here
    );

    // choose which ops are carriers per algorithm:
    var carriers = case
    { alg == 1 } { [0] }       // only op1
    { alg == 2 } { [0,2,4] }   // example
    { [0] };                   // fallback

    var out = carriers.collect({ |i| ops[i] }).sum;

    var fbSigOut = ops.wrapAt(fbOp - 1);
    LocalOut.ar(fbSigOut);

    Out.ar(0, out.dup);
}).add;
```

Operators stay DRY:

- Envelopes, levels, freqs, feedback handling are all in `makeOp`.
- Algorithms just say “this op modulates that op”.

---

### Why this works nicely

- **Feedback toggle per algorithm**: change `fbOp` and `fbAmt`, no code duplication.
- **Clean separation**:
	- *What an operator is* → `makeOp`
	- *How they’re connected* → `switch(alg, ...)`
- **DX7-aligned**: one feedback operator per algorithm is exactly what the real thing does, but you can still set `fbAmt = 0` to effectively “disable” it.

From here, the next mechanical steps are:

- Add proper 4-segment envelopes into `makeOp`.
- Add per-operator `ratio`, `detune`, `level` arrays.
- Make `alg`, `fbOp`, `fbAmt` and operator params arguments or patch data.

Once you’ve done that, you basically have a “DX7-ish core engine” ready for MIDI and GUI dressing.

1\. \* more wiring, more mental overhead, not how DX7 does it, and honestly overkill for your project.

what do you mean? DX7 obviously has more than a single feedback operator...

You’re right to poke at that — the DX7 *does* have more than one operator capable of self-feedback **across its 32 algorithms**, but each *algorithm* only designates **one** operator as “the” feedback operator at a time.

That’s the distinction I was talking about.

### How the real DX7 handles feedback

In the official Yamaha architecture:

- Every algorithm has **exactly one operator** that can apply feedback to itself.
- The feedback amount is a *global* parameter for that algorithm (0–7).
- Which operator gets feedback changes *per algorithm*, not per voice, not per operator.

Example:

- Algorithm 1: feedback is applied to operator 6.
- Algorithm 2: feedback is applied to operator 5.
- Algorithm 7: feedback is on operator 2.
- Etc.

The hardware literally has one feedback loop in the signal routing matrix, and the matrix chooses which operator’s output goes back into itself.

### So: multiple operators on the DX7 are capable of receiving feedback across different algorithms, but only one per algorithm ever does.

That’s what I meant by “not how DX7 does it” when talking about giving *every operator* its own independent feedback loop.  
The DX7 simply doesn’t allow 3 operators to self-feedback simultaneously. Only one slot exists.

---

### Why this matters for your implementation

You have two implementation choices:

#### A — DX7-style single feedback slot (recommended)

- Cleaner, faithful, and easier to implement.
- Each algorithm picks which operator receives feedback.
- You store one value: `fbOp` (1–6).

This is *exactly* how the real machine works.

#### B — SC-style per-operator feedback (more flexible, not DX7-like)

- You give each operator its own LocalIn/LocalOut loop.
- Any operator can self-feedback, even several at once.
- More power, but more headache, and not behaviourally identical.

Version B is conceptually interesting, but version A is the one that mirrors the DX7 logic and stays simple.

---

### Why Yamaha chose a single feedback operator

DX7 feedback serves a specific purpose:

- Introduce harmonic enrichment (turn a sine into a saw-ish or square-ish shape).
- Keep algorithms predictable and controllable.
- Avoid instability from multiple simultaneous feedbacks.

Giving six operators feedback would make the machine dramatically more chaotic, and the UI wouldn't map well to that.

---

### Where you stand now

Your earlier operator-builder structure supports either approach.  
To be faithful:

- You keep **one** LocalIn/LocalOut pair.
- Your “algorithm” chooses which operator feeds that loop.
- That operator gets `fbAmt * fbSignal` added to its phase.
- All other operators get `fbIn = 0`.

This is correct for DX7 modelling.

If you *want* to explore the wild west and allow multiple ops to self-modulate, you can — it’ll just depart from the DX7’s topology and feel more like a modern modular FM synth.

---

If you want next, we can sketch a clean way to encode the 32 DX7 algorithms into a SC-friendly data structure — maybe a list of “who modulates who” plus “who is the feedback operator”. This avoids wiring spaghetti and lets your SynthDef assemble itself neatly.

Right — and now we’re fully aligned.  
What you’re describing is the **actual** DX7 constraint:

**There is only one place in the whole algorithm where a signal loops “upward” (backwards in the graph).**  
That loop can land on an operator (self-feedback) *or* pass to an operator above it (cross-operator feedback).  
Everything else in the topology is strictly feed-forward.

So:

- The DX7 **does not** limit you to *only self-feedback*.
- The DX7 **does** limit you to *a single back-edge* in the whole routing graph.

This is exactly why operators can be arranged in chains where the feedback operator sits at the bottom and modulates several layers upward through the chain. Example:

Or split into branches:

**One back-edge. Many forward edges.**  
That’s the whole deal.

---

### Why SuperCollider implementation needs a deliberate feedback design

SC lets you build any graph you want — but the DX7’s structure translates to:

- Many forward operator connections: just variables and `+`.
- Only one operator is allowed to contribute to a *back-edge*.
- That back-edge must be handled with `LocalIn/LocalOut` (one-sample delay), because that’s how you represent a feedback edge in a DSP graph.

This means your model should look like:

1. Compute operators **in dependency order** (feed-forward).
2. Identify which operator’s output goes into the feedback loop (“feedback node”).
3. On the next sample, add that feedback into its designated target (self or upstream op).

You can generalise it like this:

Where:

- `X` may be the same as `Y` (self-feedback)
- `X` may be an operator above `Y` (cross-operator feedback)
- There is only *one* `Y → X` loop per algorithm  
	(matching the real DX7 routing matrix)

---

### A practical pattern for you

Instead of “single feedback operator”, you should store:

- **fbSource**: which operator’s output is tapped
- **fbTarget**: which operator receives the feedback

Those two define the back-edge.

DX7 algorithms only ever use `(fbSource == fbTarget)`  
but you can allow `(fbSource != fbTarget)` if you want the full chain-feedback behaviour you described (and modern FM engines like FM8/Operator do).

Even the real DX7’s apparent “feedback chain” behaviour is *just* the fact that the feedback operator sits under a vertical stack of modulators. The feedback itself is only applied at one node.

---

### Putting it all together

You were absolutely correct:

- a DX7 algorithm may place the designated feedback operator anywhere in its structure
- the operator above it effectively receives the “chain feedback”
- but the architecture itself only supports **a single backtrace** in the graph

And SC implementations should respect that by implementing **exactly one feedback loop in the SynthDef**, with fully programmable source and target.

---

If you want, I can show how to roll this into a compact `Algorithm` struct:

and the SynthDef will wire itself accordingly.