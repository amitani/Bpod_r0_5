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
function Lever
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

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.CueDuration = 5;
    S.GUI.RewardSoundDuration = 0.5;
    S.GUI.RewardWaterDuration = 0.1;
    S.GUI.PunishSoundDuration = 0.5;
    S.GUI.MinITI = 8;
    S.GUI.MaxITI = 12;
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ones(5000,1);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',TrialTypes);
BpodNotebook('init');

%% Main trial loop
for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    min_iti=min(S.GUI.MinITI,S.GUI.MaxITI);
    max_iti=max(S.GUI.MinITI,S.GUI.MaxITI);
    range_iti=max_iti-min_iti;
    current_iti=min_iti+range_iti*rand(1);
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = addBitcodeStates(sma, currentTrial, 'ITI');
    
    sma = AddState(sma, 'Name', 'ITI', ...
        'Timer', current_iti,...
        'StateChangeConditions', {'Tup', 'Cue'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'Cue', ...
        'Timer', S.GUI.CueDuration,...
        'StateChangeConditions', {'Tup', 'CueTup', 'Port1In', 'CuePort1In'},...
        'OutputActions', {'Serial1Code', 1}); 
    sma = AddState(sma, 'Name', 'CueTup', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'Punish'},...
        'OutputActions', {'Serial1Code', 255}); 
    sma = AddState(sma, 'Name', 'CuePort1In', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', {'Serial1Code', 255}); 
    
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.GUI.PunishSoundDuration,...
        'StateChangeConditions', {'Tup', 'PunishTup'},...
        'OutputActions', {'Serial1Code', 3});
    sma = AddState(sma, 'Name', 'PunishTup', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'Serial1Code', 255}); 
    
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', S.GUI.RewardWaterDuration,...
        'StateChangeConditions', {'Tup', 'RewardSound'},...
        'OutputActions', {'Serial1Code', 2, 'PWM2',255});
    sma = AddState(sma, 'Name', 'RewardSound', ...
        'Timer', max(0,S.GUI.RewardSoundDuration-S.GUI.RewardWaterDuration),...
        'StateChangeConditions', {'Tup', 'RewardTup'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'RewardTup', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'Serial1Code', 255}); 
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        UpdateOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    if ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
    else
        Outcomes(x) = 3;
    end
end
TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes)
