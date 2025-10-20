---
title: Introduction to *Audio Programming*
subtitle: Audio Programming week 1
author: Matt Bellingham -- <matt.bellingham@port.ac.uk>
institute: University of Portsmouth
date: 29 September 2025
---

## Today's session

- **Part 1:** Hands-on SuperCollider workshop
- **Break:** 10:30--10:45
- **Part 2:** Module overview & AI collaboration strategies

### Tasks to complete before next week
- Install **SuperCollider** on your own computer
- Install **Obsidian** on your own computer
- Create a **GitHub account** ready for week 2
- Make sure you have access to **Copilot Chat**

## Introductions
- What led you to choosing this module?
- What audio work have you done in the past?
- What audio programming environments have you had the opportunity to use before?
- What audio/music or other creative tools do you find inspiring or interesting?

## Aims of the first half of the session
- We can discuss our understanding of core audio theory and related terminology while creating a basic synth
- Review, and experiment with, the building blocks used in subtractive synthesis
- Explore the use of *SuperCollider* in the creation of simple subtractive synths

## Background task
This is a hands-on session to look at the syntax and basic functionality of SuperCollider. You will need to practice using SC in-between sessions, just as you would if you were learning an instrument.


## Subtractive synthesis
![Subtractive synthesis starts with a harmonically complex sound source, then removes or takes away (i.e. subtracts) harmonic content using a filter [@Russ:2009aa].](images/sculptor.png){height=70%}


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

![Filter types](images/filter-types-1.gif){height=85%}

---

![Filter types](images/filter-types.jpg){height=85%}

---

![A minimal subtractive synth](images/simple-subtractive-1.png){height=60%}

--------


## Audio programming languages
A programming language designed for audio and/or music work.
The language contains relevant abstractions for the user’s convenience.

The language 'understands' the tools and protocols that the user will need - oscillators, filters, envelopes, MIDI, OSC, etc. The user does not need to build these from scratch.

Most audio programming languages differentiate between audio signals and control signals.

## Audio programming languages

### Graphical languages
* Examples---Max [@cycling74Max2024], Pure Data [@puckettePureData2024]
* Typically use a unidirectional patch-cable metaphor for output/input---quick to learn
* Visual, and therefore easier to 'read' signal flow
* Large projects can become hard to read, manage, and change

## Audio programming languages

### Text-oriented languages
* Examples---SuperCollider [@mccarthySuperCollider2024], Csound [@Vercoe:2014aa], ChucK [@Wang:2008aa]
* Not visual, making them initially harder to 'read'
* Basic syntax needs to be learned up-front
* Highly expressive, and allows for significant efficiencies


## Module structure

All our sessions will run from 9am to 12pm on Monday mornings in TB1. The first six weeks will blend lecture content with workshops. The remaining sessions will consist of a two-hour workshop with drop-in time as you develop your artefact.

- Lectures **define**
- Workshops **implement**
- Drop-ins **support**


## Terminology check

*Don't worry if most or all of these topics are unfamiliar!*

- Sound propagation
- Wavelength, frequency, amplitude
- Harmonic content and the harmonic series
- Envelopes
- Localisation
- Decibels
- Equal loudness contours
- Logarithms
- Metering, including reference levels
- Synchronisation (e.g. SMPTE, word clock)
- MIDI


## Module topics at a glance
* Audio theory
* Digital audio
* Digital synthesis
* Object-oriented design
* Delay-based effects
* Spectral audio processing
* Software project management and version control
* OSC
* Processing audio dynamics
* Generative audio

## Your AI use up to now

What LLMs do you use? How often? For what?

## AI in programming - paradigm shift

The role of the programmer is changing fundamentally. Instead of focusing solely on writing code, the modern developer is becoming an orchestrator of AI tools.

* You will be a supervisor, not a simple typist [@orchardBabyStepsSemiautomatic2025; @spiessHowUseClaude2025].
* Your job is to provide clear direction, manage the process, and ensure quality [@orchardBabyStepsSemiautomatic2025; @reedWaterfall15Minutes2025; @spiessHowUseClaude2025].
* The AI handles the repetitive, tedious parts of the work, leaving you to focus on design and architecture [@grebenyukkeanClaudeCodeExperience2025].

## The Plan/Execute Cycle

A common theme amongst experienced AI-augmented programmers is the use of a structured workflow.

* **Plan:** Start by writing a detailed specification or plan.md file [@ledbetterUsingPlanExecute2025; @orchardBabyStepsSemiautomatic2025; @reedMyLLMCodegen2025].
* **Execute:** Use the AI to implement the plan, with you in the loop, supervising and providing feedback [@reedLLMCodegenHeros2025].
* **Trust and Tools:** The more you trust the AI, the more you can automate. Some even use the AI as a universal computer interface, trusting it with full filesystem access [@steinbergerClaudeCodeMy2025].

## Test, document, communicate

As code generation becomes cheap and fast, the tiebreaker for successful products is shifting from code elegance to user experience [@reedMyLLMCodegen2025]. This means new skills are paramount.

* **Defensive Coding:** You need to catch errors introduced by AI agents [@ronacherAIChangesEverything2025].
* **Strategic Thinking:** The focus moves to architectural decisions and problem-solving [@ballAmpNowAvailable2025]. The AI can handle the 'paint-by-numbers' work.
* **Effective Prompting:** Strong writing skills are critical. Your ability to craft clear, concise, and detailed prompts is a key factor in the AI's success [@reedWaterfall15Minutes2025].

## The spectrum of AI use

Not everyone approaches AI use in the same way. These articles show a few interesting philosophies.

* Some developers, like Geoffrey Litt, use AI for 'vibe coding', prioritising fun and personal utility over production-level techniques [@littStevensHackableAI2025].
* Others, like Max Woolf, are more pragmatic, viewing LLMs as a powerful but not universal tool to be used via API for specific problem-solving tasks, dismissing 'vibe coding' as unprofessional [@woolfExperiencedLLMUser2025].
* Ultimately, AI in coding is not a fundamental shift in abstraction, but a change in 'velocity,' allowing you to spend more time on design and less on the implementation grind [@grebenyukkeanClaudeCodeExperience2025; @orchardBabyStepsSemiautomatic2025].

## AI in programming - examples

* <https://harper.blog/2025/04/17/an-llm-codegen-heros-journey/>
* <https://lucumr.pocoo.org/2025/6/4/changes/>
* <https://maryrosecook.com/blog/post/become-an-ai-augmented-engineer>
* <https://me.micahrl.com/blog/llm-plan-execute-cycle/>
* <https://blog.lmorchard.com/2025/06/07/semi-automatic-coding/>
* <https://harper.blog/2025/02/16/my-llm-codegen-workflow-atm/>

# Module assessment

## Learning outcomes
LO1 Specify and design an original audio software artefact.

LO2 Make and justify decisions in the implementation of an original audio software artefact.

LO3 Demonstrate practical knowledge and understanding of programming and computational sound concepts.

LO4 Explore and critically evaluate your work against stated aims.


## Assessment
* **Artefact (50%)** - SuperCollider tool
* **AI collaboration portfolio (25%)** - Markdown doc
* **Viva voce (25%)** - Live demonstration & discussion

**Submission deadline:** Wednesday 14th January 2026 at 3pm

The brief is available on Moodle.



## Key texts with library links

[The Audio Programming Book](https://search.ebscohost.com/login.aspx?direct=true&db=nlebk&AN=324701&site=eds-live) [@Boulanger:2010aa]

[The SuperCollider Book](https://search.ebscohost.com/login.aspx?direct=true&db=edswah&AN=000316916500011&site=eds-live) [@Wilson:2011aa]

[The Theory and Technique of Electronic Music](https://msp.ucsd.edu/techniques.htm) [@Puckette:2006aa]

[Microsound](https://search.ebscohost.com/login.aspx?direct=true&db=cat01619a&AN=up.1075347&site=eds-live) [@Curtis:2004aa]

[The Computer Music Tutorial](https://search.ebscohost.com/login.aspx?direct=true&db=cat01619a&AN=up.1515278&site=eds-live) [@Roads:1996aa]

## Tasks for next week

* Install **SuperCollider** and explore the patches made today: <https://supercollider.github.io/>
* Install **Obsidian** for documentation: <https://obsidian.md/>
* Create a **GitHub account:** <https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github>
* Check your access to **Copilot Chat**: <https://m365.cloud.microsoft/>

If you have any questions please let me know at <matt.bellingham@port.ac.uk>


## References {.allowframebreaks}