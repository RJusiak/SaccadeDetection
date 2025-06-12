function calVelAcc_sgolay(i, j)
global ETparams
% In the original version of the script (Nyström & al.), the conversion from pixel to degree was calcultated in "degrees2pixels" using a fix
% distance to screen. This version recalcultate it for each measure, taking into account the variation in screen distance (Z axis).

% Lowpass filter window length
smoothInt = ETparams.minSaccadeDur; % in seconds

% Span of filter
span = ceil(smoothInt * ETparams.samplingFreq);

% % % Calculate how many pixel one degrees spans.
for a = 1:length(ETparams.data(i,j).Z)
    alpha = pi/180;  % 1° → radian
    width05 = tan(alpha/2) * ETparams.data(i,j).Z(a);
    width = 2 * width05; % size (in meter) of 1° on screen
    ETparams.data(i,j).pxPerDeg(a) = ETparams.screenSz(1) * width/ETparams.screenDim(1);
end


%% Calculate unfiltered data
%--------------------------------------------------------------------------
ETparams.data(i, j).Xorg = ETparams.data(i, j).X;
ETparams.data(i, j).Yorg = ETparams.data(i, j).Y;

ETparams.data(i, j).velXorg = [0 diff(ETparams.data(i, j).X)]./ETparams.data(i, j).Z * ETparams.samplingFreq; % "rotation" speed
ETparams.data(i, j).velYorg = [0 diff(ETparams.data(i, j).Y)]./ETparams.data(i, j).Z * ETparams.samplingFreq;
ETparams.data(i, j).velOrg = sqrt(ETparams.data(i, j).velXorg.^2 + ETparams.data(i, j).velYorg.^2); % Pythagore for XY movement 


%% Pixel values, velocities, and accelerations
%--------------------------------------------------------------------------
% The Savitzky-Golay filter smooths data by fitting a polynomial of degree N(↓) to a sliding window of size F(↓), and replacing each point with the 
% corresponding value predicted by that polynomial

N = 2;                      % Order of polynomial fit
F = 2 * ceil(span) - 1;     % Window length
[~, g] = sgolay(N, F);      % Calculate S-G coefficientsé

% Extract relevant gaze coordinates for the current trial.
X = ETparams.data(i, j).X;
Y = ETparams.data(i, j).Y;

% Calculate the velocity and acceleration
ETparams.data(i, j).X = filter(g(:, 1), 1, X);
ETparams.data(i, j).Y = filter(g(:, 1), 1, Y);

ETparams.data(i, j).velX = filter(g(:, 2), 1, X);
ETparams.data(i, j).velY = filter(g(:, 2), 1, Y);
ETparams.data(i, j).vel = sqrt(ETparams.data(i, j).velX.^2 + ETparams.data(i, j).velY.^2)./ETparams.data(i,j).pxPerDeg .* ETparams.samplingFreq;

ETparams.data(i, j).accX = filter(g(:, 3), 1, X);
ETparams.data(i, j).accY = filter(g(:, 3), 1, Y);
ETparams.data(i, j).acc = sqrt(ETparams.data(i, j).accX.^2 + ETparams.data(i, j).accY.^2)./ETparams.data(i,j).pxPerDeg .* ETparams.samplingFreq^2;

