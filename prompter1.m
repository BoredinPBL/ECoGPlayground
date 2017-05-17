%prompter1 is heavily dependent on PsychToolBox and you need to make sure
%this is installed correctly. If using a laptop with an integrated and
%dedicated GPU, consider turning off the dedicated GPU as this has caused
%issues in the past.
%prompter1 has been adapted from a sample strooptest prompt and heavily
%modified for Thomas's BCI experiment. Some residual parts of this original
%strooptest remain. 
%prompter one displays prompts according to the times set in the timing
%information column. In its current state, each trial lasts 8s. A block is
%composed of 42 trials with 6 trials per word. At the end of the 42 trials
%the code will pause. Pressing a key will start a new block. If you want to
%exit press and hold the escape key as it is checked each trial. 

%The response matrix produces 6 fields, the first 2 correspond to the
%appearance and disappearance times of the ready prompt. The 3rd
%corresponds to the word number that was displayed. The 4th and 5th
%correspond to the appearance and disappearance of the word prompt. The 6th
%column contains the time stamp that the block started as well as a the
%number of that block. All values are in system time. Each block is
%separated by a row of 10s to show that the results are no longer
%continuous. 

% Clear the workspace
close all;
clearvars;
sca;

% Setup PTB with some default values
PsychDefaultSetup(2);
%Screen('Preference', 'SkipSyncTests', 1);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

PsychImaging('PrepareConfiguration');sca


% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeSecs = 5;
isiTimeFrames = round(isiTimeSecs / ifi);

nominalFrameRate = Screen('NominalFrameRate', window);
second = nominalFrameRate;

% Number of frames to wait before re-drawing
waitframes = 1;

%in this script the pause function is used to control the timing of
%stimulus presentation. These parameters can be adjusted here:
ready_time = 1;
ready_stimulus_time = 1;
stimulus_time = 3;
break_time = 3;

%----------------------------------------------------------------------
%                     Colors in words and RGB
%----------------------------------------------------------------------

% We are going to use three colors for this demo. Red, Green and blue.
wordList = {'Walk', 'Lean Back', 'Left Hand', 'Right Hand', 'Left Foot', 'Right Foot', 'Think'}; 
%rgbColors = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1];

% Make the matrix which will determine our condition combinations
condMatrixBase = sort(repmat(1:6, 1, max(length(wordList)))); % original = condMatrixBase = sort(repmat(1:length(wordList), 1, max(length(wordList))));

% Number of trials per condition. We set this to one for this demo, to give
% us a total of 9 trials.
trialsPerCondition = 6; % 6 trials per class gives a total of 42 trials per block. Adjust to 7 if you drop a trial type

% Duplicate the condition matrix to get the full number of trials
condMatrix = condMatrixBase; %original = condMatrix = repmat(condMatrixBase, 1, trialsPerCondition);

% Get the size of the matrix
[~, numTrials] = size(condMatrix);

% Randomise the conditions
shuffler = Shuffle(1:numTrials);
condMatrixShuffled = condMatrix(:, shuffler);


%----------------------------------------------------------------------
%                     Make a response matrix
%----------------------------------------------------------------------

respMat = zeros(numTrials,6); %5 rows so I can display the ready time in the response matrix. The 6th row is for the session start time

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

escapeKey = KbName('ESCAPE');
[keyIsDown,secs,keyCode] = KbCheck;


% Animation loop: we loop for the total number of trials
%This doesn't work right now but I would like to be able to use the escape key to kill the window
sessioncounter = 1;
respMatSession = []; %the response matrix for the session starts empty
while 1 == 1
shuffler = Shuffle(1:numTrials);
condMatrixShuffled = condMatrix(:, shuffler);    
trial = 1;

    while trial <= numTrials

        % Word and color number
        wordNum = condMatrixShuffled(1, trial);

        % The color word and the color it is drawn in
        theWord = wordList(wordNum);

        % Cue to determine whether a response has been made
        respToBeMade = true;

        % If this is the first trial we present a start screen and wait for a
        % key-press
        if trial == 1
            DrawFormattedText(window, 'Imagine the movement \n\n Press Any Key To Begin',...
                'center', 'center', black);
            Screen('Flip', window);
            pause(2) %KbStrokeWait; %this has been switched to pause function for beta testing. Make sure to switch it back to KbStrokeWait
        end

        % Flip again to sync us to the vertical retrace at the same time as
        % drawing our fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
        Screen('Flip', window);
        pause(break_time)

        % Now we present the isi interval with fixation point minus one frame
        % because we presented the fixation point once already when getting a
        % time stamp

        % Draw the fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
        % Flip to the screen
        [~, time] = Screen('Flip', window);

        if trial == 1
            tBlockStart = GetSecs;
        end

        % Draw the ready and take a time marker

        DrawFormattedText(window, 'Ready?','center', 'center', black);
        [~, readyappear] = Screen('Flip', window);
        pause(ready_time)

        % Draw the fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
        [~, readydisappear] = Screen('Flip', window);
        pause(ready_stimulus_time)

        DrawFormattedText(window, char(theWord), 'center', 'center', black); %draw the word from the word matrix
        [~, timeappear] = Screen('Flip', window);
        pause(stimulus_time) %hold for 3seconds
        timedisappear = GetSecs;

        %fill the response matrix
        respMat(trial, 1) = readyappear;
        respMat(trial, 2) = readydisappear;
        respMat(trial, 3) = wordNum;
        respMat(trial, 4) = timeappear;
        respMat(trial, 5) = timedisappear;

        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
        Screen('Flip', window);

        [keyIsDown,secs,keyCode] = KbCheck; %Check to make sure the escape key hasn't been pressed
        if keyCode(escapeKey)
            sca
            break
        end

        trial = trial + 1;
    end

respMat(numTrials+1,:) = 10; % Implant a marker that the block has ended and that there is a break
respMat(1,6) = tBlockStart; %place the block start time in the top right corner of the resp matrix
respMat(2,6) = sessioncounter; %place a number indicating which session this block corresponds to
% End of experiment screen. We clear the screen once they have made their
% response
DrawFormattedText(window, 'Round Finished \n\n Press Any Key To Start the next round',...
    'center', 'center', black);
Screen('Flip', window);
respMatSession = [respMatSession; respMat]; %move the block into the overall session response matrix
sessioncounter = sessioncounter + 1;
pause(2) %KbStrokeWait; %this has been switched to pause function for beta testing. Make sure to switch it back to KbStrokeWait

end
sca;