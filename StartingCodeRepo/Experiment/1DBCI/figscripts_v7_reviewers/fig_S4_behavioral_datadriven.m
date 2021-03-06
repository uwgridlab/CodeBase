%% this script generates behavioral figures for each subject, on a subject
%% by subject basis

% clear;
fig_setup;

big = 20;
small = 14;

% num = 1;

subjid = subjids{num};
id = ids{num};
% clear num;

[files, side, div] = getBCIFilesForSubjid(subjid);

allpaths = [];
alltargets = [];
allresults = [];
allmaxs = [];
allmins = [];

fprintf('running analysis for %s\n', subjid);

cachefile = fullfile('..','metadata','trajectories.cache',[subjid '.mat']);

if (exist(cachefile, 'file'))
    fprintf('using cache file %s\n', cachefile);
    load(cachefile);
else
    for c = 1:length(files)

        fprintf('  processing file %d\n', c);

        file = files{c};
        [~, states, parameters] = load_bcidat(file);
        subjid = extractSubjid(file);

        fs = parameters.SamplingRate.NumericValue;

        if (fs == 2400)
            % cheat and downsample everything
            fprintf('    downsampling from 2.4 KHz\n');

            states.Feedback = downsample(states.Feedback, 2);
            states.TargetCode = downsample(states.TargetCode, 2);
            states.ResultCode = downsample(states.ResultCode, 2);
            states.Running = downsample(states.Running,2 );
            states.CursorPosX = downsample(states.CursorPosX, 2);
            states.CursorPosY = downsample(states.CursorPosY, 2);

            fs = 1200;
        end

        trialTime = parameters.PreFeedbackDuration.NumericValue + ...
                    parameters.FeedbackDuration.NumericValue + ... 
                    parameters.PostFeedbackDuration.NumericValue;

        if (~exist('prevTrialTime','var'))
            prevTrialTime = trialTime;
        elseif (trialTime ~= prevTrialTime)
            warning('trial time not consistent across runs');
        end

        pre = parameters.PreFeedbackDuration.NumericValue + parameters.ITIDuration.NumericValue;
        post = parameters.FeedbackDuration.NumericValue + parameters.PostFeedbackDuration.NumericValue;

        if (~exist('prevfs', 'var'))
            prevfs = fs;
        elseif (prevfs ~= fs)
            error('sampling frequency not consistet across runs, was %d is %d', prevfs, fs);
        end

        [starts, ends] = getEpochs(states.Feedback, 1, true);

        % this is a total hack
        if (num == 1 && c == 1)
            fprintf('dropping the first epoch\n');
            starts = starts(2:end);
            ends = ends(2:end);
        end


        paths = getEpochSignal([states.CursorPosX states.CursorPosY], starts, ends);

        paths(paths > 2^15) = paths(paths > 2^15) - 2^16;
        paths = constrain(paths, 0, parameters.WindowHeight.NumericValue);

        if (~isempty(allpaths) && size(allpaths, 1) ~= size(paths, 1))
            paths = paths(1:size(allpaths, 1), :, :);
        end

        allpaths = cat(3, allpaths, paths);

        results = states.ResultCode(ends);
        targets = states.TargetCode(starts);

        allresults = cat(1, allresults, results);
        alltargets = cat(1, alltargets, targets);

        allmaxs = cat(1, allmaxs, repmat(parameters.WindowHeight.NumericValue, length(starts), 1));
        allmins = cat(1, allmins, repmat(parameters.WindowHeight.NumericValue, length(starts), 1));

    end
    
    fprintf('writing cache file');
    save(cachefile);
end

%% get ready to plot
screen_max = parameters.WindowHeight.NumericValue;

ypaths = squeeze(allpaths(:,2,:));
ypaths = map(ypaths, 0, screen_max, screen_max, 0);


t = 1:parameters.SampleBlockSize.NumericValue:size(ypaths,1);
t = [t size(ypaths,1)];

ypaths = interp1(t, ypaths(t,:), 1:size(ypaths, 1));

outdir = fullfile(myGetenv('output_dir'), '1dbci', 'figs', 'perf');
TouchDir(outdir);


%% try to fit for behavior

res = alltargets == allresults;

pathdiff = diff(ypaths, 1, 1);
goodtrials = sum(pathdiff > 500) == 0;

% yuppaths = ypaths(:,alltargets==1);
% ydnpaths = ypaths(:,alltargets==2);
% idealup = mean(yuppaths(:,ceil(.8*size(yuppaths,2)):end),2);
% idealdn = mean(ydnpaths(:,ceil(.8*size(ydnpaths,2)):end),2);

goodups = ypaths(:, alltargets==1 & alltargets==allresults);
gooddowns = ypaths(:, alltargets==2 & alltargets==allresults);
idealup = mean(goodups(:,ceil(.8*size(goodups,2)):end),2);
idealdn = mean(gooddowns(:,ceil(.8*size(gooddowns,2)):end),2);

ideal_m = zeros(size(ypaths));

ideal_m(:, alltargets==1) = repmat(idealup, 1, sum(alltargets==1));
ideal_m(:, alltargets==2) = repmat(idealdn, 1, sum(alltargets==2));

% ideal = (double(alltargets)-1) .* allmaxs;
% ideal_m = repmat(ideal, 1, size(ypaths, 1))';

sq_er = (ypaths-ideal_m).^2;
% sq_er_max = repmat(max(allmaxs), size(sq_er)).^2;

% trial_er = (sum(sq_er, 1) ./ sum(sq_er_max, 1));
trial_er = sum(sq_er, 1) / size(sq_er, 1);

trial_er(trial_er == 0) = 0.01;

x = 1:length(trial_er);

figure, 
bar(x, trial_er, 'FaceColor', [.9 .9 .9]);
hold on;
bar(x(res), trial_er(res), 'FaceColor', [.5 .5 .5]); 


% plot(x(~goodtrials), trial_er(~goodtrials)+.2e5, 'kx', 'MarkerSize', 3);
plot(x(alltargets==1), trial_er(alltargets==1)+.025*max(ylim()), 'kd', 'MarkerSize', 3);

set(gca, 'FontSize', small);
set(gca, 'FontName', 'arial');

axis tight

% bar(x((~goodtrials)&res'), trial_er((~goodtrials)&res'), 'r', 'BarWidth', .1); 
% bar(x(~goodtrials&~res'), trial_er(~goodtrials&~res'), 'FaceColor', [.5 .5 .5], 'BarWidth', .05); 

% for c = 1:length(ideal)
%     if (alltargets(c)==1)
%         figure, plot(ypaths(:, c), 'r');
%     else
%         figure, plot(ypaths(:, c), 'b');
%     end
%     
%     title(c);
%     pause
% end

% goodtrials = ones(size(goodtrials))==1;

% c = polyfit(x(goodtrials), trial_er(goodtrials), 1);
% c_a = polyfit(x, trial_er, 1);
% fit_y = [min(x) max(x)] * c(1) + c(2);
% fit_y_a = [min(x) max(x)] * c_a(1) + c_a(2);

c = polyfit(x(goodtrials), log(trial_er(goodtrials)), 1);
% c_a = polyfit(x, log(trial_er), 1);
fit_y = exp([min(x) max(x)] * c(1) + c(2));
% fit_y_a = exp([min(x) max(x)] * c_a(1) + c_a(2));

[rho, pval] = corr(x(goodtrials)', log(trial_er(goodtrials)'));
% [rho, pval] = corr(x(goodtrials)', trial_er(goodtrials)');
% [rho_a, pval_a] = corr(x', log(trial_er'));

if (pval < 0.01)
    plot([min(x) max(x)], fit_y, 'k', 'LineWidth', 2);
else
    plot([min(x) max(x)], fit_y, 'k--', 'LineWidth', 2);
end

% plot([min(x) max(x)], fit_y_a, 'k--', 'LineWidth', 2);

% [rho, pval] = corr(x(goodtrials)', trial_er(goodtrials)');
% [rho_a, pval_a] = corr(x', trial_er');

if (pval < 0.01)
    title(sprintf('%s - r^2=%1.3f, p<0.01', id, rho^2), 'FontSize', big, 'FontName', 'arial');    
else
    title(sprintf('%s - r^2=%1.3f, p=%1.3f', id, rho^2, pval), 'FontSize', big, 'FontName', 'arial');    
end

xlabel('trial number', 'FontSize', big, 'FontName', 'arial');
ylabel('mean squared error (pixels)', 'FontSize', big, 'FontName', 'arial');

SaveFig(outdir, ['mse.' subjid], 'eps');
SaveFig(outdir, ['mse.' subjid], 'png');
% close

%%
figure;

t = (1:size(ypaths,1))/parameters.SamplingRate.NumericValue;

yups = ypaths(:, alltargets==1);
ydns = ypaths(:, alltargets==2);

cm = ((0:(size(yups,2)-1))/size(yups,2))'*.8;
cm = [ones(size(cm)) cm cm];

for c = 1:size(yups, 2)
    plot(t,yups(:,c), 'Color', cm(end-(c-1),:));
    hold on;
end

cm = ((0:(size(ydns,2)-1))/size(ydns,2))'*.8;
cm = [cm cm ones(size(cm))];

for c = 1:size(ydns, 2)
    plot(t,ydns(:,c), 'Color', cm(end-(c-1),:));
    hold on;
end

% plot(ypaths(:, alltargets==1), 'r'); 
% hold on;
% plot(ypaths(:, alltargets==2), 'b'); 

plot(t,idealup-3, 'k', 'LineWidth', 5);
plot(t,idealup, 'r', 'LineWidth', 5);

plot(t,idealdn-3, 'k', 'LineWidth', 5);
plot(t,idealdn, 'b', 'LineWidth', 5);

set(gca, 'FontSize', small);
set(gca, 'FontName', 'arial');

xlabel('time (s)', 'FontSize', big, 'FontName', 'arial');
ylabel('position (pixels)', 'FontSize', big, 'FontName', 'arial');

title (sprintf('%s - all paths', id), 'FontSize', big, 'FontName', 'arial');
axis tight;

SaveFig(outdir, ['paths.' subjid], 'eps');
% close;


%%


% % save(cachefile, 'allpaths', 'alltargets', 'allwindows', 'allepochs', 'bads', 'Montage', 'subjid', 'side', 'pre', 'post', 'fs', 'div');
% 
% 
% 
% clearvars -except allpaths alltargets allwindows allepochs bads Montage subjid side pre post fs div num id theme_colors red blue green big small cacheOutDir figOutDir;
% 
% % %% assumes that fig_overall has been run
% % % fig_overall no longer exists, so we need to do this a different way
% % % now...
% % %
% % % let's try pulling from fig_2b_overall.m
% % 
% % overallcachefile = fullfile(cacheOutDir, ['overall_' subjid '.mat']);
% % load(overallcachefile, 'uSigs', 'dSigs', 'aSigs');
% % overallSigs = union(find(aSigs), union(find(uSigs), find(dSigs)));
% % 
% % shiftcachefile = fullfile(cacheOutDir, ['shift_' subjid '.mat']);
% % load(shiftcachefile);
% % shiftSigs = union(find(allh), union(find(uph), find(downh)));
% % 
% % % interestingTrodes = union(overallSigs, shiftSigs)';
% % interestingTrodes = 1:length(allh);
% % interestingTrodes(bads) = [];
% % 
% % 
% % % determine up/down trial number corresponding to div
% % posttargs = alltargets;
% % posttargs(1:(div-1)) = 0;
% % 
% % uppostidx = find(posttargs==1, 1, 'first');
% % downpostidx = find(posttargs==2, 1, 'first');
% % 
% % upcount = cumsum(alltargets==1);
% % updiv = upcount(uppostidx);
% % 
% % downcount = cumsum(alltargets==2);
% % downdiv = downcount(downpostidx);
% % 
% % t = (-pre*fs:(post*fs-1))/fs;
% % 
% % tallocs = trodeLocsFromMontage(subjid, Montage, true);
% % 
% % if size(interestingTrodes,1) > 1 && size(interestingTrodes,2) == 1
% %     interestingTrodes = interestingTrodes';
% % end
% % 
% % warning('int trodes hardcoded');
% % 
% % switch(num)
% %     case 1
% %         interestingTrodes = [16 23 18 96];
% %     case 2
% %         interestingTrodes = [36 51 42 56];
% %     case 3
% %         interestingTrodes = [17 49 10];
% %     case 4
% %         interestingTrodes = [39 55 100];
% %     case 5
% %         interestingTrodes = [40 56 59 15];
% %     case 6
% %         interestingTrodes = [14 12 23];
% %     case 7
% %         interestingTrodes = [34 37 46 27];
% % end
% % % interestingTrodes = [96];
% % 
% % for trode = interestingTrodes
% %     fprintf('plotting %s - %s\n', subjid, trodeNameFromMontage(trode, Montage));
% %     
% %     figure;
% %     
% %     subplot(131); % up mean vs down mean
% %     muSmooth = GaussianSmooth(mean(squeeze(allwindows(:,trode,alltargets==1)),2), .5*fs);
% %     sigmaSmooth = GaussianSmooth(std(squeeze(allwindows(:,trode,alltargets==1)),0,2)/sqrt(sum(alltargets==1)), .5*fs);
% %     plot(t, muSmooth, 'Color', theme_colors(red,:), 'LineWidth', 2);
% %     hold on;
% %     plot(t, muSmooth+sigmaSmooth, 'Color', theme_colors(red,:), 'LineStyle', ':', 'LineWidth', 2);
% %     plot(t, muSmooth-sigmaSmooth, 'Color', theme_colors(red,:), 'LineStyle', ':', 'LineWidth', 2);
% %     
% %     muSmooth = GaussianSmooth(mean(squeeze(allwindows(:,trode,alltargets==2)),2), .5*fs);
% %     sigmaSmooth = GaussianSmooth(std(squeeze(allwindows(:,trode,alltargets==2)),0,2)/sqrt(sum(alltargets==2)), .5*fs);
% %     plot(t, muSmooth, 'Color', theme_colors(blue,:), 'LineWidth', 2);
% %     hold on;
% %     plot(t, muSmooth+sigmaSmooth, 'Color', theme_colors(blue,:), 'LineStyle', ':', 'LineWidth', 2);
% %     plot(t, muSmooth-sigmaSmooth, 'Color', theme_colors(blue,:), 'LineStyle', ':', 'LineWidth', 2);
% %     axis tight;
% % %     legend('up', 'up+SE', 'up-SE', 'down', 'down+SE', 'down-SE');
% %     plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
% %     plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
% %     plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% %     plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% % 
% %     
% %     set(gca, 'FontSize', small, 'FontName', 'Arial');
% %     xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
% %     ylabel('z-score', 'FontSize', big, 'FontName', 'Arial');
% %     title('average response', 'FontSize', big, 'FontName', 'Arial');
% % 
% %     % prepare to plot the trial by trial HG, smoothed
% %     gfilt = customgauss([.5*fs+1 7], .125*fs, 3, 0, 0, 1, [0 0]);
% %     gfilt = gfilt / sum(sum(gfilt));
% %     [r,c] = size(gfilt);
% %     rs = ceil(r/2);
% %     re = floor(r/2);
% %     cs = ceil(c/2);
% %     ce = floor(c/2);
% % 
% %     ups = squeeze(allwindows(:,trode,alltargets==1));    
% %     upsSmooth = conv2(ups,gfilt);    
% %     upsSmooth = upsSmooth(rs:(end-re),cs:(end-ce));
% %     downs = squeeze(allwindows(:,trode,alltargets==2));
% %     downsSmooth = conv2(downs,gfilt);
% %     downsSmooth = downsSmooth(rs:(end-re),cs:(end-ce));
% % 
% %     clims = [min(min(min(downsSmooth)), min(min(upsSmooth))) max(max(max(downsSmooth)),max(max(upsSmooth)))];
% % 
% %     subplot(132); % evolution of ups
% %     
% %     imagesc(t,1:size(ups,2),upsSmooth',clims);
% %     hold on;
% %     plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
% %     plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
% %     plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% %     plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% %     plot(t, updiv*ones(size(t)), 'k', 'LineWidth', 2);
% %     
% %     set(gca, 'FontSize', small, 'FontName', 'Arial');
% %     xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
% %     ylabel('trials', 'FontSize', big, 'FontName', 'Arial');
% % %     title('up response', 'FontSize', big, 'FontName', 'Arial');
% %     title(sprintf('up response (%3.2f, %3.2f)', clims(1), clims(2)), 'FontSize', big, 'FontName', 'Arial');
% % 
% %     subplot(133); % evolution of downs
% %     imagesc(t,1:size(downs,2),downsSmooth',clims);
% %     hold on;
% %     plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
% %     plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
% %     plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% %     plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% %     plot(t, downdiv*ones(size(t)), 'k', 'LineWidth', 2);
% %     
% %     set(gca, 'FontSize', small, 'FontName', 'Arial');
% %     xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
% %     ylabel('trials', 'FontSize', big, 'FontName', 'Arial');
% % %     title('down response', 'FontSize', big, 'FontName', 'Arial');
% %     title(sprintf('down response (%3.2f,%3.2f)', clims(1), clims(2)), 'FontSize', big, 'FontName', 'Arial');
% %     
% %     ba = brodmannAreaForElectrodes(tallocs(trode, :));
% %     [fa, fkey] = hmatValue(tallocs(trode,:));
% %     
% %     tname = trodeNameFromMontage(trode, Montage);
% %     
% % % %     use this section for anatomic labeling, useful if you want to know
% % % %     where all the electrodes are located
% % %     if (~isnan(ba))
% % %         if (fa > 0)
% % %             tit = sprintf('%s-%s (BA: %d, HMAT: %s)', id, tname, ba, fkey{fa});
% % %         else
% % %             tit = sprintf('%s-%s (BA: %d)', id, tname, ba);
% % %         end
% % %     else
% % %         if (fa > 0)
% % %             tit = sprintf('%s-%s (HMAT: %s)', id, tname, fkey{fa});
% % %         else
% % %             tit = sprintf('%s-%s', id, tname);
% % %         end
% % %     end
% % %     
% % %     tit = sprintf('%s, o=%d, s=%d', tit, sum(overallSigs==trode), sum(shiftSigs==trode));
% %   
% % % %     otherwise use this section
% %     tit = sprintf('%s-%s', id, tname);
% %     
% %     subplot(131); title(tit, 'FontSize', big, 'FontName', 'Arial');
% %     
% % %     mtit(tit, 'xoff', 0, 'yoff', .1, 'FontSize', big, 'FontName', 'Arial');
% %     
% %     cleantname = strrep(strrep(tname, ')', ''), '(', '');
% % %     hgsave(fullfile(pwd, 'figs', ['bytime.' subjid '.' cleantname '.fig']));
% %     
% % %     SaveFig(fullfile(pwd, 'figs'), ['bytime.' subjid '.' cleantname '.sm']);
% % %     maximize; 
% %     set(gcf,'Position',[10 100 1900 700]);
% % 
% %     subplot(131);
% %     set(gca, 'Units','normalized','Position',[0.10 0.23 0.25 0.6]);
% %     subplot(132);
% %     set(gca, 'Units','normalized','Position',[0.40 0.23 0.25 0.6]);
% %     subplot(133);
% %     set(gca, 'Units','normalized','Position',[0.70 0.23 0.25 0.6]);    
% % %     mtit(tit, 'xoff', 0, 'yoff', .03, 'FontSize', big, 'FontName', 'Arial');
% % 
% %     SaveFig(figOutDir, ['bytime.' subjid '.' cleantname '.lg'], 'eps');    
% %     close all;
% % %     SaveFig(fullfile(pwd, 'figs'), [subjid '-' tname]);
% % end
% % 
% % % %% summary for table
% % % 
% % % areas = brodmannAreaForElectrodes(tallocs(interestingTrodes, :));
% % % counter = 1;
% % % 
% % % for trode = interestingTrodes'
% % %     ba = areas(counter);
% % %     counter = counter + 1;
% % %     
% % %     [fa, fkey] = hmatValue(tallocs(trode,:));
% % %     tname = trodeNameFromMontage(trode, Montage);
% % %     
% % %     if (isnan(ba))
% % %         ba = 0;
% % %     end
% % %     
% % %     if fa == 0
% % %         fstr = 'none';
% % %     else
% % %         fstr = fkey{fa};
% % %     end
% % %     
% % %     tname = trodeNameFromMontage(trode, Montage);    
% % %     fprintf('%s\t%s\t%s\t%d\t%s\t%3.2f\t%3.2f\t%3.2f\n', ...
% % %         id, subjid, tname, ba, fstr, tallocs(trode,1), tallocs(trode,2), tallocs(trode,3))
% % % end
