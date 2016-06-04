%% Clearing all the previous variables and data
clear all
clc 
show_plots = 1;
printfigs = 1;
%% Function to load the demand data to the program
if isunix
    Netload_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/Netload.xlsx','2015');
end

if ispc
    Netload_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/Netload.xlsx','2015');
end
%% Filter Parameters

    Ts_min = 5;  % Sampling time in minutes
    Ts = Ts_min*60 ;% Sampling time in seconds
    T = 24 ; % Time span for which data is being collected in hours
    Tfinal = T*3600 - 300; % Final time for data sampling
    t = [0:Ts:Tfinal] ; % Data being collected at an interval of dt min or Ts 
    ws = (2*pi)/(Ts); % Sampling Frequency in rad/s
    w_nyq = ws/2; % Nyquist Frequency in rad/s 
    min2rad = 2*pi()/60 ; % Converting minutes to rad/s
    w2wnorm = (w_nyq)^-1;
    
%% Parametric Study
    % Low Pass filter
    Tlow2 = 180;
    Tlow1 = 450;
    wlow1 = min2rad*(Tlow1^-1);
    wlow2 = min2rad*(Tlow2^-1);
    Pbatt = zeros(27,1);
    Pbattery = zeros(365,1);
    Ebattery = zeros(365,1);
    
    for Tlow = Tlow2:10:Tlow1 % Cut off Frequency in minutes
    
    wlow1_min =  min2rad*(Tlow^-1); % Cut off frequency for Low pass butterworth filter
    w_norm_low1 = wlow1_min*w2wnorm; % Normalized cut off frequency 
    [b1,a1] = butter(2,w_norm_low1,'low'); 
    
    % For loop to calculate storage requirements for each day in a year
  
    for n = 1:1:365
   
    Netload_today = timeseries(Netload_365([((n-1)*288)+1:n*288],1), [0:300:86100]); % Time series data for the net load on a particular day
    Netload = Netload_today.data;
    Netload(isnan(Netload))= nanmean(Netload);
     
    % Non causal / Zero Phase filter
    lowpass_signal = filtfilt(b1,a1,Netload); 
    
    StorageSignal = Netload-lowpass_signal; % Calculating the storage required based on Netload - Lowpass Signal
    
     z = gt(max(abs(StorageSignal)),1000) ;
        
        if z == 1
            
            Pbattery(n,1) = NaN;
            
        else
            
            Pbattery(n,1) = max(abs(StorageSignal));
        
        end
        
        if max(abs(cumtrapz(t,StorageSignal)))/3600   == 0 
         Ebattery(n,1) = NaN;
        else
         Ebattery(n,1) = max(abs(cumtrapz(t,StorageSignal)))/3600; % Area under curve 
        end
 
    end

    k = ((Tlow-Tlow2)/10)+1;

    % Kernel Density Estimation for Battery Power Capacity (MW)
    row = 1;
    for rel_req = 0.90:0.01:0.99     % required reliability 
    pts = (min(Pbattery(:,1)):0.1:max(Pbattery(:,1)));
    [f_Pstorage,xPbatt,~] = ksdensity(Pbattery(:,1),pts,'support','positive',...
	'function','cdf'); % Kernel Density Estimation of Power Capacity of Battery Storage
    Pbatt(k,row) = interp1(f_Pstorage,xPbatt,rel_req); % Power Capacity of Battery Storage to be installed for required reliability 
    
    pts = (min(Ebattery(:,1)):0.1:max(Ebattery(:,1)));
    [f_Estorage,xEbatt,~] = ksdensity(Ebattery(:,1),pts,'support','positive',...
	'function','cdf'); % Kernel Density Estimation of Power Capacity of Battery Storage
    Ebatt(k,row) = interp1(f_Estorage,xEbatt,rel_req); % Power Capacity of Battery Storage to be installed for required reliability
        if isnan(Ebatt(k,row))
            Ebatt(k,row) = Ebatt(k-1,row)+(Ebatt(k-1,row)-Ebatt(k-2,row)); 
        end
    row = row +1;
    end
    end  
    
    Pbatt = flipud(Pbatt);
    Ebatt = flipud(Ebatt);
    surfaxis = [wlow1:(wlow2-wlow1)/27:wlow2];
    relreq = 0.90:0.01:0.99;
    
    % Pbatt surface plot
    figure('Name','Pbatt Surf')
    surf(relreq',surfaxis',Pbatt)
    xlabel('Reliability')
    ylabel('Frequency (1/hrs)') 
    zlabel('Pbatt(MW)')

    % Ebatt surface plot
    figure('Name','Ebatt Surf')
    surf(relreq',surfaxis',Ebatt)
    xlabel('Reliability')
    ylabel('Frequency (1/hrs)')
    zlabel('Ebatt(MW)')


    
    