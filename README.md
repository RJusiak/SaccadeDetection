# SaccadeDetection
The algorithm is implemented in Matlab and tested on version R2020b.
README-file of the event detection algorithm accompanying the article Nyström, M. & Holmqvist, K. (in press), "An adaptive algorithm for fixation, saccade, and glissade detection in eye-tracking data". Behavior Research Methods
Updated by R.Jusiak under Matlab R2020b to add Z axis and correction for irregular sampling frequency.

If you have any questions or comments on the original paper or the code, send an email at :
marcus.nystrom@humlab.lu.se.

If you have any questions or comments on the updated code, send me an email at :
renaud.jusiak@gmail.com

Observe that this script requires a Z axis. For data collected from viewers keeping their heads relatively still while watching static stimuli, prefere using the original version (Nyström & al. 2010)

Usage:  Run the file: beginEventDetection.m
        Read comments to know what section to run, and what variable to modify (i.e. sampling frequency)

The command 'load('Example_RawData.mat');' in the file beginEventDetection.m loads raw gaze positions from three participants into the variable ETdata, which holds data in a structure array, sorted after participant and Trial.
Notice that the example data contains portions or poor data (where something when wrong during recording). This is to show how the algorithms handles noisy data.

Example: ETdata(2,6).X contains all x-coordinates for participant 2 recorded during 
trial 6. Similarily, ETdata(2,6).Y contains corresponding y-coordinates.

Results are stored in the folder 'DetectionResults' in the file 'DetectionResults.mat'. The results can be accessed from the variable ETparams.

The "Graphs" folder contains examples of results. The original data of a Participant/Trial as well as the detected saccades & fixations
are ploted onto the corresponding presented stimulus.
