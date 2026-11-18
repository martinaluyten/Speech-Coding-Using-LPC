# LPC Speech Coding

Speech coding with Linear Predictive Coding (LPC) in MATLAB, inspired by the LPC10
coder used in the 1978 Speak & Spell toy. Homework 1 for the Digital Audio Analysis and Processing course
(Politecnico di Milano, 2025).

Authors: Martina Luyten and Andrea Casati

Course material and template: Mirco Pezzoli (DAAP 2025)

## What it does

**Encoder** (`encoder.m`)
- Resamples the input to 8 kHz, normalises it and applies pre-emphasis
- Splits the signal into overlapping frames
- Detects voiced / unvoiced frames
- Computes the LPC coefficients (autocorrelation + Levinson-Durbin)
- Estimates pitch (AMDF) and gain for each frame
- Saves everything to `encodedData.mat`

**Decoder** (`decoder.m`)
- Builds an excitation signal (pulse train for voiced frames, noise for unvoiced ones)
- Filters it with the LPC coefficients to resynthesise the speech

## How to run

1. Open MATLAB in the project folder.
2. Run `lpc_test.m`.
3. Choose an audio file (try one from `input/`), then enter the window length
   (96-512 samples, 256 suggested) and the hop size.
4. The decoded speech is saved as an 8 kHz audio file.

Requires MATLAB with the Signal Processing Toolbox.

## Audio samples

You can hear the result without running MATLAB:

- `input/` has the original recordings (the letters of the alphabet, a few
  phrases, 44.1 kHz).
- `output/` has the same sounds after LPC encoding and decoding (8 kHz, mono).

Compare, for example, `input/a.mp3` with `output/a.mp3`. The decoded version
sounds robotic, as in the Speak & Spell. The report discusses why.

## Files

| File / folder | Purpose |
|---|---|
| `lpc_test.m` | Main script: file selection, parameters, encode, decode |
| `encoder.m`, `decoder.m` | LPC encoder and decoder |
| `voicedframedetection.m` | Voiced / unvoiced frame detection |
| `pitchdetectionamdf.m` | Pitch estimation with AMDF |
| `generateexcitationsignal.m` | Excitation signal generation |
| `input/` | Original audio recordings |
| `output/` | Decoded audio produced by the coder |
| `report.pdf` | Full report with method, results and limitations |
