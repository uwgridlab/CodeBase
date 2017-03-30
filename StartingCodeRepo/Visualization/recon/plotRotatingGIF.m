%%  Generate a GIF of a rotating recon
%   Create an animated GIF showing the reconstructed cortical surface (with
%   electrodes) rotating
%   Nile Wilson 2016.09.206

%%  How to Use
%   To use this script, edit the information in the section directly below
%   by copying the code in plotRecon.m and pasting (replacing) into this section.
%   
%   If you would like to change the angle / duration of rotation, edit the
%   last two code sections (more detail below).

%% Copy and paste from plotSetup.m in this section of code
subjID  = 'acabb1';
hemi    = 'r'; %hemisphere, may be 'l', 'r', or 'b'

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
                 
       
%--------------------------------------------------------------------------
% Note
%--------------------------------------------------------------------------
% To change the alpha/transparency of the brain, open PlotCortex from
% PlotDotsDirect. In the PlotBrain function, change the value of
% 'facealpha' to a number between 0 (completly transparent) and 1 (solid).


%%  Only copy and paste code from plotSetup into the section above
%   The code below may need to be edited get the proper viewing ables for
%   your subject


%%  Rotate the view (inferior to superior and back)
%--------------------------------------------------------------------------
%   Note
%--------------------------------------------------------------------------
%
%   If you want to change the angle or duration of rotation, edit the value
%   el or az in the for loop definitions. Note that one will act as the
%   loop variable and the other will be constant. To get a sense of what
%   values you should be using, manually rotate the brain in the figure
%   generated above and pay attention to the az and el values outputted to
%   the bottom left corner of the figure window.
%
%--------------------------------------------------------------------------
filename    = strcat(subjID, '_recon.gif');
startValue  = -90;
endValue    = 90;

for el = startValue:3:endValue %degrees of rotation along el
            az = 90;
            view([az el])

            drawnow
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            
            if el == startValue
              imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.1);
            else
              imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
            end          
end

for el = endValue:-3:startValue
            az = 90;
            view([az el])

            drawnow
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            
       
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);        
end

%%  Rotate the view (lateral)
filename    = strcat(subjID, '_recon_lateral.gif');
startValue  = 90;
endValue    = 270;

for az = startValue:3:endValue %degrees of rotation along az
            el = 0;
            view([az el])

            drawnow
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            
            if az == startValue
              imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.1);
            else
              imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
            end          
end

for az = endValue:-3:startValue
            el = 0;
            view([az el])

            drawnow
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            
      
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);         
end