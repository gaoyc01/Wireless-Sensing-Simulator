function tof = grid_search_tof(CSI, fc_list)
    % grid_search_tof
    % Input:
    %   - CSI is the CSI used for ranging; [T S A L]
    %   - fc_list is the subcarrier frequency parameters; [1 S]
    % Output:
    %   - tof is the rough time-of-flight estimation result; [1 1]    
    
    % Select the csi data of one antenna as input.
    ue_csi1=CSI(:,:,1);
    % Find the most suitable signal propagation time by means of grid search.
    time_num = size(ue_csi1,1);
    tof_list = [];
    for time = 1:time_num
        taulist = linspace(1e-10,5e-8,195);
        lentau = length(taulist);
        similarity = [];
        for i = 1:lentau
            tau = taulist(i);
            epsilon_e = exp(1j*2*pi*(fc_list)*tau);
            similarity = [similarity, real(ue_csi1(time,:)*conj(epsilon_e)')];
        end
            [~, index] = max(similarity);
        
        tof = taulist(index);
        tof_list = [tof_list, tof];
    end
    % Calculate the average of the tof estimates at different sampling points.
    tof = mean(tof_list,2);
end