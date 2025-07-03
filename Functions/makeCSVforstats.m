%Make csvs
[path2,path1] = uigetfile('*.mat','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
load([path1,path2],'AudioTab')
%Assumes they are already in date order from .mat creation
subs = unique(AudioTab.Subject);
%% Make a table with the right columns
%They're in date order now but I want them in visit order
AudioTab2 = AudioTab;
AudioTab2 = addvars(AudioTab2,zeros(size(AudioTab2,1),1),'Before','AudiogramDate','NewVariableNames','Days');
for i = 1:size(AudioTab,1)
    sub = AudioTab.Subject{i};
    ear = AudioTab.Side{i};
    %Ipsi or contra 
    switch sub
        case {'MVI001','MVI002','MVI003','MVI004','MVI007'} %Left Ear
            if contains(ear,'Left')
                AudioTab2.Side{i} = 'Ipsi';
            else
                AudioTab2.Side{i} = 'Contra';
            end
        case {'MVI005','MVI006','MVI008'} %Right Ear
            if contains(ear,'Right')
                AudioTab2.Side{i} = 'Ipsi';
            else
                AudioTab2.Side{i} = 'Contra';
            end
    end
    %Days since surgery
    switch sub
        case 'MVI001'
            surg_day = datetime(2016,08,12);
        case 'MVI002'
            surg_day = datetime(2016,11,04);
        case 'MVI003'  
            surg_day = datetime(2017,02,03);
        case 'MVI004'
            surg_day = datetime(2017,12,12);
        case 'MVI005'   
            surg_day = datetime(2018,08,24);
        case 'MVI006'
            surg_day = datetime(2018,08,31);
        case 'MVI007'
            surg_day = datetime(2019,01,14);
        case 'MVI008'    
            surg_day = datetime(2019,09,13);            
    end
    [y,m,d] = ymd(AudioTab.AudiogramDate(i));
    AudioTab2.Days(i) = days(datetime([y,m,d]) - surg_day);
end
%Remove tests that aren't AC or BC
AudioTab2 = AudioTab2(contains(AudioTab.Type,'AC')|contains(AudioTab.Type,'BC'),:);
AudioTab2.AudiogramDate = [];
%% Calculate metrics
Stat_tab = AudioTab2(:,1:3); %Will delete rows at the end
Stat_tab.ABG = zeros(size(AudioTab2,1),1);
Stat_tab.PTA = zeros(size(AudioTab2,1),1);
Stat_tab.PTA_LF = zeros(size(AudioTab2,1),1);
Stat_tab.PTA_HF = zeros(size(AudioTab2,1),1);

for i = 1:length(subs)
    sub_tab = AudioTab2(contains(AudioTab2.Subject,subs{i}),:);
    dates = unique(sub_tab.Days);
    for j = 1:length(dates)
        sub_tab2 = sub_tab(sub_tab.Days==dates(j),:);
        if size(sub_tab2,1)>4 %Fix if there are duplicates
            
        end
    end
end

