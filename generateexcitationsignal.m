function excite = generateexcitationsignal(voicedIdx, gains, pitch, windowLength, hopSize)
%%generateexcitationsignal(voicedIdx, gains, pitch, winLen)
% This function generates the excitation signal for LPC-10 coding that
% depends on voiced (train of pulses) or unvoiced (random noise) signals
% Arguments:
%   - voicedIdx
%   - gains
%   - pitch
%   - winLen
%
% Outputs
%   - excite
%
% DAAP HW1 2025
% Mirco Pezzoli

excite = zeros((length(voicedIdx) - 1) * hopSize + windowLength, 1);

for ii = 1:length(voicedIdx)
    % defining indexes
    startIndex = (ii - 1) * hopSize + 1;
    endIndex = startIndex + windowLength - 1;

    if voicedIdx(ii) == 1 % if voiced
        pulse_position = startIndex : pitch(ii) : endIndex;
        excite(pulse_position) = gains(ii);
    else % if unvoiced
        excite(startIndex:endIndex) = gains(ii) * randn(windowLength, 1);
    end
end

end