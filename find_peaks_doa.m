function [aoa,spectral_values]=find_peaks_doa(angle_scan_range,spectral_values,no_sources)
    no_angles=length(angle_scan_range); %no of angles
    indices_window=[1,2,3]; %sliding window
    
    peak_angles=zeros(no_angles,1); %vector storing peak angles
    peak_spectral_values=zeros(no_angles,1); % vector storing peak values corresponding to peak angles
    peaks_count=0; % no of peaks
    
    while indices_window(3)<no_angles
        if(spectral_values(indices_window(2))>=spectral_values(indices_window(1)) && spectral_values(indices_window(2))>=spectral_values(indices_window(3)))
            peaks_count=peaks_count+1;
            peak_angles(peaks_count)=angle_scan_range(indices_window(2));
            peak_spectral_values(peaks_count)=spectral_values(indices_window(2));
        end
        indices_window=indices_window+[1,1,1];
    end

    aoa=peak_angles(1:peaks_count);
    spectral_values=peak_spectral_values(1:peaks_count);
    [spectral_values,indices]=sort(spectral_values, 'descend');
    aoa=aoa(indices);
    spectral_values=spectral_values(1:no_sources);
    aoa=aoa(1:no_sources);

end




    

