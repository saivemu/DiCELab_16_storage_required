%% This script plots the Thermal Generation in the area(BPA) based on the available generation data
%% Clearing all the previous variables and data
clear all
clc

%% Variables to suppress/show/save the plots
show_plots = 1; 
printfigs = 1;

%% Function to load the demand data from excel to MATLAB 
% isunix and ispc determine the current OS 
if isunix

    ThermalGen_365 = load_data('/home/vemu/Downloads/ThermalGeneration.xlsx','2014');
    Netload_365 = load_data('/home/vemu/Dropbox/Sai - Research Work/Excel sheet Backup/Netload.xlsx','2015');
    WindGen_365 = load_data('/home/vemu/Downloads/WindGeneration.xlsx','2014');
end
if ispc

    ThermalGen_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/ThermalGeneration.xlsx','2014');
    Netload_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/Netload.xlsx','2015');
    WindGen_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/WindGeneration.xlsx','2014');   
end

%% Timeseries for Daily Thermal Generation

% 288 data points correspond to one day - 2016 correspond to one week

% n=1;

% ThermalGen_today = timeseries(ThermalGen_365([((n-1)*288)+1:n*288],1), [0:300:86100]); % Time series data for the Thermal generation on day 'n'

ThermalGen_today = timeseries(ThermalGen_365((1:2016),1)); % Time series data for the Thermal generation for a week

Netload_today = timeseries(Netload_365((1:2016),1)); % Time series data for the net load on a particular day

WindGen_today = timeseries(WindGen_365((1:2016),1)); % Time series data for the Wind generation for a week

if show_plots
    plot(Netload_today.data,'r') % Netload plot
    hold on 
    plot(ThermalGen_today.data,'c') % Thermal Generation 
    hold on
    plot(WindGen_today.data,'g') % Wind Generation 
    legend('Net load','Thermal Generation','Wind Generation')
    set(gca,'fontsize',12)
    set(gca,'linewidth',2)
    ylabel('Power (MW)')
    xlabel('K')
end

xlim([0 2016])

%% Print/Save figures - specify the address and filename
if printfigs
    if isunix
        saveTightFigure(gcf,'~/Dropbox/Sai - Research Work/Report/WeekGenPlot.pdf') 
    end
    if ispc
        saveTightFigure(gcf,'C:\Users\Sai\Dropbox\Sai - Research Work/Report/WeekGenPlot.pdf')
    end
end