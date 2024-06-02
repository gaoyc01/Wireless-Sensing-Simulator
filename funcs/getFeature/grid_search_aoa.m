function theta = grid_search_aoa(CSI, lambda, lambda_list)
    % grid_search_aoa
    % Input:
    %   - CSI is the CSI used for ranging; [T S A L]
    %   - lambda is the wavelength corresponding to the center frequency of the signal [1 1]
    %   - lambda_list is the subcarrier lambda parameters; [1 S]
    % Output:
    %   - tof is the rough time-of-flight estimation result; [1 1]   

    % Select the csi data of three antennas as input.
    ue_csi1=CSI(:,:,1);
    ue_csi2=CSI(:,:,2);
    ue_csi3=CSI(:,:,3);
    % Conjugate-multiply the CSI received by the two antennas.
    csi_data1=ue_csi3.*conj(ue_csi1);
    csi_data2=ue_csi2.*conj(ue_csi1);
    % Find the most suitable angle by means of grid search.
    distance1=[];
    distance2=[];
    intervals=pi/180;
    for theta=0:intervals:pi
        distance1=[distance1,real(csi_data1*(exp(-1j*2*pi*lambda/2*cos(theta)./lambda_list))')];
        distance2=[distance2,real(csi_data2*(exp(-1j*2*pi*lambda/2*cos(theta)./lambda_list))')];
    end
    distance1=distance1.';
    distance2=distance2.';
    [~,theta1]=max(distance1);
    [~,theta2]=max(distance2);
    theta1=theta1*pi/180;
    theta2=theta2*pi/180;
    xAoA = mean(cos(theta2),2);
    yAoA = mean(cos(theta1),2);
    if (xAoA>0)&&(yAoA>0)
        theta=atan(xAoA/yAoA);
    elseif (xAoA>0)&&(yAoA<0)
        theta=atan(xAoA/yAoA);
    elseif (xAoA<0)&&(yAoA>0)
        theta=atan(xAoA/yAoA)+pi;
    else
        theta=atan(xAoA/yAoA)-pi;
    end
    % Calculate the average of the aoa estimates at different sampling points.
    theta = theta/pi*180;
end