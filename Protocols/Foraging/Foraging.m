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
            S.GUI.LowArmProb1 = 0.1;
            S.GUI.HighArmProb1 = 0.6;
            S.GUI.LowArmProb2 = 0.175;
            S.GUI.HighArmProb2 = 0.525;
            S.GUI.MinBlock = 60;
            S.GUI.MaxBlock = 80;
            S.GUI.WaitToClear = 0;
            S.GUI.ClearOnBlockSwitch = 0;
            S.GUI.ReadyPeriod1 = 2;
            S.GUI.ReadyPeriod2 = 2.5;
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
            S.GUI.FAPunishment = 0; 
        case 2 %Forced alternate
            S.GUI.LowArmProb1 = 0;
            S.GUI.HighArmProb1 = 1;
            S.GUI.LowArmProb2 = 0;
            S.GUI.HighArmProb2 = 1;
            S.GUI.MinBlock = 1;
            S.GUI.MaxBlock = 1;
            S.GUI.WaitToClear = 1;
            S.GUI.ClearOnBlockSwitch = 1;
            S.GUI.ReadyPeriod1 = 2;
            S.GUI.ReadyPeriod2 = 2.5;
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
        case 3 %Alternate
            S.GUI.LowArmProb1 = 0;
            S.GUI.HighArmProb1 = 1;
            S.GUI.LowArmProb2 = 0;
            S.GUI.HighArmProb2 = 1;
            S.GUI.MinBlock = 1;
            S.GUI.MaxBlock = 1;
            S.GUI.WaitToClear = 0;
            S.GUI.ClearOnBlockSwitch = 1;
            S.GUI.ReadyPeriod1 = 2;
            S.GUI.ReadyPeriod2 = 2.5;
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
        case 4 % Lick
            S.GUI.LowArmProb1 = 1;
            S.GUI.HighArmProb1 = 1;
            S.GUI.LowArmProb2 = 1;
            S.GUI.HighArmProb2 = 1;
            S.GUI.MinBlock = 1;
            S.GUI.MaxBlock = 1;
            S.GUI.WaitToClear = 0;
            S.GUI.ClearOnBlockSwitch = 0;
            S.GUI.ReadyPeriod1 = 2;
            S.GUI.ReadyPeriod2 = 2.5;
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
            S.GUI.AlarmSound = 0; % No Noize
            S.GUI.AlarmSoundDuration = 0;
            S.GUI.AlarmPunishment = 0;
            S.GUI.MissPunishment = 0;
    end
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ones(5000,1);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.[200 200 1000 200]

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlot = figure('Position', [425 050 450 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
BpodSystem.GUIHandles.SideOutcomePlot = axes();
BpodSystem.ProtocolFigures.LickOutcomePlot = figure('Position', [425 250 450 400],'name','Lick plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
BpodSystem.GUIHandles.LickRasterPlot = axes();
BpodSystem.ProtocolFigures.BlockPlot = figure('Position', [425 650 450 200],'name','Block plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
BpodSystem.GUIHandles.BlockPlot = axes();
BpodNotebook('init');

%% Main trial loop
block_count = 0;
block_length_list = [];
side_list = [];
current_block_length = 0;
reward_left = 0;
reward_right = 0;
right_high = randi(2)-1;
ith_block = 0;

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
             ith_block = ith_block+1;  % 1 2 3 4 ... 
             ith_prob_block = floor((ith_block-1)/2);  % 0 0 1 1 2 2 ... 
             min_block = min(S.GUI.MaxBlock, S.GUI.MinBlock);
             max_block = max(S.GUI.MaxBlock, S.GUI.MinBlock);
             block_lengths = min_block:max_block;
             current_block_length = block_lengths(randi(length(block_lengths)));
             right_high = ~right_high;
             block_length_list(end+1) = current_block_length;
             side_list(end+1) = right_high;
             if(S.GUI.ClearOnBlockSwitch)
                 reward_left = 0;
                 reward_right = 0;
             end
         else
             block_length_list(end) = block_length_list(end)+1;
         end
    end
    if(mod(ith_prob_block,2)==0)
        high_prob = S.GUI.HighArmProb1;
        low_prob = S.GUI.LowArmProb1;
    else
        high_prob = S.GUI.HighArmProb2;
        low_prob = S.GUI.LowArmProb2;
    end
    if(right_high)
        reward_right = reward_right | (rand(1) < high_prob);
        reward_left  = reward_left | (rand(1) < low_prob);
    else
        reward_right = reward_right | (rand(1) < low_prob);
        reward_left  = reward_left | (rand(1) < high_prob);
    end
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = addBitcodeStates(sma, currentTrial, 'Ready'); %PWM1
    
    if(randi(2)==1)
        current_ready_period = S.GUI.ReadyPeriod1;
    else
        current_ready_period = S.GUI.ReadyPeriod2;
    end
    if(S.GUI.AlarmSound)
        sma = AddState(sma, 'Name', 'Ready', ...
            'Timer', current_ready_period,...
            'StateChangeConditions', {'Tup', 'Answer','Port1In','Alarm',...
            'Port2In','Alarm'},...
            'OutputActions', {'PWM4',255}); 
    else
        sma = AddState(sma, 'Name', 'Ready', ...
            'Timer', current_ready_period,...
            'StateChangeConditions', {'Tup', 'Answer'},...
            'OutputActions', {'PWM4',255}); 
    end
    
    sma = AddState(sma, 'Name', 'Answer', ...
        'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Tup', 'Miss', 'Port1In','LeftIn',...
        'Port2In','RightIn'},...  %todo: lick
        'OutputActions', {'PWM4',255, 'Serial1Code', S.GUI.AnswerSound});
    
    if(S.GUI.AnyLick)
        if(reward_right)
            sma = AddState(sma, 'Name', 'RightIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardRight'},...  
                'OutputActions', {'Serial1Code', 255});
            sma = AddState(sma, 'Name', 'LeftIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardRight'},...  
                'OutputActions', {'Serial1Code', 255});
        else
            sma = AddState(sma, 'Name', 'RightIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardLeft'},...  
                'OutputActions', {'Serial1Code', 255});
            sma = AddState(sma, 'Name', 'LeftIn', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'RewardLeft'},...  
                'OutputActions', {'Serial1Code', 255});
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
    
    sma = AddState(sma, 'Name', 'RewardLeft', ...
        'Timer', S.GUI.RewardSoundDuration,...
        'StateChangeConditions', {'Tup', 'WaterLeft'},...  
        'OutputActions', {'Serial1Code',S.GUI.LeftSound});
    sma = AddState(sma, 'Name', 'WaterLeft', ...
        'Timer', S.GUI.RewardWaterDuration,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',255, 'PWM2',255});
    
    sma = AddState(sma, 'Name', 'RewardRight', ...
        'Timer', S.GUI.RewardSoundDuration,...
        'StateChangeConditions', {'Tup', 'WaterRight'},...  
        'OutputActions', {'Serial1Code',S.GUI.RightSound});
    sma = AddState(sma, 'Name', 'WaterRight', ...
        'Timer', S.GUI.RewardWaterDuration,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',255, 'PWM3',255});
    
    sma = AddState(sma, 'Name', 'FalseAlarm', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',255});
    
    sma = AddState(sma, 'Name', 'Miss', ...
        'Timer', S.GUI.MissPunishment,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',255});
    
    sma = AddState(sma, 'Name', 'Alarm', ...
        'Timer', S.GUI.AlarmSoundDuration,...
        'StateChangeConditions', {'Tup', 'AlarmPunishment'},...  
        'OutputActions', {'Serial1Code', S.GUI.AlarmSound});
    sma = AddState(sma, 'Name', 'AlarmPunishment', ...
        'Timer', S.GUI.AlarmPunishment,...
        'StateChangeConditions', {'Tup', 'ITI'},...  
        'OutputActions', {'Serial1Code',255});
    
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
        UpdateOutcomePlot(TrialTypes, BpodSystem.Data, block_length_list, side_list);
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

function UpdateOutcomePlot(TrialTypes, Data, block_length_list, side_list)
global BpodSystem

% disp(block_length_list)
% disp(side_list);


for x = 1:Data.nTrials
    LeftIn(x) = ~isnan(Data.RawEvents.Trial{x}.States.LeftIn(1));
    RightIn(x) = ~isnan(Data.RawEvents.Trial{x}.States.RightIn(1));
    RewardLeft(x) = ~isnan(Data.RawEvents.Trial{x}.States.RewardLeft(1));
    RewardRight(x) = ~isnan(Data.RawEvents.Trial{x}.States.RewardRight(1));
    Alarm(x) =  ~isnan(Data.RawEvents.Trial{x}.States.Alarm(1));
end
Rewarded = RewardLeft|RewardRight;
axes(BpodSystem.GUIHandles.SideOutcomePlot);
%%
cla;
hold on;
total_block_length = 0;
for i=1:length(block_length_list)
    if(i == length(block_length_list))
        len = length(Rewarded) - total_block_length;
    else
        len = block_length_list(i);
    end
    if(side_list(i)) % right_high
        rectangle('Position', [total_block_length+0.5, 2.5, len, 1],'EdgeColor','none','FaceColor',[1,0.8,0.8]);
    else
        rectangle('Position', [total_block_length+0.5, 0.5, len, 1],'EdgeColor','none','FaceColor',[0.8,0.8,1]);
    end 
    total_block_length = total_block_length+block_length_list(i);
end

if(~isempty(find(RightIn&Rewarded)));plot(find(RightIn&Rewarded),3,'m.');end
if(~isempty(find(RightIn&~Rewarded)));plot(find(RightIn&~Rewarded),3,'k.');end
Miss = ~(LeftIn | RightIn | Alarm);
if(~isempty(find(Miss)));plot(find(Miss),2,'c.');end
if(~isempty(find(Alarm)));plot(find(Alarm),2,'k.');end
if(~isempty(find(LeftIn&Rewarded)));plot(find(LeftIn&Rewarded),1,'c.');end
if(~isempty(find(LeftIn&~Rewarded)));plot(find(LeftIn&~Rewarded),1,'k.');end
ylim([0.5 3.5]);
set(gca,'ytick',1:3,'yticklabel',{'Left','M/A','Right'});

if(Data.nTrials > 300)
    xlim([Data.nTrials-300, Data.nTrials]);
else
    xlim([0 300]);
end
%%

axes(BpodSystem.GUIHandles.LickRasterPlot);
%%
cla;
set(gca,'Ydir','reverse')
hold on;
total_block_length = 0;
for i=1:length(block_length_list)
    if(i == length(block_length_list))
        len = length(Rewarded) - total_block_length;
    else
        len = block_length_list(i);
    end
    if(side_list(i)) % right_high
        rectangle('Position', [0, total_block_length, 11.5, len],'EdgeColor','none','FaceColor',[1,0.8,0.8]);
    else
        rectangle('Position', [0, total_block_length, 11.5, len],'EdgeColor','none','FaceColor',[0.8,0.8,1]);
    end 
    total_block_length = total_block_length+block_length_list(i);
end
%%
for x = 1:Data.nTrials
    t0 = Data.RawEvents.Trial{x}.States.Ready(1);
    answer = Data.RawEvents.Trial{x}.States.Answer(1) - t0;
    left = [];
    right = [];
    try
        left = Data.RawEvents.Trial{x}.Events.Port1In - t0;
    catch
    end
    try
        right = Data.RawEvents.Trial{x}.Events.Port2In - t0;
    catch
    end
        
    % answer, answer+2  black line
    % blue for left, red for right
    plot([answer answer],[x-1 x],'k');
    plot([answer+2 answer+2],[x-1 x],'k');
    for t = left(:)'
        plot([t t],[x-1,x],'b');
    end
    for t = right(:)'
        plot([t t],[x-1,x],'r');
    end
end

if(Data.nTrials > 50)
    ylim([Data.nTrials-50, Data.nTrials]);
else
    ylim([0 50]);
end
%%

axes(BpodSystem.GUIHandles.BlockPlot);
%%
cla
set(gca,'Ydir','normal')
hold on
total_block_length = 0;
correct_rate = zeros(length(block_length_list),1);
miss_rate = zeros(length(block_length_list),1);
alarm_rate = zeros(length(block_length_list),1);
for i=1:length(block_length_list)
    I = total_block_length+(1:block_length_list(i));
    I(I>length(RightIn))=[];
    if(side_list(i)) % right_high
        correct_rate(i) = mean(RightIn(I));
    else
        correct_rate(i) = mean(LeftIn(I));
    end
    miss_rate(i) = mean(Miss(I));
    alarm_rate(i) = mean(Alarm(I));
    
    total_block_length = total_block_length+block_length_list(i);
end
x = 1:length(alarm_rate);
plot(x,correct_rate,'g.');
plot(x, miss_rate,'c.');
plot(x, alarm_rate,'k.');
xlim([0 length(alarm_rate)+0.5]);
ylim([0 1]);


% for x = 1:Data.nTrials
%     if isnan(Data.RawEvents.Trial{x}.States.LadderOFF(1))
%         Outcomes(x) = 1;% success
% %     elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
% %         Outcomes(x) = 1;
% %     else
% %         Outcomes(x) = 1;
%     end
% end
% TrialTypeOutcomePlot(,'update',Data.nTrials+1,TrialTypes,Outcomes)
