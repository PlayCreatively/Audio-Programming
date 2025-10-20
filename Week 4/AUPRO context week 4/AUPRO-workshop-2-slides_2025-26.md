---
title: Workshop 2 - subtractive synthesis in *SuperCollider*
subtitle: Audio Programming
author: Matt Bellingham -- <matt.bellingham@port.ac.uk>
date: 6th October 2025
institute: University of Portsmouth
---

## Aims for today
- Review the function of filters, and the use of filters in SuperCollider
- Introduce `Line`, `XLine`, and `Impulse` in SuperCollider
- Make use of simple envelopes in SuperCollider, namely `Env.perc`

## First step - Bluetooth headphones in SC
- Many Bluetooth headphones have problems with SC as the input and output sample rates are different
- The fix is to use the iMac's microphone as the input and your headphones as the output
- You can find the name of the inputs with `ServerOptions.inDevices`
- Similarly, outputs are listed with `ServerOptions.outDevices`
- We can manually change the inputs and outputs using your computer's normal audio settings, or you can update SC's 	startup file to always use your preferred combination with something like...

```js
Server.default.options.inDevice_("iMac Microphone");
Server.default.options.outDevice_("YourHeadphones")
```


## Terminology check

- Simple vs. complex harmonic motion
- Various waveshapes - sine, square, sawtooth
- Noise - white, pink
- Filters - high-pass, low-pass etc.

----

![A sine wave](images/sine.jpg){height=80%}

----

![Waveshapes](images/waveshapes.png){height=85%}

----

![White noise and pink noise](images/noise.png){height=80%}


---

![A minimal subtractive synth](images/simple-subtractive-1.png){height=60%}

--------


![Filter types](images/filter-types-1.gif){height=85%}

---

![Filter types](images/filter-types.jpg){height=85%}

---

![Filter slope [@Everest:2009aa] determined by the number of 'poles' in the filter design---each pole contributes 6dB](images/filter-slope.png){height=75%}

----

![Filter resonance](images/filter-resonance.jpg){height=85%}

---

![Filter resonance](images/resonance2.png){height=70%}

---

![A self-oscillating filter [see @Roads:1996aa]](images/resonance3.png){height=80%}


## Video examples

[SQUELCH (Roland TB-303, MC-202, TR-606, Doepfer Dark Energy, Dark Time)](https://youtu.be/UbF29k-He4U)

[Polivoks - Russian Analog synth from the 80's demo](https://youtu.be/qWwSf-HCSko)

[Klangbau / Hordijk Twin Peak Ping Demo (Eurorack VCF)](https://youtu.be/0bImXyKv18A)

------

![A minimal subtractive synth](images/simple-subtractive-1.png){height=60%}

--------

![Two oscillators == greater potential for harmonic complexity](images/simple-subtractive-2.png){height=80%}

---

![The Roland SH-101](images/sh101.png){height=80%}

---

 
## An envelope generator (EG)
 
![An envelope generator; see @Russ:2009aa.](images/envelope-generator.gif){height=70%}

## Decay (1-stage) envelopes

A video example of [a simple envelope with a single control for decay](https://youtu.be/HYCt1FV3bM4).


## EG controlling amplitude

```
┌────────────┐    ┌────────────┐    ┌────────────┐            
│            │    │            │    │            │            
│ Oscillator │───>│   Filter   │───>│ Amplifier  ├──> Audio   
│            │    │            │    │            │    output  
└────────────┘    └────────────┘    └────────────┘            
                                           ^                  
                                           │                  
                                    ┌────────────┐            
                                    │  Envelope  │            
                                    │ generator  │            
                                    └────────────┘            
```

----

![Two-stage envelope (AD/AR)](images/ad.png){height=80%}

----

## Envelope generators

![ADSR](images/adsr.png){height=80%}

---

## Envelope generators

![ADSR parameters explained](images/adsr-explained.png){height=70%}



## Basic synth
```
┌────────────┐    ┌────────────┐    ┌────────────┐            
│            │    │            │    │            │            
│ Oscillator │───>│   Filter   │───>│ Amplifier  ├──> Audio   
│            │    │            │    │            │    output  
└────────────┘    └────────────┘    └────────────┘            
```

## LFO controlling oscillator frequency
```
┌────────────┐    ┌────────────┐    ┌────────────┐            
│            │    │            │    │            │            
│ Oscillator │───>│   Filter   │───>│ Amplifier  ├──> Audio   
│            │    │            │    │            │    output  
└────────────┘    └────────────┘    └────────────┘            
       ^                                                      
       │                                                      
┌────────────┐                                                
│    LFO     │                                                
│            │                                                
└────────────┘                                                
```

* This is an example of modulation [@Reid:2000aa].
* The LFO could be modulating the frequency of the audible oscillator == vibrato.
* If the oscillator is outputting a pulse wave the LFO could modulate the pulse width $\rightarrow$ pulse width modulation, or PWM.

## LFO controlling filter cutoff
```
┌────────────┐    ┌────────────┐    ┌────────────┐            
│            │    │            │    │            │            
│ Oscillator │───>│   Filter   │───>│ Amplifier  ├──> Audio   
│            │    │            │    │            │    output  
└────────────┘    └────────────┘    └────────────┘            
                         ^                                    
                         │                                    
                  ┌────────────┐                              
                  │    LFO     │                              
                  │            │                              
                  └────────────┘                              
```

## LFO controlling amplitude $\rightarrow$ tremolo
```
┌────────────┐    ┌────────────┐    ┌────────────┐            
│            │    │            │    │            │            
│ Oscillator │───>│   Filter   │───>│ Amplifier  ├──> Audio   
│            │    │            │    │            │    output  
└────────────┘    └────────────┘    └────────────┘            
                                           ^                  
                                           │                  
                                    ┌────────────┐            
                                    │    LFO     │            
                                    │            │            
                                    └────────────┘            
```

## Scaling

![A frequency which is constant over time.](images/scaling1.png){height=70%}

## Scaling
![A frequency which modulates over time; depending on the speed of the modulation this might be perceived as vibrato.](images/scaling2.png){height=70%}

## Scaling
![In many audio programming languages [@Roads:1996aa], a standard bipolar wave has a default mul (multiple) of 1, which equates to 100% amplitude [@Cottle:2013aa]. The wave shown here starts at 0, and has a range from 1 to -1.](images/scaling3.png){height=70%}

## Scaling
![We can specify the starting point of the parameter (in this case, 200Hz) and the amount by which it is modulated (in this case, 10Hz). The result is a wave which modulates $\pm$ 10Hz from a base frequency of 200Hz [@Wilson:2011aa].](images/scaling4.png){height=70%}

<!--

## Installing Obsidian
Why?


## What is strategic AI collaboration?

- Using LLMs (e.g. ChatGPT, Copilot, Claude) to:
  - Generate code
  - Explore creative ideas
  - Debug and optimise
- Not just copying — **filtering, refining, and reflecting**

---

## Assessment criteria

**AI collaboration portfolio (25%)**  
- Strategic use of prompts  
- Critical filtering of outputs  
- Documentation of decisions  
- Reflective commentary

---

## Prompting tips

- Be specific: _“Create a SuperCollider synth with PWM and LFO”_  
- Iterate: refine based on output  
- Ask for alternatives: _“Can you suggest three envelope shapes?”_  
- Use follow-ups: _“Why did you choose that filter?”_

---

## Hands-on activity

1. Use an LLM to:
   - Generate envelope code
   - Explore synth ideas (e.g. emulate Polivoks)
   - Debug your SuperCollider patch
2. Save:
   - Prompts
   - Responses
   - Notes on what you accepted, modified, or rejected

---

## Documenting your collaboration

- Use Obsidian or Markdown
- Include:
  - Prompt history
  - Screenshots or code snippets
  - Reflections on usefulness
  - Decisions made

---


## Example reflection

> I asked ChatGPT to create a tremolo effect. The initial code used `SinOsc`, but I modified it to use `LFTri` for a sharper modulation. I rejected its envelope suggestion as it didn’t suit my synth’s timing.

-->

## Why use GitHub?

- Version control for your code  
- Track changes over time  
- Collaborate and share  
- Document your creative process

If you don’t yet have a GitHub account, you need to create one…

---


## Create a GitHub Account
* Go to <https://github.com/>
* Click ‘Sign Up’
* Choose a username, enter your email, and create a password
	* Pick a username that you will be able to share with academic staff and potential employers; you can change it in the future.
	* You can use any email you wish and you don’t need to share it with us; just make sure you can access that email now so you can verify it. You can change your email in the future.
	* Capture your password so you can sign in elsewhere
* Verify your email address

## Sign in to GitHub Desktop
* Launch GitHub Desktop on the Mac (Spotlight search is Command+space)
* Click **Sign in to GitHub.com**
* Authorise access to your GitHub account

## Create a new repository (AKA repo)
* Click `File > New Repository` to create a new one 
* Give it a name (e.g. creative-systems-portfolio)
* Choose a local path
* Initialise with a `README.md` and publish

## Make your first commit
* Open the repo folder on the Mac
* Edit the README.md to include: 
	* Your name
	* Your goals for the module
	* A short reflection on creative systems
* Save the file
* In GitHub Desktop, write a commit message and click Commit to main
* Click **Push origin** to upload your changes to GitHub

## Share your repo with the academic staff
* Go to Your Repository
	* Navigate to your personal repo on github.com
* Click on the ‘Settings’ Tab
	* Found near the top-right of your repo page
* Scroll to ‘Collaborators’
	* Under the Access section in the left-hand menu
* Click ‘Add People’
	* Type mattbport into the search box
* Select the Correct Username
	* Confirm it’s Matt Bellingham’s account
* Click ‘Add’
	* Matt will receive an invitation to access your repo

---

## First commit with SuperCollider code

- Add:
  - Synth code
  - Add a Markdown document with some notes
- Write a clear commit message:
  > “Initial subtractive synth with Env.linen and LFO modulation”

---

## Pushing to GitHub

- Click **Push origin** to upload your work  
- Your code is now backed up and shareable  
- You can revert changes or track progress

---

## Get the GitHub Student Developer Pack

As you're a student, you can apply for the **GitHub Student Developer Pack**; a free bundle of tools and resources to support your learning and creative projects.

### How to apply

- Visit <https://github.com/education>
- Click **Get Student Benefits**
- Sign in with your GitHub account
- Verify your student status (e.g. university email or student ID)


## Best practices

- Commit regularly  
- Use meaningful messages  
- Include `README.md`  
- Document AI contributions clearly

### Next steps

- Continue committing as your project evolves  
- Use GitHub to showcase your work  
- Consider using GitHub Pages for documentation or demos


## References {.allowframebreaks}