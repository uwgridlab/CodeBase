%%  Plotting reconstructions for subjects
%   Nile Wilson 2016.09.06
%
%   Change the subject ID and hemisphere to match coverage and run this
%   script in the subject's main folder (not in any sub-directories like subject/images)

subjID  = 'acabb1';
hemi    = 'r'; %hemisphere, may be 'l', 'r', or 'b'

%%  Electrode information
%   In this code section, change the subject ID and the weight variables to
%   match what grids/strips are present in the current subject. You should
%   also adjust Montage.MontageTokenized to match the grids/strips. Labels
%   must also be adjusted.
%
%   Weights are used to assign different colors for each grid/strip.
%   Because the hsv colormap is used, the following numbers generally
%   correspond to the listed colors when the max is around 6 (usually used
%   for the grid).
%
%--------------------------------------------------------------------------
%   COLORS
%--------------------------------------------------------------------------
%   6   =   red
%   5   =   salmon pink
%   4   =   magenta
%   3   =   purple
%   2   =   navy blue
%   1   =   sky blue
%   0   =   cyan
%   -1  =   seafoam green
%   -2  =   green
%   -3  =   lime green
%   -4  =   yellow
%   -5  =   orange
%--------------------------------------------------------------------------

% Assign colors to each grid/strip
wGrid1  = ones(32,1)*6;     %red
wGrid2  = ones(32,1)*6;     %red
wAST    = ones(6,1)*0.5;    %light blue??
wMST    = ones(6,1)*-4;     %yellow
wPST    = ones(6,1)*4;      %magenta
wTO     = ones(8,1)*5;      %salmon pink
wPF     = ones(8,1)*-2;     %green
wAF     = ones(16,1)*1.7;   %navy blue
wAI     = ones(8,1)*0;      %cyan
wPI     = ones(8,1)*-1;     %seafoam green??

% Concatenate the weights
weights = cat(1, wGrid1, wGrid2, wAST, wMST, wPST, wTO, wPF, wAF, wAI, wPI);

% These are the grids that were registered in bioimage suite
Montage.MontageTokenized = {'Grid1(1:32)' 'Grid2(1:32)' 'AST(1:6)' 'MST(1:6)' 'PST(1:6)' 'TO(1:8)' 'PF(1:8)' 'AF(1:16)' 'AI(1:8)' 'PI(1:8)' };

% Number labels that will be plotted (numbers in the electrodes)
labels = [1:(length(wGrid1)+length(wGrid2)) 1:length(wAST) 1:length(wMST) 1:length(wPST) 1:length(wTO) 1:length(wPF) 1:length(wAF) 1:length(wAI) 1:length(wPI)];

%%  Gets the electrode locations for this subject in their native brain space and plot
%   You should not have to change anything in this section

locs = trodeLocsFromMontage(subjID, Montage, false);

% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments

figure;
PlotDotsDirect(subjID, ... % the subject on who's brain the electrodes will be drawn
               locs, ... % the location of the electrodes
               weights, ... % the weights to use for coloring
               hemi, ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
               [-abs(max(weights)) abs(max(weights))], ... % the color limits for the weights
               20, ... % the size of the dots, in points I believe
               'hsv', ... % the colormap to use for dot coloration
               labels, ... % labels for the electrodes, I think this can be a cell array 
               true); % a boolean switch as to whether or not to draw the labels
               
                 % calls to PlotDotsDirect where you don't want to keep
                 % re-drawing the brain over itself
                 
