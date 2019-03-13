% pr_preprocessSleepStaging
clc,clear
%% Room1 - database
ch_rootPath	= 'D:\Database\REM_stimulation\REM_pilot\rawFiles\Room1';
% vt_chName   = {'mgnmPilot_Room1_0001.eeg','mgnmPilot_Room1_0002.eeg'...
%             'mgnmPilot_Room1_0003.eeg','mgnmPilot_Room1_0004.eeg'...
%             'mgnmPilot_Room1_102_1.eeg','mgnmPilot_Room1_103_1.eeg'...
%             'mgnmPilot_Room1_103_2.eeg','mgnmPilot_Room1_105_1.eeg'};

vt_chName   = {'mgnmPilot_Room1_105_2.eeg'};

%% Room2_database
% ch_rootPath	= 'D:\Database\REM_stimulation\REM_pilot\rawFiles\Room2';
% vt_chName   = {'mgnmPilot_Room2_0003.eeg',...
%             'mgnmPilot_Room2_101_1.eeg','mgnmPilot_Room2_101_2.eeg'};
% vt_chName   = {'mgnmPilot_Room2_0002.eeg','mgnmPilot_Room2_102_2.eeg'};

%% Process

for ff = 1:numel(vt_chName)
    ch_filename = fullfile(ch_rootPath,vt_chName{ff});
    fprintf('\n::::: Starting new file ::::\n')
    fprintf('Selected file: %s\n',ch_filename)
    fn_preprocess_sleep_staging(ch_filename);
end
