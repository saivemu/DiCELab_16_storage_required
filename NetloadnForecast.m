%% Net load and Netload Forecast comparision plot from the available data 

%% Clearing all the previous variables and data
clear all
clc 
show_plots = 1;
printfigs = 1;
%% Function to load the demand data to the program
if isunix
    Netload_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/Netload.xlsx','2015');
    Netload_Cast_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/NetloadForecast.xlsx','2015');
end

if ispc
    Netload_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/Netload.xlsx','2015');
    Netload_Cast_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/NetloadForecast.xlsx','2015');
end
%% Filter
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
    Tlow = 300; % Cut off Frequency in minutes
    wlow1_min =  min2rad*(Tlow^-1); % Cut off frequency for Low pass butterworth filter
    w_norm_low1 = wlow1_min*w2wnorm; % Normalized cut off frequency 
    [b1,a1] = butter(2,w_norm_low1,'low'); 
 %% Netload and Netload Forecast signals
 
    n = 200; % Day 'n' of a year
   
    Netload_today = timeseries(Netload_365([((n-1)*288)+1:n*288],1), [0:300:86100]); % Time series data for the net load on a particular day
    Netload = Netload_today.data;
    Netload(isnan(Netload))= nanmean(Netload);
    Netload_Cast_today = timeseries(Netload_Cast_365([((n-1)*288)+1:n*288],1), [0:300:86100]);
    NetloadForecast = Netload_Cast_today.Data;
    NetloadForecast(NetloadForecast==0) = mean(NetloadForecast);
     
    % Non causal / Zero Phase filter
    lowpass_signal = filtfilt(b1,a1,Netload); % Calculating the rating for the battery required based on Netload - Lowpass Signal
    lowpass_Forecast = filtfilt(b1,a1,NetloadForecast);
   
if showplots  
    plot(Netload,'linewidth',2);
    hold on
    plot(NetloadForecast,'r','linewidth',2);
    set(gca,'fontsize',14)
    xlabel('K')
    ylabel('Netload(MW)')
    legend('Netload','Netload Forecast')
end 

if printfigs
    if isunix
        saveTightFigure(gcf,'~/Dropbox/Sai - Research Work/Report/OperatorNetloadnForecast.pdf')
        %print(gcf,'-dpdf','~/Dropbox/Sai - Research Work/Report/OperatorPOVSignal.pdf') 
    end
    if ispc
        saveTightFigure(gcf,'C:\Users\Sai\Dropbox\Sai - Research Work/Report/OperatorNetloadnForecast.pdf')
        %print(gcf,'-dpdf','~/Dropbox/Sai - Research Work/Report/OperatorPOVSignal.pdf') 
    end 
end