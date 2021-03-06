%% do the work

subjids = {'26cb98', '38e116', '4568f4', '30052b', 'fc9643', 'mg', '04b3d5'};

uvals_all = [];
dvals_all = [];
tlocs_all  = [];

uvals_scrn = [];
dvals_scrn = [];
ulocs_scrn = [];
dlocs_scrn = [];

for c = 1:length(subjids)
    subjid = subjids{c};

    doPlots = false;
    fig_overall;
    
    tlocs = trodeLocsFromMontage(subjid, Montage, true);
    
    uvals_all = cat(2, uvals_all, uvals);
    dvals_all = cat(2, dvals_all, dvals);
    tlocs_all  = cat(1, tlocs_all,  tlocs);
    
    uvals_scrn = cat(2, uvals_scrn, uvals(~isnan(uvals)));
    dvals_scrn = cat(2, dvals_scrn, dvals(~isnan(dvals)));
    uctl_trode_flag(c) = ~isnan(uvals(getControlChannel(subjid)));
    
    ulocs_scrn = cat(1, ulocs_scrn, tlocs(~isnan(uvals),:));
    dlocs_scrn = cat(1, dlocs_scrn, tlocs(~isnan(dvals),:));
    dctl_trode_flag(c) = ~isnan(dvals(getControlChannel(subjid)));
    
    clearvars -except uvals_all dvals_all tlocs_all uvals_scrn dvals_scrn ulocs_scrn dlocs_scrn subjids c uctl_trode_flag dctl_trode_flag;
end


%% plot up targets
figure;

load('recon_colormap');
templocs = [1.01*abs(ulocs_scrn(:,1)) (ulocs_scrn(:,2)) ulocs_scrn(:,3)];

% % this is the new way, maximizing color contrast
um = max(abs(uvals_scrn));
PlotDotsDirect('tail', templocs, uvals_scrn, 'r', [-um um], 15, 'recon_colormap', [], false);
colormap(cm);
colorbar;
title('up target activation - all subjects');

circleControlTrodes(gca, subjids(uctl_trode_flag), true);

% % here was the old way
% subplot(121);
% PlotDotsDirect('tail', templocs, uvals_scrn, 'r', [-1 1], 10, 'recon_colormap', [], false);
% view(90,0);
% colormap(cm);
% % colorbar;
% 
% subplot(122);
% PlotDotsDirect('tail', templocs, uvals_scrn, 'r', [-1 1], 10, 'recon_colormap', [], false);
% view(270,0);
% colormap(cm);
% % colorbar;
% 
% mtit('up target activation - all subjects', 'xoff', 0, 'yoff', 0);

% % now do something with it
maximize;
% hgsave(gcf, fullfile(pwd, 'figs', 'overall.tal.up.fig'));
SaveFig(fullfile(pwd, 'figs'), 'overall.tal.up.lg', 'png');

%% plot down targets
figure;
load('recon_colormap');
templocs = [1.01*abs(dlocs_scrn(:,1)) (dlocs_scrn(:,2)) dlocs_scrn(:,3)];

% % this is the new way, maximizing color contrast
dm = max(abs(dvals_scrn));
PlotDotsDirect('tail', templocs, dvals_scrn, 'r', [-dm dm], 15, 'recon_colormap', [], false);
colormap(cm);
colorbar;
title('down target activation - all subjects');
circleControlTrodes(gca, subjids(dctl_trode_flag), true);

% % this is the old way
% subplot(121);
% PlotDotsDirect('tail', templocs, dvals_scrn, 'r', [-1 1], 10, 'recon_colormap', [], false);
% view(90,0);
% colormap(cm);
% % colorbar;
% 
% subplot(122);
% PlotDotsDirect('tail', templocs, dvals_scrn, 'r', [-1 1], 10, 'recon_colormap', [], false);
% view(270,0);
% colormap(cm);
% % colorbar;
% 
% mtit('down target activation - all subjects', 'xoff', 0, 'yoff', 0);

% % now do something with it
maximize;
% hgsave(gcf, fullfile(pwd, 'figs', 'overall.tal.down.fig'));
SaveFig(fullfile(pwd, 'figs'), 'overall.tal.down.lg', 'png');
