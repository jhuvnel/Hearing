%% loadData.m deidentifies and loads data
function loadData_v2
%Select the file to load
[path2,path1] = uigetfile({'*.xlsx','*.xls'},'Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
in_path = [path1,path2];
[~,~,AudioDat] = xlsread(in_path);
AudioTab = cell2table([cell(size(AudioDat,1)-1,1),AudioDat(2:end,:)]);
tab_labs = AudioDat(1,:);
%Some will start with #s which matlab doesn't allow
for i = 1:length(tab_labs)
   lab = tab_labs{1,i};
   if ismember(lab(1),'0123456789')
       tab_labs{i} = ['f_',lab];
   end
end
AudioTab.Properties.VariableNames = [{'Subject'},tab_labs];
%% Deidentify by last name
AudioTab.Subject(contains(AudioTab.LastName,'Stephens')) = {'MVI001'};
AudioTab.Subject(contains(AudioTab.LastName,'Cummings')) = {'MVI002'};
AudioTab.Subject(contains(AudioTab.LastName,'McDowell')) = {'MVI003'};
AudioTab.Subject(contains(AudioTab.LastName,'Cress')) = {'MVI004'};
AudioTab.Subject(contains(AudioTab.LastName,'Croney')) = {'MVI005'};
AudioTab.Subject(contains(AudioTab.LastName,'Messer')) = {'MVI006'};
AudioTab.Subject(contains(AudioTab.LastName,'Daudelin')) = {'MVI007'};
AudioTab.Subject(contains(AudioTab.LastName,'Macauley')) = {'MVI008'};
%Remove people who were tested but not selected
AudioTab(cellfun('isempty', AudioTab.Subject),:) = [];
%Now get rid of names
AudioTab.LastName = [];
AudioTab.FirstName = [];
%% Turn date into a datetime
dates = AudioTab.AudiogramDate;
dates2 = NaT(length(dates),1);
for i = 1:length(dates)
    if contains(dates{i},':')
        dates2(i,1) = datetime(dates{i},'InputFormat','MM/dd/yyyy hh:mm:ss a');
    else
        dates2(i,1) = datetime(dates{i},'InputFormat','MM/dd/yyyy');
    end
end
AudioTab.AudiogramDate = dates2;
AudioTab = sortrows(AudioTab,[1 2 3 4]);
%% Delete duplicate rows and combine information
[~,idx] = unique(AudioTab(:,1:4),'rows');
AudioTab2 = AudioTab(1:length(idx),:); %Just to initialize the table
start_idx = idx;
end_idx = [idx(2:end)-1;length(dates)]; 

for i = 1:length(idx)
    if start_idx(i) == end_idx(i)
        AudioTab2(i,:) = AudioTab(idx(i),:);
    else %Combine rows
        AudioTab2(i,1:4) = AudioTab(idx(i),1:4);
        AudioTab2{i,5:end} = nanmean(AudioTab{start_idx(i):end_idx(i),5:end});
    end
end
AudioTab = AudioTab2;
%% Save with same name
fname = [path2(1:strfind(path2,'.')),'mat'];
save([path1,fname],'AudioTab')
writetable(AudioTab,[path1,'NEW_',path2])
end