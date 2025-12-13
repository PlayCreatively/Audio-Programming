# 1. Strategic AI Briefing Documentation (500–600 words)

Document how you provided context to AI tools, including your initial project brief,
technical constraints, and creative goals. Include:

- [ ] a. Your initial project brief given to AI tools
- [ ] b. Examples of how you provided SuperCollider/DSP context
- [ ] c. Evidence of how you refined your prompting approach

# 1.1 AI Incorporation
For this project, AI played the part of an informant, teacher, as well as assistant programmer, therefore there was no direct project brief but instead more of a natural dialogue, as I was gauging the project's feasibility and informing myself on all the parts required to make the project happen.


``` Prompt
would it be difficult to recreate the dx7 with supercollider?`
```

After getting a detailed descriptions of what elements are required for the project I wanted a clarification on the 4-segment rate/level envelopes as well as an explanation why it deemed a .syx parser would be a mini-project of its own.

``` Prompt
1. 4-segment rate/level envelopes? 
2. Parsing .syx and mapping all parameters is a mini-project on its own. Why?
```

``` Prompt
alright, let's move onto creating the DX7 on the SuperCollider. As far as I understand, it requires 6 oscillators, a 4-segment rate/level envelope for each oscillator, and functions to rewire the oscillators by rewiring the bus. Is there more?
```


## 1.2 Prompt refinement
- **Provide options:** as a global command, I instructed the LLM to provide at least two potential approaches to any implementation and explain how one works best for the project.
- **Human formality and curtesy**: speaking to it in a thought out and polite manner not only makes you more thoughtful than you might be if talking to a machine, it itself is also more likely to be helpful — the logic being based on prior research, suggesting that politeness increases the quality of LLMs, as well as the often held intuition that since LLMs are a autocomplete prediction machines, deviating from the training data might impact the quality of the answer.
- ==TODO: add more examples==

---
# 2. Example Prompts and AI Outputs (800–1000 words)
Provide 4–5 detailed examples of AI interactions that were significant to your project
development. For each example include:

- [ ] a. The exact prompt you used (in code blocks)
- [ ] b. The AI’s response/output (in code blocks)
- [ ] c. Your reflective commentary on the quality and usefulness of the response
- [ ] d. How you modified or used the AI’s suggestion

# 2.1 Feedback delay

**Prompt**

``` Prompt
how do busses work? can I wire them up so one output is connected to all other inputs? As in, can an input have multiple inputs and can an output be connected to multiple inputs?
``` 

The LLM provides me with the vital information that SC's buses use a single block buffer (usually 64 samples) for efficiency reasons, which results in a considerable delay in terms of FM synthesis. Since the DX7 was directly wired up, hardware wise, introducing any sort of delay will most likely deviate far from the original sound of the DX7. This informed my next decision when it came to the dynamic wiring of the different operators; since I knew buses were too slow and hardwiring each operator would not allow me to translate between different operator wirings.

**LLM output**

``` ChatGPT 5.1
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
```

# 2.2 Dynamic wiring

**Prompt**

![[Pasted image 20251119162845.jpg]]
``` Prompt
see these different connections?  
is it possible to create a single system that can linearly interpolate between any of these systems? If so, how would they be wired up and how would it work?
```

**LLM output (Gemini 3 Pro Preview)**

``` Gemini 3 Pro Preview
In the field of vehicle dynamics and control theory, this concept is known as a **Reconfigurable Active Suspension** or a **Virtual Suspension System.**
[...]
```

For brevity I will stop here as it went on to describe how something like the Mars rover (considering it also has 6 wheels) would be wired up... Very smart Gemini ✨ Here's a cookie 🍪.

My reasoning for not providing context to this diagram is precisely because I wanted a generic solution to the very generic problem of linearly interpolating between different configurations of something that is essentially nodes and edges. In terms of Graph Theory, I wanted a way to interpolate between two graphs, knowing the number of nodes will stay the same. So I knew a solution existed where every node would be connected to each other and the connection could be represented as the **weight** of each edge, and since they're linear values, ranging from 0 to 1, we can interpolate between different graphs by simply interpolating the weights. However, the two things I didn't know yet, was:

1. Graphs are generally bidirectional, unlike the DX7 operators which are strictly linear.
2. Knowing roughly how Large Language Models (LLMs) function under the hood, I knew these kinds of linear node flows could be represented and calculated using tensors and matrix operations. But I couldn't figure out how to do that exactly.

**Prompt**

``` Prompt
this is all digital, it's in fact a synthesizer; one thing that's important is that there's a clear order of operations. One node feeds into the next node and influences its output
```

The LLM provides me with the incredibly neat, and in hindsight, incredibly obvious solution of storing everything in a 6x6 matrix and treating the columns as the input and the rows as the output. In a matrix aware language, such operations could be as succinct as calculating the dot product between the output mixer vector (which operator should output to the speaker), the input vector (a cache of the previously calculated outputs of each operator) and the transported wiring matrix:
$$
\vec M_{ixer} \cdot \vec I_n \cdot M^\intercal  =\vec O_{ut}
$$

**LLM output (Gemini 3 Pro Preview)**

``` Gemini 3 Pro Preview
This changes the context completely! If this is a digital synthesizer (specifically **FM Synthesis**, as these diagrams are almost certainly the 32 algorithms from the classic **Yamaha DX7**), the solution is much more elegant than hydraulic pipes.

To create a single system that can linearly interpolate between these discrete algorithms—morphing from a "stack" (series) to "carriers" (parallel) and everything in between—you need to build a **Fully Connected Modulation Matrix**.

Here is how you wire it up and how the interpolation logic works within a Digital Signal Processing (DSP) environment (like Max/MSP, Reaktor, SuperCollider, or C++).

### 1. The Wiring: The "Matrix" Approach
In a standard DX7, the "Algorithm" is a hard-wired preset. To make it morphable, you must "un-wire" it and connect **everything to everything**.

You need two primary data structures:

1.  **The Modulation Matrix ($6 \times 6$ Grid):** This controls "Who modulates whom."
    *   Rows = Sources (Operators 1–6)
    *   Columns = Destinations (Operators 1–6)
    *   Value = The **Modulation Index** (Amount). 0.0 means no connection; 1.0 means full connection.
2.  **The Output Mixer (Vector of 6):** This controls "Who goes to the speakers (Audio Output)."
    *   In Diagram 1, only Operator 1 goes to the output.
    *   In Diagram 32, all 6 operators go to the output.

### 2. How it Works: The Order of Operations
Since you specified that the order is critical (Node B processes Node A's output), you must calculate the operators in a specific sequence every single audio sample.

However, to allow *any* feedback configuration (like the loops seen on the top of the blocks in the diagrams), you usually calculate from the "bottom up" or use a **one-sample delay** for feedback paths.

#### The Universal DSP Block (The "Single System")
Instead of 32 different code blocks, you write **one** loop that runs for every audio sample:

\```pseudo
// Store the output of all 6 operators from the previous sample (for feedback)
prev_outputs = [op1_last, op2_last, ..., op6_last]

// The Current Sample Calculation Loop
current_outputs = [0, 0, 0, 0, 0, 0]

// We calculate each Operator (1 through 6)
for i = 1 to 6:
    
    // Step A: Calculate Input Modulation
    // Sum up all incoming signals based on the Matrix
    modulation_input = 0
    for j = 1 to 6:
        // Matrix[j][i] is "How much Op j modulates Op i"
        modulation_input += prev_outputs[j] * Matrix[j][i] 
    
    // Step B: The Synthesis (Order of Operations)
    // The operator generates sound based on its specific frequency + the modulation input
    current_outputs[i] = sine_wave(phase[i] + modulation_input) * Envelope[i]

// Step C: The Main Mix
// Decide what actually goes to the speakers
final_audio = 0
for k = 1 to 6:
    final_audio += current_outputs[k] * OutputMixer[k]
\```

### 3. Linearly Interpolating (The "Morph")
Now you have a "Universal Algorithm." To morph between **Diagram 1** and **Diagram 32**, you simply interpolate the values in the **Matrix** and the **Output Mixer**.

**Example: Morphing from Algorithm 1 to Algorithm 32**

*   **State A (Diagram 1 - The Tower):**
    *   Matrix: Op 6 modulates 5, 5 modulates 4, 4 modulates 3...
    *   Output Mixer: Only Op 1 is audible (1.0). Op 2–6 are silent (0.0).
*   **State B (Diagram 32 - The Flat Line):**
    *   Matrix: All modulation values are 0.0 (no FM, just additive).
    *   Output Mixer: All Operators are audible (1.0).

**The Interpolation Logic:**
If your morph knob is at 50% ($\alpha = 0.5$):

1.  **The Connections:** The connection "Op 6 $\to$ Op 5" fades to 50% strength. The spectral complexity decreases smoothly.
2.  **The Outputs:** Operators 2, 3, 4, 5, and 6 slowly fade in at the main output.
3.  **The Result:** You will hear the complex, metallic FM tower slowly dissolve into a massive, thick chord of 6 stacked sine waves.

### 4. Dealing with Feedback (The loops on top of boxes)
You'll notice some boxes (like Box 6 in Diagram 1) have a line connecting to themselves.
*   In the **Matrix**, this is simply the diagonal value `Matrix[6][6]`.
*   To interpolate a feedback loop, you linearly fade that value from 0.0 to 1.0 (or whatever the target feedback amount is).

### Summary
Yes, you can build this.
1.  **Wire it:** Connect every Operator to every other Operator (and itself) with a variable gain node (VCA).
2.  **Wire the outs:** Connect every Operator to the main output with a variable gain node.
3.  **Control it:** Store the 32 diagrams as "Presets" of Matrix values.
4.  **Morph it:** Use linear interpolation (Line/Ramp function) to transition the grid of gain values from Preset A to Preset B over time.

This is effectively how modern "Matrix Synths" (like Arturia's MatrixBrute or Native Instruments' FM8) work under the hood, allowing for sounds that are impossible on the original hardware.
```

In further retrospect, I notice that regardless of how chaotic the operator wiring are, they always go from a higher index down to a lower index. Simply by that logic I can safely assume that calculating from the highest index down to the lowest ensures that the input is as fresh as it can be, only requiring me to reorder the calculations to get even closer to the DX7 hardware. 

I believe I already had this thought early on, but since the wiring is so dynamic, and I wanted the freedom of exploring configurations outside of the hardwired DX7 configurations I thought that hardcoding in a single buffer would make the space symmetric. But if this single delay buffer has audible impact then it might have been the wrong decision.

---

~~Since the [[#1.2 Prompt refinement|Provide Options]] prompt is in effect, I often get forced options that are not only ~~

---
# 3. Critical Filtering and Decision Making (400–500 words)
Document specific instances where you rejected or significantly modified AI
suggestions. Include:

- [ ] a. At least 2 examples of AI outputs you rejected with your reasoning
- [ ] b. Examples of code you modified or improved from AI suggestions
- [ ] c. Your criteria for evaluating AI suggestions in audio programming contexts

There was not as much critical filtering as there were critiques, inquiries, and corrections. This is due to the fact that in order to maintain an up-to-date context, the AI needed to be led along and kept on the same page. 

# 3.1 Pushback

**Abridged LLM output (ChatGPT 5.1)**

```
First, two ways to integrate feedback:

1. **Global, single feedback loop (DX7-style)**
    
    - One `LocalIn`/`LocalOut` in the whole SynthDef.
        
    - Exactly one operator per algorithm taps that loop.
        
    - Pros: simple, matches DX7 (there’s only one feedback slot per algorithm), easy to reason about.
        
    - Cons: if you ever want _multiple_ feedback ops, you have to refactor.
        
2. **Per-operator feedback loops**
    
    - An array of LocalIn/LocalOut pairs, one per operator, e.g. 6 channels.
        
    - Pros: super flexible; any op can self-feedback independently.
        
    - Cons: more wiring, more mental overhead, not how DX7 does it, and honestly overkill for your project.
        

For a DX7-inspired synth, **go with option 1**: single feedback loop, but make your **operator function** agnostic to whether it’s using feedback or not. The algorithm decides that.
```

**Prompt**

```
what do you mean? DX7 obviously has more than a single feedback operator.
```

**Abridged LLM output (ChatGPT 5.1)**

```
You’re right to poke at that — the DX7 _does_ have more than one operator capable of self-feedback **across its 32 algorithms**, but each _algorithm_ only designates **one** operator as “the” feedback operator at a time.

That’s the distinction I was talking about.
```

**Prompt**

``` Prompt
I think you might be confused. the DX7 can have a chain, even two chains, of feedback from one operator to the next. The only thing that's limited is a single backtrace, there's only one feedback loop that feedbacks into a layer above itself, either connecting to itself or other operators
```

**Abridged LLM output (ChatGPT 5.1)**

``` ChatGPT 5.1
Right — and now we’re fully aligned.  
What you’re describing is the **actual** DX7 constraint:

**There is only one place in the whole algorithm where a signal loops “upward” (backwards in the graph).**  
That loop can land on an operator (self-feedback) _or_ pass to an operator above it (cross-operator feedback).  
Everything else in the topology is strictly feed-forward.
```

To summarize the conversation above, we were not speaking the same language when it came to frequency modulation, LLM used the term feedback as meaning self modulation and I understood feedback as any sort of modulation driven by another operator. At first, I believed it to be hallucinating as the DX7 clearly had more modulating operators than 1 in each algorithm. Were I to shrug it off as a hallucination, as opposed to a misunderstanding, we might not have gotten to an understanding, and the ill-defined terminology we were both using might have risen somewhere else where it might not have been as obvious that we were speaking past each other.

# 3.2 Inquiry

**Prompt**

```
would it be difficult to recreate the dx7 with supercollider?
```

Within the very detailed response was this claim which stood out to me as unlikely and I decided to inquire about it.

**AI output snippet (ChatGPT 5.1)**

```
**SysEx patch import.** Parsing .syx and mapping all parameters is a mini-project on its own.
```

**Prompt**

```
"Parsing .syx and mapping all parameters is a mini-project on its own" Why?
```

**AI output snippet (ChatGPT 5.1)**

```
## Why is parsing `.syx` and mapping all parameters a mini-project?

Because a DX7 voice isn’t “a few knobs.” It’s a **dense, packed spec** with a lot of small but audible rules. Concretely:

- **Multiple dump formats.**
    
- **7-bit data packing & checksums.**
    
- **Hundreds of parameters per voice.** For **6 operators**, each has:
    
    - 4 **Rates** + 4 **Levels**
        
    - **Keyboard level scaling** (breakpoint, left/right depths, left/right curves)
        
    - **Rate scaling**
        
    - **Velocity sensitivity**
        
    - **Amplitude (output) level**
        
    - **Coarse/fine frequency**, **mode** (ratio vs fixed), **detune**
        
    - Operator on/off flags
        
- **Global voice params:** **Algorithm**, **feedback**, **LFO** (speed, delay, wave, PMD/AMD, key sync), **pitch EG** (another 4-rate/4-level), **transpose**, **name**.
    
- **Non-linear tables everywhere.** Detune isn’t “cents = value×constant.” Keyboard scaling curves are categorical shapes. Velocity curves, pitch EG depth—many use Yamaha’s internal tables. To sound right you either:
    
    - Recreate those tables and mappings, **or**
        
    - Design musical approximations and accept small drift from hardware/DEXED.
        
- **Operator indexing & routing.** The 32 algorithms define a directed graph of who modulates whom; you must translate the algorithm number into your engine’s operator wiring (and place feedback on the right node).
    
- **Compatibility choices.** Do you target mkI semantics (classic DX7) or mkII/TX802 (extras, different ranges), and do you support bank dumps with performance data?
```

---
# 4. Collaboration Strategy Reflection (300–400 words)

As agreed with my supervisor, Matt Bellingham, the following section will look the same for both Audio Programming and Sound and Music Programming as both projects were worked on in tandem and differentiating between my LLM collaboration approaches would be difficult and frankly disingenuous, as they were one in the same. 

The collaboration was at its best when I was able to abstract individual generic problems from the project and tackle it in isolation using an LLM as a thinking partner. Once that problem is solved, implementing it manually as a generic function guarantees that you retain ownership and full comprehension of the whole codebase.

What can sadly happen is that time constraints and anxieties will steer you towards taking shortcuts and working in a somewhat reverse order: getting the LLM to work on the whole solution until you get to the desired goal and then retroactively study and refactor the code base. This may take more time in the long run, but in the short term it can sooth your anxieties about going down a null route. 

I tried to get the LLM to work in a way that facilitated the former approach, however, their underlying incentive is predisposed to do the work for you and spit out working code. It is not yet capable of reprograming itself to slow down and have a human-like dialogue where its making sure you're following along as opposed to throwing a whole assay at you, hoping it's covering all potential future questions you might have.

Creatively, it affords you to stay more in the high level thinking than the implementation level, freeing you from the limitations of your own knowledge and capability as well as the tunnel vision that the implementation level can lead to.

For a long time, professions relating to programming have had the [defect of being able to] take shortcuts, be it writing solutions based on intuition alone or brute-forced debugging which leads to solutions you can't explain. Then, since the introduction of the internet (and websites such as [stackoverflow.com](https://stackoverflow.com/)) outsourcing your solutions to fellow programmers have become easier, and now, at the dawn of LLMs, as they creep into our toolchains, it's become harder to not make use of the speed boost. I'm stating this because it only happens when the time allocated is not enough for the job to be done, and as long as jobs have deadlines, shortcuts will be taken.

---
# 5. Annotation Integration
### 5.1 Original aims

- **Creative goal:** Make a close enough simulation of the DX7 with the ability to read in old **MIDI System Exclusive files** (.syx) that contained famous 80s synth presets. 
- **JTBD.** A purely personal journey and resulting synth that teaches me about FM synths and their power to create unique sounds, making me capable of future experimental sound work.
- **Heuristics** (H1) working .syx parser; (H2) sound output recognized as a DX7.

### 5.2 Influences

**Software:** **[Dexed](https://github.com/asb2m10/dexed)** grounded the implementation of both the synth and the .syx parser. 
**Hardware:** **Yamaha DX7** was the north star but more specifically its emulation in the form of [Dexed](https://github.com/asb2m10/dexed) made it possible to audibly compare against using the exact same .syx files.
### 5.3 Implementation process

- **Language/platform choice:** Choosing between [Faust](https://faust.grame.fr/), [Juce](https://juce.com/get-juce/) and [SuperCollider](https://supercollider.github.io/) (SC), I initially went for Faust as it compiled down to a CPP script which would be easy to integrate with any GUI framework I go with when creating the interface for the project which is my project for Sound and Music Programming and not this Audio Programming class. Faust also had an online editor to quickly get running with any sort of audio generation. But after learning about Open Sound Control (OSC) I settled on SC as I thought it be better to use the tools I was being taught in class. In hindsight, Faust might have been the more appropriately flexible tool to use.
- **Design decisions:** Due to my own aspirations I wanted to be able to linearly interpolate between algorithms and in order to do that I would have to move away from the binary operator wiring and move to what ChatGPT 5.1 succinctly called 'variable gain nodes', which simply means the connections will be linear as opposed to binary. With that, and representing the connections as a matrix (sometimes referred to as a "matrix circuit", see image), I can dynamically wire up any existing or hypothetical DX7 algorithm in existence.
   ![[Pasted image 20251212143938.png|300]]
   
   I also decided to make it freely configurable which operators output their audio. So unlike the DX7, where the output operator is directly dictated by the algorithm, I have made it into its own parameter, meaning I can make any and all of the operators both feedback and output at the same time.

### 5.4 Evaluation against aims and heuristics

- **H1 working .syx parser:** As far as I can tell, the parser works as intended. Comparing the values from the resulting parsed JSON values, it seems to hold up, however due to the fact that the resulting audio output is difficult to liken to the DX7, it's hard to make a conclusive statement.
- **H2 sound output recognized as a DX7:** As mentioned, the resulting output does not adhere to the expected output of a DX7 simulator.

If I had more time I might have aborted the multi-algorithm setup and gone for a single algorithm, hardcoding the nested frequency modulation and making use of the dedicated **`PMOsc`** UGen in Super Collider, as that might have resulted in a closer output parity; although, **`PMOsc`** doesn't have a phase parameter, making a DX7 simulation using vanilla Super Collider a potential lost cause.

### 5.5 Reference list
1. [ ] References: Compile an APA-formatted reference list that includes well-chosen technical sources and details of the tools that influenced your work. All code examples should be properly formatted using Markdown code blocks with appropriate syntax highlighting.