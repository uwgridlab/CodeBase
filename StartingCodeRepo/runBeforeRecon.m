%%  Run this first
%   Before running any code for recons like ReconstructCorticalSurface, run
%   this script to make sure the path is set correctly
%
%   If you have multiple subjects folders in your path, make sure to remove
%   all except for the subject you are interested in

%%  The code (just one line)

%   Make sure the path points to the parent directory of the Visualization
%   folder
%   For example, if you have
%   C:\Users\name\MATLAB\RECONS\Miah\Visualization\Recon
%   then use C:\Users\name\MATLAB\RECONS\Miah

setenv('matlab_devel_dir',pwd);