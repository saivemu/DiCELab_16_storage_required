function saveTightFigure(h,outfilename)
% SAVETIGHTFIGURE(H,OUTFILENAME) Saves figure H in file OUTFILENAME without
%   the white space around it. 

% get the current axes
ax = get(h, 'CurrentAxes');

% make it tight
ti = get(ax,'TightInset');
set(ax,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

% adjust the papersize
set(ax,'units','centimeters');
pos = get(ax,'Position');
ti = get(ax,'TightInset');
set(h, 'PaperUnits','centimeters');
set(h, 'PaperSize', [pos(3)+ti(1)+ti(3)+1 pos(4)+ti(2)+ti(4)+1]);
set(h, 'PaperPositionMode', 'manual');
set(h, 'PaperPosition',[0 0  pos(3)+ti(1)+ti(3)+1 pos(4)+ti(2)+ti(4)+1]);

% save it
saveas(h,outfilename);
