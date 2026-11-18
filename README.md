# Speech-Coding-Using-LPC
Speech coding with Linear Predictive Coding (LPC) in MATLAB, inspired by the LPC10
coder used in the 1978 Speak & Spell toy. Homework 1 for the DAAP course
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

Requires MATLAB with the Signal Processing Toolbox.

## Files

| File | Purpose |
|---|---|
| `lpc_test.m` | Main script: file selection, parameters, encode, decode |
| `encoder.m`, `decoder.m` | LPC encoder and decoder |
| `voicedframedetection.m` | Voiced / unvoiced frame detection |
| `pitchdetectionamdf.m` | Pitch estimation with AMDF |
| `generateexcitationsignal.m` | Excitation signal generation |
| `input/` | Sample audio files (letters of the alphabet, short phrases) |
| `report.pdf` | Full report with method, results and limitations |
