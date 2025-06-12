% Script created by : "Nyström, M. & Holmqvist, K. (in press), "An adaptive algorithm for fixation, saccade, and glissade detection 
 % in eye-tracking data". Behavior Research Methods
% Updated by R.Jusiak under Matlab R2020b
% -------------------------------------------------------------------------
% For usage, see the README-file.
% -------------------------------------------------------------------------
clear
close all
clc
clear global ETparams   % globals are still present (hidden) even after a clear. This line specifically clear them


%% ------------------------------------------------------------------------
% Init parameters
% -------------------------------------------------------------------------
% Load participant file as the ETdata struct. lines = participants ; columns = Trials ; Each cell must contain X/Y/Z and time for each measurement
load("Example_RawData.mat");

% Set parameters for processing in ETparams & add previously loaded datas
global ETparams
ETparams.data = ETdata;
ETparams.screenSz = [1680 1050];                    % Screen resolution (px)
ETparams.screenDim = [0.47376 0.2961];              % Screen size (meters)
ETparams.samplingFreq = 500;                        % Sampling frequency (Hz)
ETparams.blinkVelocityThreshold = 1000;             % if vel > 1 000 degrees/s, it is noise or blinks
ETparams.blinkAccThreshold = 100000;                % if acc > 100 000 degrees/s^2, it is noise or blinks
ETparams.peakDetectionThreshold = 100;              % Initial value of the peak detection threshold
ETparams.minFixDur = 0.030;                         % in seconds
ETparams.minSaccadeDur = 0.015;                     % in seconds


%% Data correction if irregular sampling
% Run this section if the sampling frequency is unstable.
% Interpolate datas to retrieve the theorical sampling step (1/frequency).
% /!\ This transforms the datas. Not recommended if :   - event dectection threshold close to sampling step
%                                                       - sampling frequency highly unstable
% The following plots are help to decide whether the correction is needed/possible or not

Participant = 1;
Trial = 2;
step = diff(ETparams.data(Participant, Trial).t); figure ; plot(step) ; ylabel('step'); title('With Outliers') % Plot step for set Participant/Stim
noOut = step(step < 2*median(step) & step > 0);
figure ; plot(noOut) ; ylabel('step'); title('Without Outliers') % Plot step (time between each measures) for set Participant/Stim, excluding extreme and rare values
figure ; histogram(noOut,100) ; title('Step Distribution') % Plot step distribution 
clear step noOut

% The maximum interpolation duration can be set as a time (1↓) or a number of points (2↓↓)
% (1) in seconds 
% ETparams.limIntrp = 0.015;

% (2) in number of points 
pointsIntrp = 5 ;
ETparams.limIntrp = pointsIntrp/ETparams.samplingFreq;

TimeCorrect
clear pointsIntrp

%% ------------------------------------------------------------------------
% Begin detection
% -------------------------------------------------------------------------
eventDetection
save([cd, '\DetectionResults\DetectionResults.mat'], 'ETparams', '-v7.3'); % '-v7.3' allow saving heavy files (>2Go)
disp('Data saved')

%% Check specific results
% Choose what you whant to explore in ETparams.saccadeInfo(participant, Trial, saccade index)
Participant = 5;
Trial = 4;
image = [cd, '\Stimuli\Stim_', num2str(Trial), '.jpeg'] ; % !Don't forget to change the picture for the corresponding painting

SacVerif = squeeze(ETparams.saccadeInfo(Participant, :, :)); % number of column = maximum number of saccade detected for a Participant/Trial. The excess is empty
DataVerif = squeeze(ETparams.data(Participant, :, :));
SacAmpVerif = arrayfun(@(x) x.AmplitudePx, squeeze(ETparams.saccadeInfo(Participant, :, :)), 'UniformOutput', false); % Saccades amplitude
% Squeeze converts a 3D struct (difficult to explore) into 2D

% Plot the original data, saccades & fixations onto the corresponding image for set Trial and Participant
figure
imshow(image) ; hold on
plot(ETdata(Participant,Trial).X, ETdata(Participant,Trial).Y, 'LineWidth', 1) 

tempSacc = squeeze(ETparams.saccadeInfo(Participant,Trial,:));
SaccClear = cell2mat(struct2cell(tempSacc))';
for a = 1:size(SaccClear,1)
    saccCoord = [SaccClear(a,[4,6]); SaccClear(a,[5,7])]; % coordinates X (line 1) and Y of start (col 1) and end of saccade a
    plot(saccCoord(1,:), saccCoord(2,:), 'g', 'LineWidth', 1.25)
end

tempFix = squeeze(ETparams.fixationInfo(Participant,Trial,:));
fixClear = cell2mat(struct2cell(tempFix))';
for a = 1:size(fixClear,1)
    plot(fixClear(a,1), fixClear(a,2),'r*')
end


%% ------------------------------------------------------------------------
% Plot results
% -------------------------------------------------------------------------
% Calculate basic parameters
mean(cat(1, ETparams.data.avgNoise))
mean(cat(1, ETparams.data.stdNoise))
mean(cat(1, ETparams.glissadeInfo.duration))
mean(cat(1, ETparams.saccadeInfo.duration))
mean(cat(1, ETparams.fixationInfo.duration))

% Plot histograms (glissades, saccades and fixations Duration)
% figure
% hist(cat(1, ETparams.glissadeInfo.duration), 100)
figure
histogram(cat(1, ETparams.saccadeInfo.duration), 40)
xlabel('Saccade duration (s)'), ylabel('Number of saccades')
figure
histogram(cat(1, ETparams.fixationInfo.duration), 100)
xlabel('Fixation duration (s)'), ylabel('Number of fixations')

% Choose what Trial to plot
Participant = 5;
Trial = 4;
plotResultsVel(ETparams, Participant, Trial)