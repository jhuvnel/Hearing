%This script looks for missing speech discrimination values in the table 
%and lets a user enter them if they exist

[path2,path1] = uigetfile('*.mat','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
load([path1,path2],'AudioTab')
%% Find NaN values

for i = 1:size(AudioTab,1)
   if any(isnan([AudioTab.WRPCNT_RT(i),AudioTab.WRPCNT_LFT(i)])) 
       old_vals = [AudioTab.WRDBHL_RT(i),AudioTab.WRPCNT_RT(i),...
           AudioTab.WRDBHL_LFT(i),AudioTab.WRPCNT_LFT(i),...
           AudioTab.SPSRT_RT(i),AudioTab.SPMSK_RT(i),...
           AudioTab.SPSRT_LFT(i),AudioTab.SPMSK_LFT(i)];
       sub = AudioTab.Subject{i};
       date = datestr(AudioTab.AudiogramDate(i),'mmmm dd, yyyy');
       prompt = {['Check values for ',sub,' on',newline,date,newline,...
           newline,'Right Word DBHL: '];'Right Word %: ';'Left Word DBHL: ';...
           'Left Word %: ';'Speech Thresh Right: ';'Speech Mask Right: ';...
           'Speech Thresh Left: ';'Speech Mask Left: '};
       new_vals = inputdlg(prompt,'Change Values',[1,27],strsplit(num2str(old_vals)));
       new_vals = str2num(strjoin(new_vals));
       %Write the new values
       AudioTab.WRDBHL_RT(i) = new_vals(1);
       AudioTab.WRPCNT_RT(i) = new_vals(2);
       AudioTab.WRDBHL_LFT(i) = new_vals(3);
       AudioTab.WRPCNT_LFT(i) = new_vals(4);
       AudioTab.SPSRT_RT(i) = new_vals(5);
       AudioTab.SPMSK_RT(i) = new_vals(6);
       AudioTab.SPSRT_LFT(i) = new_vals(7);
       AudioTab.SPMSK_LFT(i) = new_vals(8);
   end
end

%% save
save([path1,path2],'AudioTab')
