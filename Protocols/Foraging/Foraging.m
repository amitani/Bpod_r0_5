%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
function Foraging
% This protocol demonstrates control of the Island Motion olfactometer by using the hardware serial port to control an Arduino Leonardo Ethernet client. 
% Written by Josh Sanders, 10/2014.
%
% SETUP
% You will need:
% - An Island Motion olfactometer: http://island-motion.com/5.html
% - Arduino Leonardo double-stacked with the Arduino Ethernet shield and the Bpod shield
% - This computer connected to the olfactometer's Ethernet router
% - The Ethernet shield connected to the same router
% - Arduino Leonardo connected to this computer (note its COM port)
% - Arduino Leonardo programmed with the Serial Ethernet firmware (in /Bpod Firmware/SerialEthernetModule/)
%
%% protocol description
% run ladder
% turn ladder on LED 7 for 10 sec if not fall
% stop by experimenter Poke8, mouse click
% ITI 10-15
%%
global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    [indx, tf] = listdlg('ListString',{'Foraging','Forced-Alternate','Alternate','Lick'},'SelectionMode','single','PromptString','Set parameters',...
        'ListSize',[150,100]);
    if(~tf)
        indx = 1;
    end
    switch(indx)
        case 1 %Foraging
            S.GUI.LowArmProb = 0.1;
            S.GUI.HighArmProb = 0.8;
            S.GUI.MinBlock = 60;
            S.GUI.MaxBlock = 80;
            S.GUI.WaitToClear = 0;
            S.GUI.ClearOnBlockSwitch = 0;
            S.GUI.ReadyPeriod = 2;
            S.GUI.AnswerPeriod = 2;
            S.GUI.AnswerSound = 15;
            S.GUI.AnyLick = 0;
            S.GUI.RewardSoundDuration = 0.2;
            S.GUI.RewardWaterDuration = 0.1;
            S.GUI.LeftSound = 10;
            S.GUI.RightSound = 20;
            S.GUI.MinITI = 5;
            S.GUI.MaxITI = 7;
            S.GUI.ITIStep = 0.5;
            S.GUI.AlarmSound = 99; % WhiteNoize
            S.GUI.AlarmSoundDuration = 0.5;
            S.GUI.AlarmPunishment = 2;
            S.GUI.MissPunishment = 0;
            S.GUI.FAPunishment = 2; 
        case 2 %Forced alternate
            S.GUI.LowArmProb = 0;
            S.GUI.HighArmProb = 1;
            S.GUI.MinBlock = 1;
            S.GUI.MaxBlock = 1;
            S.GUI.WaitToClear = 1;
            S.GUI.ClearOnBlockSwitch = 1;
            S.GUI.ReadyPeriod = 2;
            S.GUI.AnswerPeriod = 2;
            S.GUI.AnswerSound = 15;
            S.GUI.AnyLick = 0;
            S.GUI.RewardSoundDuration = 0.2;
            S.GUI.RewardWaterDuration = 0.1;
            S.GUI.LeftSound = 10;
            S.GUI.RightSound = 20;
            S.GUI.MinITI = 5;
            S.GUI.MaxITI = 7;
            S.GUI.ITIStep = 0.5;
            S.GUI.AlarmSound = 99; % WhiteNoize
            S.GUI.AlarmSoundDuration = 0.5;
            S.GUI.AlarmPunishment = 2;
            S.GUI.MissPunishment = 0;
            S.GUI.FAPunishment = 2; 
        case 3 %Alternate
            S.GUI.LowArmProb = 0;
            S.GUI.HighArmProb = 1;
            S.GUI.MinBlock = 1;
            S.GUI.MaxBlock = 1;
            S.GUI.WaitToClear = 0;
            S.GUI.ClearOnBlockSwitch = 1;
            S.GUI.ReadyPeriod = 2;
            S.GUI.AnswerPeriod = 2;
            S.GUI.AnswerSound = 15;
            S.GUI.AnyLick = 1;
            S.GUI.RewardSoundDuration = 0.2;
            S.GUI.RewardWaterDuration = 0.1;
            S.GUI.LeftSound = 10;
            S.GUI.RightSound = 20;
            S.GUI.MinITI = 5;
            S.GUI.MaxITI = 7;
            S.GUI.ITIStep = 0.5;
            S.GUI.AlarmSound = 99; % WhiteNoize
            S.GUI.AlarmSoundDuration = 0.5;
            S.GUI.AlarmPunishment = 2;
            S.GUI.MissPunishment = 0;
            S.GUI.FAPunishment = 2; 
        case 4 % Lick
            S.GUI.LowArmProb = 1;
            S.GUI.HighArmProb = 1;
            S.GUI.MinBlock = 60;
            S.GUI.MaxBlock = 80;
            S.GUI.WaitToClear = 0;
            S.GUI.ClearOnBlockSwitch = 0;
            S.GUI.ReadyPeriod = 2;
            S.GUI.AnswerPeriod = 2;
            S.GUI.AnswerSound = 15;
            S.GUI.AnyLick = 0;
            S.GUI.RewardSoundDuration = 0.2;
            S.GUI.RewardWaterDuration = 0.1;
            S.GUI.LeftSound = 10;
            S.GUI.RightSound = 20;
            S.GUI.MinITI = 5;
            S.GUI.MaxITI = 7;
            S.GUI.ITIStep = 0.5;
            S.GUI.AlarmSound = 0; % WhiteNoize
            S.GUI.AlarmSoundDuration = 0;
            S.GUI.AlarmPunishment = 0;
            S.GUI.MissPunishment = 0;
            S.GUI.FAPunishment = 2; 
    end
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ones(5000,1);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.[200 200 1000 200]

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [425 250 500 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.2 .3 .75 .5]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',TrialTypes);
BpodNotebook('init');

%% Main trial loop
block_count = 0;
current_block_length = 0;
reward_left = 0;
reward_right = 0;
right_high = 0;

for currentTrial = 1:MaxTrials
    disp(['Trial #: ', num2str(currentTrial)]);
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    %random ITI
    min_iti=min(S.GUI.MinITI,S.GUI.MaxITI);
    max_iti=max(S.GUI.MinITI,S.GUI.MaxITI);
    itis = min_iti:S.GUI.ITIStep:max_iti;
    current_iti=itis(randi(length(itis)));
    
    if(block_count >= current_block_length)
         if(~(S.GUI.WaitToClear && (reward_left||reward_right)))
             % if wait to clear and either has a reward, continue current
             % block
             min_block = min(S.GUI.MaxBlock, S.GUI.MinBlock);
             max_block = max(S.GUI.MaxBlock, S.GUI.MinBlock);
             block_lengths = min_block:max_block;
             current_block_length = block_lengths(randi(length(block_lengths)));
             right_high = ~right_high;
             if(S.GUI.ClearOnBlockSwitch)
                 reward_left = 0;
                 reward_right = 0;
             end
         end
    end
    if(right_high)
        reward_right = reward_right | (rand(1) < S.GUI.HighArmProb);
        reward_left  = reward_left | (rand(1) < S.GUI.LowArmProb);
    else
        reward_right = reward_right | (rand(1) < S.GUI.LowArmProb);
        reward_left  = reward_left | (rand(1) < S.GUI.HighArmProb);
    end
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = addBitcodeStates(sma, currentTrial, 'Ready');
    
    if(S.GUI.AlarmSound)
        sma = AddState(sma, 'Name', 'Ready', ...
            'Timer', S.GUI.ReadyPeriod,...
            'StateChangeConditions', {'Tup', 'Answer','Port1In','Alarm',...
            'Port2In','Alarm'},...
            'OutputActions', {}); 
    else
        sma = AddState(sma, 'Name', 'Ready', ...
            'Timer', S.GUI.ReadyPeriod,...
            'StateChangeConditions', {'Tup', 'Answer'},...
            'OutputActions', {}); 
    end
    
    sma = AddState(sma, 'Name', 'Answer', ...
        'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Tup', 'Miss', 'Port1In','LeftIn',...
        'Port2In','RightIn'},...  %todo: lick
        'OutputActions', {'Serial1Code', S.GUI.AnswerSound});
    
    if(S.GUI.AnyLick)
        if(reward_right)
            sma = AddState(sma, 'Name', 'RightIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardRight'},...  
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'LeftIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardRight'},...  
                'OutputActions', {});
        else
            sma = AddState(sma, 'Name', 'RightIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardLeft'},...  
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'LeftIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardLeft'},...  
                'OutputActions', {});
        end
    else
        if(reward_right)
            sma = AddState(sma, 'Name', 'RightIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardRight'},...  
                'OutputActions', {});
        else
            sma = AddState(sma, 'Name', 'RightIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'FalseAlarm'},...  
                'OutputActions', {});
        end
        if(reward_left)
            sma = AddState(sma, 'Name', 'LeftIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardLeft'},...  
                'OutputActions', {});
        else
            sma = AddState(sma, 'Name', 'LeftIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'FalseAlarm'},...  
                'OutputActions', {});
        end
    end
    
    sma = AddState(sma, 'Name', 'RewardRight', ...
        'Timer', S.GUI.RewardSoundDuration,...
        'StateChangeConditions', {'Tup', 'WaterRight'},...  
        'OutputActions', {'Serial1Code',S.GUI.RightSound});
    sma = AddState(sma, 'Name', 'WaterRight', ...
        'Timer', S.GUI.RewardWaterDuration,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',0, 'PWM1',255});
    
    sma = AddState(sma, 'Name', 'RewardLeft', ...
        'Timer', S.GUI.RewardSoundDuration,...
        'StateChangeConditions', {'Tup', 'WaterLeft'},...  
        'OutputActions', {'Serial1Code',S.GUI.LeftSound});
    sma = AddState(sma, 'Name', 'WaterLeft', ...
        'Timer', S.GUI.RewardWaterDuration,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',0, 'PWM2',255});
    
    sma = AddState(sma, 'Name', 'FalseAlarm', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',0});
    
    sma = AddState(sma, 'Name', 'Miss', ...
        'Timer', S.GUI.MissPunishment,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',0});
    
    sma = AddState(sma, 'Name', 'Alarm', ...
        'Timer', S.GUI.AlarmSoundDuration,...
        'StateChangeConditions', {'Tup', 'AlarmPunishment'},...  
        'OutputActions', {'Serial1Code', S.GUI.AlarmSound});
    sma = AddState(sma, 'Name', 'AlarmPunishment', ...
        'Timer', S.GUI.AlarmPunishment,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',0});
    
    sma = AddState(sma, 'Name', 'ITI', ...
        'Timer', current_iti,...
        'StateChangeConditions', {'Tup', 'exit'},...  
        'OutputActions', {});
    
    
    block_count = block_count + 1;
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        UpdateOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
        if(~isnan(BpodSystem.Data.RawEvents.Trial{end}.States.RewardLeft(1)))
            reward_left = false;
        end
        if(~isnan(BpodSystem.Data.RawEvents.Trial{end}.States.RewardRight(1)))
            reward_right = false;
        end
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
% for x = 1:Data.nTrials
%     if isnan(Data.RawEvents.Trial{x}.States.LadderOFF(1))
%         Outcomes(x) = 1;% success
% %     elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
% %         Outcomes(x) = 1;
% %     else
% %         Outcomes(x) = 1;
%     end
% end
TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes)
