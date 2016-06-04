%% Figure 1 - Net load and low pass signal plots

%% Clearing all the previous variables and data
clear all
clc 
show_plots = 1;
printfigs = 1;
%% Function to load the demand data to the program
if isunix
    Netload_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/Netload.xlsx','2015');
    %Netload_Cast_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/NetloadForecast.xlsx','2015');
end

if ispc
    Netload_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/Netload.xlsx','2015');
   % Netload_Cast_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/NetloadForecast.xlsx','2015');
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
    Tlow = 360; % Cut off Frequency in minutes
    wlow1_min =  min2rad*(Tlow^-1); % Cut off frequency for Low pass butterworth filter
    w_norm_low1 = wlow1_min*w2wnorm; % Normalized cut off frequency 
    [b1,a1] = butter(2,w_norm_low1,'low');    
    
%%  For loop to calculate storage requirements for each day in a year

for n = 1:1:365
   
    Netload_today = timeseries(Netload_365([((n-1)*288)+1:n*288],1), [0:300:86100]); % Time series data for the net load on a particular day
     
    % Non causal / Zero Phase filter
    lowpass_signal = filtfilt(b1,a1,Netload_today.Data); % Calculating the rating for the battery required based on Netload - Lowpass Signal
    
end
    
    Storage_required = Netload-lowpass_signal;
    k = 1:1:288;
    t_plot = k/12;

if show_plots
    plot(t_plot',Netload_today.Data,'b','LineWidth',2)
    hold on 
    plot(t_plot',lowpass_signal,'r-','LineWidth',2)
    set(gca,'fontsize',14,'XTick',[0 6 12 18 24]);
    xlabel('Hours')
    ylabel('Power(MW)')
    I = legend('$L$','$\tilde{L}_{lp}$')
    set(I,'Interpreter','latex')
end

if printfigs
        if isunix
            saveTightFigure(gcf,'~/Dropbox/Sai - Research Work/Report/SampleFilterPlot.pdf') % Function to remove the white margins added by MATLAB to pdf plots
            %print(gcf,'-dpdf','~/Dropbox/Sai - Research Work/Report/SampleFilterRemPlot.jpg') 
        end
        if ispc
            saveTightFigure(gcf,'C:\Users\Sai\Dropbox\Sai - Research Work/Report/SampleFilterPlot.pdf')
            %print(gcf,'C:\Users\Sai\Dropbox\Sai - Research Work/Report/SampleFilterRemPlot.jpeg') 
        end
end

%% Code to Obtain a required storage plot
% if show_plots
%     
%     figure('Name','Power Capacity')
%     plot(t_plot',Storage_required,'b')
%     hold on 
%     set(gca,'fontsize',14)
%     set(gca,'XTick',[0 6 12 18 24]) % customize axes to hours
%     xlabel('Hours')   
%     ylabel('$P^{(i)}_{k}\ (MW)$','Interpreter','latex')
%     
% end 