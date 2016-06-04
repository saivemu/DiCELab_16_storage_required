%% Figure 1 - Net load and low pass signal plots

%% Clearing all the previous variables and data
clear all
clc 
show_plots = 1;
printfigs = 1;

%% Function to load the demand data
if isunix
    Netload_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/Netload.xlsx','2015');
end

if ispc
    Netload_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/Netload.xlsx','2015');
end

%% Filter Specifications
    Ts_min = 5;  % Sampling time in minutes
    Ts = Ts_min*60 ;% Sampling time in seconds
    T = 24 ; % Time span for which data is being collected in hours
    Tfinal = T*3600 - 300; % Final time for data sampling
    t = [0:Ts:Tfinal] ; % Data being collected at an interval of dt min or Ts 
    ws = (2*pi)/(Ts); % Sampling Frequency in rad/s
    w_nyq = ws/2; % Nyquist Frequency in rad/s 
    min2rad = 2*pi()/60 ; % Converting minutes to 
    w2wnorm = (w_nyq)^-1;

    % Low Pass filter
    Tlow = 360; % Cut off Frequency in minutes
    wlow1_min =  min2rad*(Tlow^-1); % Cut off frequency for Low pass butterworth filter
    w_norm_low1 = wlow1_min*w2wnorm; % Normalized cut off frequency 
    [b1,a1] = butter(2,w_norm_low1,'low'); 

    % Low range bandpass filter

    Tbpl1 = 120; % higher limit for low band pass
    Tbpl2 = 360; % Lower limit for low band pass

    wbpl1 = min2rad*(Tbpl1^-1);
    wbpl2 = min2rad*(Tbpl2^-1);

    w_norm_bpl1 = w2wnorm*wbpl1;
    w_norm_bpl2 = w2wnorm*wbpl2;
    w_bpl = [w_norm_bpl2,w_norm_bpl1];
    [b2,a2] = butter(2,w_bpl,'bandpass');

    % High range bandpass filter 

    Tbph1 = 20; % higher limit 
    Tbph2 = 120; % Lower limit

    wbph1 = min2rad*(Tbph1^-1);
    wbph2 = min2rad*(Tbph2^-1);

    w_norm_bph1 = w2wnorm*wbph1;
    w_norm_bph2 = w2wnorm*wbph2;
    w_bph = [w_norm_bph2,w_norm_bph1];
    [b3,a3] = butter(2,w_bph,'bandpass');
    
    
    
%%  For loop to calculate storage requirements for each day in a year

for n = 1:1:365
   
    Netload_today = timeseries(Netload_365([((n-1)*288)+1:n*288],1), [0:300:86100]); % Time series data for the net load on a particular day
    Netload = Netload_today.data;
    Netload(isnan(Netload))= nanmean(Netload);    
     
    % Non causal / Zero Phase filter
    lowpass_signal = filtfilt(b1,a1,Netload); % Calculating the rating for the battery required based on Netload - Lowpass Signal
    
end
 
Storage_required = Netload-lowpass_signal;
k = 1:1:288;
t_plot = k/12;

if show_plots
    
    figure('Name','Power Capacity')
    plot(t_plot',Storage_required,'b')
    hold on 
    refline(0,max(abs(Storage_required)));
    set(gca,'fontsize',14)
    set(gca,'XTick',[0 6 12 18 24]) % Trying to customize axes to hours
    xlabel('Hours')   
    ylabel('$P^{(i)}_{k}\ (MW)$','Interpreter','latex')
    
end 

if printfigs
    if isunix  
        saveTightFigure(gcf,'~/Dropbox/Sai - Research Work/Report/SamplePreqPlot.pdf') % Function to remove the white margins added by MATLAB to pdf plots
    end
    if ispc
         print(gcf,'C:\Users\Sai\Dropbox\Sai - Research Work/Report/SamplePreqPlot.jpg')
        %saveTightFigure('Power Capacity','C:\Users\Sai\Dropbox\Sai - Research Work/Report/SamplePreqPlot.pdf') % Function to remove the white margins added by MATLAB to pdf plots
    end
end

if show_plots
    figure('Name','Energy Storage')
    plot(t_plot',cumtrapz(t,Storage_required)/3600,'r')
    hold on 
    refline(0,min(cumtrapz(t,Storage_required)/3600));
    set(gca,'fontsize',14)
    set(gca,'XTick',[0 6 12 18 24]) % Trying to customize axes to hours
    xlabel('Hours')   
    ylabel('$E^{(i)}_{k}\ (MWh)$','Interpreter','latex')
        
end
 
if printfigs
    if isunix  
            saveTightFigure(gcf,'~/Dropbox/Sai - Research Work/Report/SampleEreqPlot.pdf')% Function to remove the white margins added by MATLAB to pdf plots
    end
    if ispc
            saveTightFigure(gcf,'C:\Users\Sai\Dropbox\Sai - Research Work/Report/SampleEreqPlot.pdf')     
    end
end