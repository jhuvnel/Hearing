% Script for plotting quality of life survey scores starting from mvi
% server data. Note that you will need to have the Functions subfolder within 
% mvi\DATA SUMMARY\IN PROGRESS\Hearing\Functions added to your MATLAB path
% in order to run this script successfully

% Last updated on 2025-07-02 by CFB (celia@jhmi.edu)

%% Patient groups based on hearing status
close all; clear all; clc; warning off
% Load most recent QOL dataset
AudioTab = readtable("H:\Study Subjects\ALLMVI-SurveyResults.xlsx");
AudioTab = AudioTab(:,{'Subject','Date','Visit','THIOverall','AIOverall'});
AudioTab = AudioTab(~strcmp(AudioTab.Visit, ''), :);
% Remove rows ending with 'f'
rowsWithF = cellfun(@(x) endsWith(string(x), 'F'), AudioTab.Visit);
AudioTab = AudioTab(~rowsWithF, :);
% Change visit numbering to delete x or v letter and convert to double
visitProcessed = cellfun(@(x) regexprep(string(x), '[xv]$', ''), AudioTab.Visit);
AudioTab.Visit = str2double(visitProcessed);
% Patient IDs to include
patients = unique(AudioTab.Subject(contains(AudioTab.Subject,'MVI')));
% Visits we want to display
unique_visits = unique(AudioTab.Visit(~isnan(AudioTab.Visit)));
select_visits = [0; 3; unique_visits(unique_visits>8)]; % remove 1-8 visits

% Hearing status (not necessarily due to implantation). Note: particularly
% with older patients, some participants had preop hearing loss in
% implanted ear, so array below is tentative and MUST BE UPDATED DEPENDING
% ON CONTEXT OF FIGURE. E.g., mvi017 had preop hearing loss in R ear,
% mvi019 and mvi020 had bilateral high frequency hearing loss preop
groups = [1 1 1 1 0 1 0 0 0 1 1 1 1 1 0 0 0 0 1 0]; % 1 = aidable hearing or no HL, 0 = non-aidable HL
letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
letters_1 = letters(find(groups==1));
letters_0 = letters(find(groups==0));
%% Load data
AudioTab_0 = AudioTab(ismember(AudioTab.Subject,patients(groups==0)),:);
AudioTab_1 = AudioTab(ismember(AudioTab.Subject,patients(groups==1)),:);

% Option 2: If group membership is based on patient IDs in each AudioTab
patients_group_0 = intersect(patients, unique(AudioTab_0.Subject));
patients_group_1 = intersect(patients, unique(AudioTab_1.Subject));

% Get dimensions for each group
n_patients_0 = length(patients_group_0);
n_patients_1 = length(patients_group_1);
n_visits = length(select_visits);

% Initialize data matrices with appropriate sizes for each group
THI_0_data = NaN(n_patients_0, n_visits);
AI_0_data = NaN(n_patients_0, n_visits);
THI_1_data = NaN(n_patients_1, n_visits);
AI_1_data = NaN(n_patients_1, n_visits);

% Fill matrices for AudioTab_0 (Group 0)
for k = 1:height(AudioTab_0)
    patient_idx = find(strcmp(patients_group_0,AudioTab_0.Subject(k)));
    visit_idx = find(select_visits == AudioTab_0.Visit(k));
    
    if ~isempty(patient_idx) && ~isempty(visit_idx)
        THI_0_data(patient_idx, visit_idx) = AudioTab_0.THIOverall(k);
        AI_0_data(patient_idx, visit_idx) = AudioTab_0.AIOverall(k);
    end
end

% Fill matrices for AudioTab_1 (Group 1)
for k = 1:height(AudioTab_1)
    patient_idx = find(strcmp(patients_group_1,AudioTab_1.Subject(k)));
    visit_idx = find(select_visits == AudioTab_1.Visit(k));
    
    if ~isempty(patient_idx) && ~isempty(visit_idx)
        THI_1_data(patient_idx, visit_idx) = AudioTab_1.THIOverall(k);
        AI_1_data(patient_idx, visit_idx) = AudioTab_1.AIOverall(k);
    end
end

% Create column names from select_visits
visit_names = arrayfun(@(x) ['Visit_' num2str(x)], select_visits, 'UniformOutput', false);

% Create output tables with group-specific dimensions
THI_0 = array2table(THI_0_data, 'VariableNames', visit_names, 'RowNames', patients_group_0);
AI_0 = array2table(AI_0_data, 'VariableNames', visit_names, 'RowNames', patients_group_0);
THI_1 = array2table(THI_1_data, 'VariableNames', visit_names, 'RowNames', patients_group_1);
AI_1 = array2table(AI_1_data, 'VariableNames', visit_names, 'RowNames', patients_group_1);

%% Extract data from tables and determine dimensions
THI_0_data = table2array(THI_0);
THI_1_data = table2array(THI_1);
AI_0_data = table2array(AI_0);
AI_1_data = table2array(AI_1);

% Get number of visits dynamically
n_visits = width(THI_0); % or width(THI_1), should be the same
visit_labels = THI_0.Properties.VariableNames; % Get visit names from table

% Create x positions based on number of visits
xposit = 1:n_visits;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%      PLOT BOXPLOTS    %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create fig, plot data as boxplots, and format
[fig1,xpos,ymin,xwid,ywid,boxWidth,xshift,linew] = initializefig(1);

% THI plot
ha1(1) = subplot(1,2,1);
bp = boxplot(THI_0_data,'Widths',boxWidth,'Positions',xposit+xshift,'Symbol','','Whisker',3);
h = findobj(gca,'Tag','Box'); 
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),'k','FaceAlpha',0.1,'EdgeColor','none');
end
set(bp,'LineWidth',linew,'LineStyle','-','Color',[0.2 0.2 0.2]);
hold on
bp = boxplot(THI_1_data,'Widths',boxWidth,'Positions',xposit-xshift,'Symbol','','Whisker',3);
set(bp,'LineWidth',linew,'LineStyle','-','Color','k');
plot(xposit,median(THI_1_data,'omitnan'),'k:','LineWidth',1.5)
plot(xposit,median(THI_0_data,'omitnan'),':','LineWidth',1.5,'Color',[0.2 0.2 0.2])
hold off 

% Add text labels for individual data points
for i = 1:size(THI_1_data,1)
    for j = 1:n_visits
        if ~isnan(THI_1_data(i,j))
            text(j-0.3+0.05*randn,THI_1_data(i,j),letters_1(i),'FontSize',12) 
        end
    end
end
for i = 1:size(THI_0_data,1)
    for j = 1:n_visits
        if ~isnan(THI_0_data(i,j))
            text(j+0.2+0.05*randn,THI_0_data(i,j),letters_0(i),'FontSize',12,'Color',[0.2 0.2 0.2]) 
        end
    end
end

% Set x-axis properties
xlim([0.5, n_visits+0.5])
xticks(xposit)
xticklabels(strrep(visit_labels, 'Visit_', 'V'))
yticks(0:10:100)
title('THI Scores')

% AI plot
ha1(2) = subplot(1,2,2);
bp = boxplot(AI_0_data,'Widths',boxWidth,'Positions',xposit+xshift,'Symbol','','Whisker',3);
h = findobj(gca,'Tag','Box'); 
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),'k','FaceAlpha',0.1,'EdgeColor','none');
end
set(bp,'LineWidth',linew,'LineStyle','-','Color',[0.2 0.2 0.2]);
hold on
bp = boxplot(AI_1_data,'Widths',boxWidth,'Positions',xposit-xshift,'Symbol','','Whisker',3);
set(bp,'LineWidth',linew,'LineStyle','-','Color','k');
plot(xposit,median(AI_1_data,'omitnan'),'k:','LineWidth',1.5)
plot(xposit,median(AI_0_data,'omitnan'),':','LineWidth',1.5,'Color',[0.2 0.2 0.2])
hold off 

% Add text labels for individual data points
for i = 1:size(AI_1_data,1)
    for j = 1:n_visits
        if ~isnan(AI_1_data(i,j))
            text(j-0.3+0.05*randn,AI_1_data(i,j),letters_1(i),'FontSize',12) 
        end
    end
end
for i = 1:size(AI_0_data,1)
    for j = 1:n_visits
        if ~isnan(AI_0_data(i,j))
            text(j+0.2+0.05*randn,AI_0_data(i,j),letters_0(i),'FontSize',12,'Color',[0.2 0.2 0.2]) 
        end
    end
end

% Set x-axis properties
xlim([0.5, n_visits+0.5])
xticks(xposit)
xticklabels(strrep(visit_labels, 'Visit_', 'V'))
yticks([0:10:70 85])
yticklabels({'0','10','20','30','40','50','60','70','100'})
title('AI Scores')

formatfig(fig1,ha1,xpos,ymin,xwid,ywid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%     PLOT INDIVIDUAL POINTS    %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create fig, plot data as individual points, and format
[fig2,xpos,ymin,xwid,ywid,~,~,~] = initializefig(2);


% THI plot
ha2(1) = subplot(1,2,1);
plot_ind_scores(THI_0_data,THI_1_data,letters_1,letters_0,xposit)

% THI plot
ha2(2) = subplot(1,2,2);
plot_ind_scores(AI_0_data,AI_1_data,letters_1,letters_0,xposit)
formatfig(fig2,ha2,xpos,ymin,xwid,ywid)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     FIG FORMATTING FUNCTIONS    %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fig,xpos,ymin,xwid,ywid,boxWidth,xshift,linew]=initializefig(fignum)
fig = figure(fignum);
set(fig,'Color','w','Units','inches','Position',[0.5 0.5 15 4])
xmin = 0.04;
xmax = 0.99;
xspac = 0.05;
ymin = 0.12;
ymax = 0.9;
ywid = ymax-ymin;
xwid = (xmax-xmin-xspac)/2;
xpos = xmin:(xwid+xspac):xmax;
xshift = 0.06;
boxWidth = 0.1;
linew = 1.5;
end


function []=formatfig(fig,ha,xpos,ymin,xwid,ywid)
ha(1).Position = [xpos(1),ymin,xwid,ywid];
ha(2).Position = [xpos(2),ymin,xwid,ywid];
set(ha,'XTickLabels',{'Pre-Op','1 Mo','6 Mo','1 Yr','2 Yr','3 Yr','4 Yr','5 Yr','6 Yr','7 Yr','8 Yr'},...
    'XTickLabelRotation',0,'FontSize',12,'box','on')
set(ha(1),'YLim',[-7 104])
set(ha(2),'YLim',[-7 88])
title(ha(1),'Tinnitus Handicap Index (THI)')
title(ha(2),'Autophony Index (AI)')
set(ha(1:2),'XGrid','on','XMinorGrid','off','YGrid','on')
han=axes(fig,'visible','off'); 
han.XLabel.Visible='on';
xlab=xlabel(han,'Time Post-Op');
xlab.Position(2)= -0.08;
fig.Renderer = 'painters';
fontsize(fig, 12, "points")
% fontname(fig,'Times')
end


function []=plot_ind_scores(array_0,array_1,letters_1,letters_0,xposit)
medianArrayHear = median(array_1,1,'omitnan');
medianArrayNoHear = median(array_0,1,'omitnan');
prctile25ArrayHear = prctile(array_1,25,1);
prctile25ArrayNoHear = prctile(array_0,25,1);
prctile75ArrayHear = prctile(array_1,75,1);
prctile75ArrayNoHear = prctile(array_0,75,1);


color_palette = [
    0.0000, 0.4470, 0.7410; % 1. Blue
    0.8500, 0.3250, 0.0980; % 2. Burnt orange
    0.9290, 0.6940, 0.1250; % 3. Yellow
    0.4940, 0.1840, 0.5560; % 4. Purple
    0.4660, 0.6740, 0.1880; % 5. Green
    0.3010, 0.7450, 0.9330; % 6. Light blue
    0.6350, 0.0780, 0.1840; % 7. Burgundy
    0.1000, 0.1000, 0.6000; % 8. Navy blue
    0.5880, 0.2940, 0.0000; % 9. Brown
    1.0000, 0.5000, 0.1000; % 10. Orange
    0.2500, 0.2500, 0.2500; % 11. Dark gray
    0.7500, 0.0000, 0.7500; % 12. Magenta
    0.5000, 0.5000, 0.0000; % 13. Olive
    0.0000, 0.5000, 0.5000; % 14. Teal
    0.5000, 0.0000, 0.5000; % 15. Dark purple
    0.0000, 0.6000, 0.2000; % 16. Forest green
    0.8000, 0.0000, 0.2000; % 17. Crimson
    0.2000, 0.3000, 0.8000; % 18. Royal blue
    0.9000, 0.4000, 0.7000; % 19. Pink
    0.4000, 0.2000, 0.0000; % 20. Dark brown
    0.6000, 0.8000, 0.2000; % 21. Lime green
    0.0000, 0.2000, 0.4000; % 22. Dark teal
    0.7000, 0.5000, 0.0000; % 23. Gold
    0.3000, 0.0000, 0.3000; % 24. Deep purple
    0.5000, 0.7000, 0.9000; % 25. Sky blue
];
markshift = 0;
linew = 2;

patch([(xposit(~isnan(medianArrayHear))-markshift) fliplr(xposit(~isnan(medianArrayHear))-markshift)],[prctile25ArrayHear(~isnan(medianArrayHear)) fliplr(prctile75ArrayHear(~isnan(medianArrayHear)))],0.7*ones(1,3),'EdgeColor','none','FaceAlpha',0.6)
hold on
patch([(xposit(~isnan(medianArrayNoHear))-markshift) fliplr(xposit(~isnan(medianArrayNoHear))-markshift)],[prctile25ArrayNoHear(~isnan(medianArrayNoHear)) fliplr(prctile75ArrayNoHear(~isnan(medianArrayNoHear)))],0.7*ones(1,3),'EdgeColor','none','FaceAlpha',0.6)
for i = 1:length(array_1(:,1))
    for j = 1:length(array_1(1,:))
        text(xposit(j)-markshift,array_1(i,j),letters_1(i),'HorizontalAlignment','center','Color',color_palette(i,:));
    end
    currarray = array_1(i,:);
    nanarray = currarray(~isnan(currarray));
    plot(xposit(~isnan(array_1(i,:)))-markshift,nanarray,'LineWidth',0.1,'Color',color_palette(i,:))
end
for i = 1:length(array_0(:,1))
    for j = 1:length(array_0(1,:))
        text(xposit(j)+markshift,array_0(i,j),letters_0(i),'HorizontalAlignment','center','Color',color_palette(i,:));
    end
    currarray = array_0(i,:);
    nanarray = currarray(~isnan(currarray));
    plot(xposit(~isnan(array_0(i,:)))-markshift,nanarray,'LineWidth',0.1,'Color',color_palette(i,:))
end
plot(xposit,medianArrayHear,'k-','LineWidth',linew);
plot(xposit,medianArrayNoHear,'k-','LineWidth',linew);
end