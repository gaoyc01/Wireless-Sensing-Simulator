function [s,f,t] = naive_spectrum(csi_data, sample_rate, visable,UI)
    % naive_spectrum
    % Input:
    %   - csi_data is the CSI used for STFT spectrum generation; [T S A L]
    %   - sample_rate determines the resolution of the time-domain and
    %   frequency-domain;
    % Output:
    %   - stft_mat is the generated STFT spectrum; [sample_rate/2 T]

    % Calculate mean power of the signal over subcarriers, antennas, and links
    csi_data = mean(csi_data .* conj(csi_data), [2 3 4]);
    % Time samples of the CSI data
    
    T = size(csi_data, 1);
    disp(T)
    % Define window size (must be <= T)
    windowSize = min(T, 128);  % Choose a smaller window size if T < 128
    
    % Define window function and overlap
    window = hamming(windowSize);
    overlap = round(windowSize / 2);  % 50% overlap
    
    % Calculate the STFT and visualization.
    [s,f,t] = stft(csi_data, sample_rate, 'Window', window, 'OverlapLength', overlap);
    
    % Visualization (optional).
    if visable
        stft(csi_data, sample_rate, 'Window', window, 'OverlapLength', overlap);
    end
    if size(t,1) == 1
        t = (0:1/sample_rate:1-1/sample_rate).';
        s = repmat(s,1,sample_rate);
    end
%     mesh(UI,t,f,abs(s).^2)
%     view(UI, 2)
%     axis(UI, 'tight')
    surf(UI, t, f, abs(s).^2, 'EdgeColor', 'none')
    view(UI, 2)
    axis(UI, 'tight')

%     view(2), axis tight
%     window = 4;
%     noverlap = window/2;
%     nfft = window;
%     [s, f, t, p] = spectrogram(csi_data, window, noverlap, nfft, sample_rate);
%     figure
%     imagesc(UI,t, f, 20*log10((abs(s))));xlabel('Samples'); ylabel('Freqency')
%     title('使用spectrogram画出的短时傅里叶变换图形')
%     colorbar;
%     plot(UI,imagesc(t, f, 20*log10((abs(s))));xlabel('Samples'); ylabel('Freqency'))
end
