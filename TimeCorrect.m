function TimeCorrect
% This function interpole datas to correct an unstable sampling. It recreates datas to match theorical sampling frequency. "ETparams.limIntrp" gives
% the maximum size of the interpolation
global ETparams
clear pointsIntrp

for i = 1:size(ETparams.data, 1)  % 1 to number of sujects
    for j = 1:size(ETparams.data, 2) % 1 to number of trials
        if isempty(ETparams.data(i,j).t) == 0 % check if data are present
            step = diff(ETparams.data(i,j).t); % Time between each measure (before interpolation)
            ETparams.data(i,j).X(find(step == 0)) = []; % Delete some sampling error (2 measure for 1 time)
            ETparams.data(i,j).Y(find(step == 0)) = [];
            ETparams.data(i,j).Z(find(step == 0)) = [];
            ETparams.data(i,j).t = ETparams.data(i,j).t - ETparams.data(i,j).t(1);
            ETparams.data(i,j).t(find(step == 0)) = [];
            
            TrialLength = (ETparams.data(i,j).t(end)); % Trial duration (in seconds)
            ETparams.data(i,j).t(ETparams.data(i,j).t < 0) = NaN;
            newTimestamps = 0 : 1/ETparams.samplingFreq : TrialLength; % Index of corrected datas. = time of a perfectly stable sampling
            ETparams.data(i,j).X = interp1(ETparams.data(i,j).t, ETparams.data(i,j).X, newTimestamps); % Interpolation
            ETparams.data(i,j).Y = interp1(ETparams.data(i,j).t, ETparams.data(i,j).Y, newTimestamps);
            ETparams.data(i,j).Z = interp1(ETparams.data(i,j).t, ETparams.data(i,j).Z, newTimestamps);
            
            noIntrpIndx = find([0 step] > ETparams.limIntrp); % Find steps > max interpolation
            
            for a = 1:length(noIntrpIndx) % replace their interpolations by NaNs
                deleteIndx = find(newTimestamps < ETparams.data(i,j).t(noIntrpIndx(a)) & newTimestamps > ETparams.data(i,j).t(noIntrpIndx(a)-1));
                ETparams.data(i,j).X(deleteIndx) = NaN;
                ETparams.data(i,j).Y(deleteIndx) = NaN;
                ETparams.data(i,j).Z(deleteIndx) = NaN;
            end
        end
    end
end
disp('Correction done')


% ETparams.data(i, j).t(isnan(ETparams.data(i, j).t)) = []