---
title: 'Modifiers and additive synthesis'
subtitle: Audio Programming week 3
author: Matt Bellingham -- <matt.bellingham@port.ac.uk>
institute: University of Portsmouth
date: Monday 13th October 2025
---

## Recap from last week

* Harmonic complexity via various waveshapes
* White and pink noise
* Filters; we focussed on low-pass and high-pass filters
* Envelope generators


----

## Recap

![Filter resonance](images/filter-resonance.jpg){height=85%}

---

## Recap

![Filter resonance](images/resonance2.png){height=70%}

---

## Recap

![A self-oscillating filter [see @Roads:1996aa]](images/resonance3.png){height=80%}

 
## An envelope generator (EG)
 
![An envelope generator; see @Russ:2009aa.](images/envelope-generator.gif){height=70%}


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

------

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

## Strategic AI collaboration

You are expected to use AI tools (e.g. Copilot, ChatGPT, GitHub Copilot) to support your audio programming practice in a strategic and reflective manner.

**Appropriate uses include:**
- Generating and refining SuperCollider code for synthesis and modulation
- Troubleshooting and optimising signal flow or parameter scaling
- Exploring alternative synthesis approaches (e.g. additive, subtractive, granular)

**You must critically document:**
- The prompts or queries used and their intent
- How you evaluated and modified AI-generated outputs
- Any limitations or errors in the AI’s suggestions

## Strategic AI collaboration

**Your AI collaboration portfolio should demonstrate:**
- Technical understanding of your artefact
- Clear rationale for AI use
- Critical reflection on the role of AI in your creative and technical decisions

**Your viva voce will include discussion of:**
- Your synthesis design choices
- Your engagement with AI tools
- Your ability to explain and justify your workflow

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



## The harmonic series
![Modes of vibration](images/modes.gif)

## The harmonic series
![Fourier synthesis](images/fourier.gif)

## Additive synthesis

<https://youtu.be/ev7VRaVpUpA?si=hYiJbR7RzMUogU5L>

<https://youtu.be/2rqn4bYFUZU?si=ypl8xM6053alKUIp>

<https://youtu.be/J4yKD5fvRbQ?si=lN5sj-QsC0XKo2OW>

<https://youtu.be/ri3l4QUWlbE?si=phA8GjDYlrnwD0Ce>

<https://youtu.be/htF2GzI7Q74?si=cTkbxNKAq-1zjbD9>

<https://youtu.be/SmntcyD_GhI?si=mQ7NeHNdtp7tBQON>

## Sawtooth

![Sawtooth wave: $1 / n$ when $n$ is even or odd](images/saw.png){height=80%}


## Square

![Square wave: amplitude of $1/n$ when $n$ is odd, or $0$ when $n$ is even](images/square.png){height=80%}




## References {.allowframebreaks}
