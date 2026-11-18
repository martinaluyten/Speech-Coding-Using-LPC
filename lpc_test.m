%% DAAP course 2025 - Homework 1: LPC-based Speak and Spell
% Implement the LPC10 speech encoding used in 1978 Speak and Spell toy by
% Texas Instruments. The TMC0280 chip used to synthesize speech using LPC.
% 
% DAAP HW1 2025
% Mirco Pezzoli

clear all
clc

% The user can select an audio file to compute
[fileName, path] = uigetfile({'*.wav;*.mp3', 'Audio Files (*.wav, *.mp3)'},...
    'Select an audio file');

% Input of the window length
while true
    answer = inputdlg('Insert window length in samples (between 96 and 512), 256 samples is suggested:', ...
                      'Window Length Input', [1 50], {'256'});
    
    if isempty(answer)
        error('User cancelled the input.');
    end
    
    wl = str2double(answer{1});
    
    if ~isnan(wl) && isscalar(wl) && mod(wl,1) == 0 && wl >= 96 && wl <= 512
        break; 
    else
        uiwait(warndlg('Invalid input! Please enter an integer between 96 and 512.', 'Invalid Input'));
    end
end

minHop = floor(wl / 8); % 87.5% maximum overlap
maxHop = wl;

% Input of the hop size
prompt = sprintf('Insert hop size in samples (between %d and %d),  %d samples is suggested: ', minHop, maxHop, wl);

while true
    answer = inputdlg(prompt, 'Hop Size Input', [1 50], {num2str(wl)});
    
    if isempty(answer)
        error('User cancelled the input.');
    end
    
    hs = str2double(answer{1});
    
    if ~isnan(hs) && isscalar(hs) && mod(hs,1) == 0 && hs >= minHop && hs <= maxHop
        break;
    else
        uiwait(warndlg(sprintf('Invalid input! Please enter an integer between %d and %d.', minHop, maxHop), 'Invalid Input'));
    end
end



% Encoding the audio file
encoder(fileName, path, wl, hs);

% Decoding the audio file
[synthS, excite] = decoder();

load('encodedData.mat');
 
if length(signal) > length(synthS)
    % Zero padding of synthS in order to plot
    synthS = [synthS; zeros(length(signal) - length(synthS), 1)];
else
    % Zero padding of signal in order to plot
    signal = [signal; zeros(length(synthS) - length(signal), 1)];
end

t = 0:1/sampleRate:(length(signal)-1)/sampleRate; 

subplot(3, 1, 1)
plot(t, signal, "LineWidth", 1);
xlabel("Time [s]"), ylabel("Amplitude");
title("Original signal");

subplot(3, 1, 2)
plot(t, synthS, "red", "LineWidth", 1);
xlabel("Time [s]"), ylabel("Amplitude");
title("LPC synthetised signal");

subplot(3, 1, 3)
plot(t, signal, 'DisplayName', 'Original Signal');
hold on;
plot(t, synthS, 'r', 'DisplayName', 'Synthesized Signal');
xlabel("Time [s]"), ylabel("Amplitude");
title("Original and Synthesized Signals");
legend;
hold off;

audiowrite(fileName, synthS, sampleRate);