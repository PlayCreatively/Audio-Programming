### Audio Programming workshop 1

```
Com-/ Make selected lines a comment
Shift-Com-B Balance enclosures
Com-. Stop all playback
Com-D Open help file for selected item
Double click enclosure Balance enclosures
```

#### Booting the server
Command - B

If you get a sample rate error on a lab Mac, do a Spotlight search for `Audio MIDI Setup' and make sure that your inputs and outputs all use the same sample rate (either 48kHz or 44.1kHz).

#### UGens
Typically have upper-case names, such as `Synth`, `SinOsc`, `LFNoise`, etc. Some particularly useful ones for today:

```
SinOsc
Pulse
Saw
WhiteNoise
PinkNoise
MouseX
MouseY
```

#### Messages
Usually (but not always) separated by a dot (`.play`, `.scope` etc.)

#### Arguments
A list of items separated by commas, enclosed in parentheses, following a message `(1, 2, 3)`.

#### Variables
User-defined names, useful to clean up code or reuse elements.

#### Functions
Anything in curly braces - `{SinOsc.ar}`

#### Expression
Punctuated by a semicolon, delineates the order in which the lines of code are executed.

#### Arrays
Items separated in commas and enclosed in square brackets `[1, 2, 3]`.

----

### Test code
#### Patch 1 - simple sine

```
(
{
	
	SinOsc.ar(200, 0, 0.5)
}.play
)
```

Using the above patch, try to:

* Change the frequency
* Change the amplitude
* Play the sound in stereo
* Change the waveshape


#### Patch 2 - adding variables

```
(
{
	var freq = 200;
	var amp = 0.5;
	var width = 0.5;
	
	Pulse.ar(freq, width, amp) !2
	
}.play
)
```

* How does it work?
* What would you change to...?
	* Change the frequency
	* Change the amplitude
	* Play separate frequencies from the left and right channels
* How can you show the harmonic content of the sound?


#### Patch 3 - broken!
This doesn't work - but why?

```smalltalk
(
{
	var freq = 200;
	var vol = 0.5
	var cutoff = 2000;

	RLPF.ar(Saw.ar(freq, vol) cutofff, 0.2
}.play
)
```

There are four errors in the above code. Try to find them, fix it, and play it!