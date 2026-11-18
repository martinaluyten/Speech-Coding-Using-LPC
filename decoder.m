function [synthS, excite] = decoder()
%% LPC decoder

close all
clc

%% Load the encoded data
load("encodedData.mat");

% Generate excitation signal
excite = generateexcitationsignal(voicedIdx, gains, pitch, windowLength, hopSize);

% synthS has equal length of excite
synthS = zeros(length(excite), 1);

% Defining window for the usage in the synthesis
window = hamming(windowLength);

for ii = 1:length(voicedIdx)
    startIndex = (ii - 1) * hopSize + 1;
    endIndex = startIndex + windowLength - 1;

    % Select excite signal we need (from startIndex to endIndex)
    exciteFrame = excite(startIndex:endIndex);
    
    synthFrame = filter(1, coeffs{ii}, exciteFrame);
    
    % if windowLength ~= hopSize
        % synthFrame = synthFrame .* window;
    % end
    
    % OLA
    synthS(startIndex:endIndex) = synthS(startIndex:endIndex) + synthFrame;
end

% Apply De-emphasis filter
b = abs([1, -0.975]);
synthS = filter(1, b, synthS);

% Normalization of the synthetised signal
synthS = synthS / max(abs(synthS));

% Play it
soundsc(synthS, 8000);

end
