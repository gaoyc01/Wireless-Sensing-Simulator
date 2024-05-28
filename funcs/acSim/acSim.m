function [per, ber, chanEst] = acSim(chanModel, vhtConfig, numPkt, noise)
    % acSim performs the end-to-end simulation based on the 802.11ac protocal.
    
    errFlag = zeros(numPkt, 1);
    ber = zeros(numPkt, 1);
    per = 0;
    dict = containers.Map({'CBW20', 'CBW40', 'CBW80', 'CBW160'}, {56, 114, 242, 484});
    nS = dict(vhtConfig.ChannelBandwidth);
    nSTS = vhtConfig.NumSpaceTimeStreams;
    nR = chanModel.info.NumReceiveElements;
    chanEst = zeros(nS, nSTS, nR);
    ind = wlanFieldIndices(vhtConfig);
    ofdmInfo = wlanVHTOFDMInfo('VHT-Data', vhtConfig);
    for n = 1:numPkt
        % Generate random bytes.
        txPSDU = randi([0 1], vhtConfig.PSDULength * 8, 1);
        % Generate the transmitter wave.
        txWave = wlanWaveformGenerator(txPSDU, vhtConfig);
        reset(chanModel);
        % Multipath fading channel.
        rxWave = chanModel([txWave; zeros(ofdmInfo.FFTLength + ofdmInfo.CPLength, nSTS)]);
        % AWGN channel.
        rxWave = awgn(rxWave, noise); % The power of the rxWave is assumed as 0 dBW.
        % Estimate the coarse packet offset.
        coarsePktOffset = wlanPacketDetect(rxWave, vhtConfig.ChannelBandwidth);
        % Discard the packet if the packet boundary is not detected.
        if isempty(coarsePktOffset)
            per = per + 1;
            ber(n, 1) = 1;
            errFlag(n, 1) = 1;
            continue;
        end
        % Estimate the coarse frequency offset from the L-STF field.
        lSTF = rxWave(coarsePktOffset + (ind.LSTF(1):ind.LSTF(2)), :);
        coarseFreqOffset = wlanCoarseCFOEstimate(lSTF, vhtConfig.ChannelBandwidth);
        % Compensate the coarse frequency offset.
        rxWave = helperFrequencyOffset(rxWave, chanModel.SampleRate, -coarseFreqOffset);
        % Estimate the fine packet offset from the Non-HT field.
        nonHT = rxWave(coarsePktOffset + (ind.LSTF(1):ind.LSIG(2)), :);
        finePktOffset = wlanSymbolTimingEstimate(nonHT, vhtConfig.ChannelBandwidth);
        pktOffset = finePktOffset + coarsePktOffset;
        % Discard the packet if the offset is too large.
        if pktOffset > 50
            per = per + 1;
            ber(n, 1) = 1;
            errFlag(n, 1) = 1;
            continue;
        end
        % Estimate the fine frequency offset from the L-LFT field.
        lLTF = rxWave(pktOffset + (ind.LLTF(1):ind.LLTF(2)), :);
        fineFreqOffset = wlanFineCFOEstimate(lLTF, vhtConfig.ChannelBandwidth);
        % Compensate the fine frequency offset.
        rxWave = helperFrequencyOffset(rxWave, chanModel.SampleRate, -fineFreqOffset);
        % Demodulate the VHT-LTF field for channel estimation.
        vhtLTF = rxWave(pktOffset + (ind.VHTLTF(1):ind.VHTLTF(2)), :);
        vhtLTFDemod = wlanVHTLTFDemodulate(vhtLTF, vhtConfig);
        chanEstPilot = vhtSingleStreamChannelEstimate(vhtLTFDemod, vhtConfig);
        curChanEst = wlanVHTLTFChannelEstimate(vhtLTFDemod, vhtConfig);
        chanEst = chanEst + curChanEst;
        % Recover the data field.
        vhtData = rxWave(pktOffset + (ind.VHTData(1):ind.VHTData(2)), :);
        varVHT = vhtNoiseEstimate(vhtData, chanEstPilot, vhtConfig);
        rxPSDU = wlanVHTDataRecover(vhtData, curChanEst, varVHT, vhtConfig);
        % Calculate the bit error rate and the packet error.
        [numErr, ber(n, 1)] = biterr(txPSDU, rxPSDU);
        per = per + (numErr ~= 0);
    end
    % Get the packet error rate.
    per = per / numPkt;
    % Get the bit error rate.
    ber = mean(ber);
    % Get the average channel estimation H matrix.
    chanEst = chanEst / (numPkt - sum(errFlag));
end


