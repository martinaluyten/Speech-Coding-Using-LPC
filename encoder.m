function encoder (fileName, path, wl, hs)
%% LPC-encode
%
% DAAP course 2025
% Mirco Pezzoli
% clear
close all
clc

%% Define parameters
sampleRate = 8000;

% Reading input audio signal
[s, fs] = audioread(append(path, fileName));

% Work at 8kHz sampling rate
signal = resample(s, sampleRate, fs);

% Normalize the signal with respect to peak value
signal = signal / max(abs(signal));
 
% Apply a pre-emphasis filter as highpass filter
b = [1, -0.975];
signal = filter(b, 1, signal);                   % pre-emphasis filtering

% STFT Parameters
% suggested parameters 256-sample window length and hopsize, hamming window
windowLength = wl;
hopSize = hs;

window = hamming(windowLength);

% LPC-10 parameters
ps_lpcVoiced = 10;
ps_lpcUnvoiced = 4;

% Pitch estimation parameters
signalLength = length(signal);
nFrame = floor((signalLength - windowLength) / hopSize ) + 1;
pitch = zeros(nFrame, 1);

% Optionally low pass the prediction error with FIR filter with cut off at
% 800 Hz
b_lowpass = fir1(10, 800 / (sampleRate * 0.5), "low");

doPlot = false; % Activate plots

coeffs = [];
gains = zeros(nFrame, 1);
power = zeros(nFrame, 1);

%% Esimate voiced frame
[voicedIdx, ~] = voicedframedetection(signal, window, hopSize);

%% Estimate LPC filters

for ii = 1:nFrame
    
    % Extract a frame from the signal

    % Find the indexes of the framed signal
    frameIndexes = (ii - 1) * hopSize + 1 : (ii - 1) * hopSize + windowLength;
    signalFramed = signal(frameIndexes) .* window;

    % Compute autocorrelation
    [r, ~] = xcorr(signalFramed);
    centralLag = ceil(length(r) / 2);
    
    % Compute the whitening filter parameters using the function levinson
    % (see doc levinson)
    
    if voicedIdx(ii) == 1
        ps = ps_lpcVoiced;
    else
        ps = ps_lpcUnvoiced;
    end

    a = levinson(r(centralLag:end), ps);

    % Avoid NaNs
    a(isnan(a)) = 0;

    coeffs{ii} = a;

    
    % Compute the prediction error using filter
    e = filter(a, 1, signalFramed);
    t = 0:1/sampleRate:(windowLength-1)/sampleRate;

    % Plot the Magnitude of the signal spectrum, and on the same graph, the
    % the LPC spectrum estimation (remember the definition of |E(omega)|)
    if doPlot
        
        % Compute the shaping filter H using freqz function
        [H, w] = freqz(1, a, windowLength);
        fH = w * sampleRate / (2 * pi);

        %frequency axis
        fAx = 0:sampleRate/(windowLength-1):sampleRate;

        % Compute the DFT of the original signal
        % FFT of the signal
        S = fft(signalFramed);
        
        E = fft(e);

        % Re-scale to Nyquist for plot
        S(windowLength / 2 + 1:end) = [];
        E(windowLength / 2 + 1:end) = [];
        fAx(windowLength / 2 + 1:end) = [];
        
        figure(1), clf
        subplot(4,1,1)
        %Plot of the FFT of the original signal
        plot(fAx, abs(S), "LineWidth", 1);
        hold on;
        title("DFT of the original signal");
        xlabel("Frequency [Hz]"), ylabel('Magnitude');
        
        %Spectral matching of the filter
        plot(fH, abs(H), "red", "LineWidth", 1);
        legend("Original Spectrum", "LPC Estimate");
        hold off

        subplot(4,1,2), hold on
       
        % plot prediction error (time domain)
        plot(t * 1000, e, "LineWidth", 1); 
        xlabel("Time [ms]"), ylabel("Amplitude");
        title("Prediction error in time-domain") 

        % Plot the prediction error magnitude spectrum
        subplot(4,1,3)
        %Plot prediction error (frequency domain)
        plot(fAx, abs(E), "LineWidth", 1);
        xlabel("Frequency [Hz]"), ylabel('Magnitude');
        title ("Prediction error in frequency-domain");
        
    end
    % Pitch estimation for voiced signals
    if voicedIdx(ii) == 1
        pitch(ii) = pitchdetectionamdf(e);
        % Optionally low pass the error
         e = filter(b_lowpass, 1, e);
    end

    % Plot the predition error e in time
    if doPlot
        figure(2)
        plot(t * 1000, e, "LineWidth", 1);
        xlabel("Time [ms]"), ylabel("Amplitude");
        title("Prediction error in time-domain (filtered if it's a voiced frame)") 
    end

    
    if voicedIdx(ii) == 1
        % Compute the gain for a pitched sound
        lim = floor(windowLength./pitch(ii)).*pitch(ii);
        power(ii) = (1/lim).*(e(1:lim)'*e(1:lim));
        gains(ii) = sqrt(power(ii)*pitch(ii));

    else
        % Compute the gain for unvoiced sounds
        gains(ii) = sqrt(mean(e.^2));
    end
  
end

%% Save encoded data
save("encodedData.mat", "windowLength", "hopSize", "gains", "pitch", "voicedIdx", "coeffs", "sampleRate", "signal");