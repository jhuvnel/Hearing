%% Patient groups based on hearing status
close all; clear all; clc
% groups = [1 1 1 1 0 1 0 0 0 1 1 1 1 1 0 0 0];
% letters = 'ABCDEFGHIJKLMNOPQ';
groups = [1 1 1 1 0 1 0 0 0 1 1 1 1 1 0 0];
letters = 'ABCDEFGHIJKLMNOP';
letters_1 = letters(find(groups==1));
letters_0 = letters(find(groups==0));
%% Load data
[~,~,THI_vals] = xlsread('MVI-THI-AI-Results-2025-02-27.xlsx','THI');
THI_1 = cell2mat(THI_vals(find(groups==1)+1,2:5)); %preserved hearing
THI_0 = cell2mat(THI_vals(find(groups==0)+1,2:5)); %lost hearing
[~,~,AI_vals] = xlsread('MVI-THI-AI-Results-2025-02-27.xlsx','AI');
AI_1 = cell2mat(AI_vals(find(groups==1)+1,2:5)); %preserved hearing
AI_0 = cell2mat(AI_vals(find(groups==0)+1,2:5)); %lost hearing
%% Figure format
fig = figure(1);
set(fig,'Color','w','Units','inches','Position',[0.5 0.5 10 4])
xmin = 0.04;
xmax = 0.99;
xspac = 0.05;
ymin = 0.1;
ymax = 0.9;
ywid = ymax-ymin;
xwid = (xmax-xmin-xspac)/2;
xpos = xmin:(xwid+xspac):xmax;
xshift = 0.06;
xposit = 1:4;
boxWidth = 0.1;
linew = 1.5;
%% THI plot
ha(1) = subplot(1,2,1);
% boxchart(THI_1,'BoxFaceColor',[0,0,0],'MarkerStyle','none','BoxFaceAlpha',0,'BoxWidth',0.1)
% boxchart(THI_0,'BoxFaceColor',[0,0,0],'MarkerStyle','none','BoxFaceAlpha',0,'BoxWidth',0.1)
bp = boxplot(THI_0,'Widths',boxWidth,'Positions',xposit+xshift,'Symbol','','Whisker',3);
h = findobj(gca,'Tag','Box'); 
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),'k','FaceAlpha',0.1,'EdgeColor','none');
end
set(bp,'LineWidth',linew,'LineStyle','-','Color',[0.2 0.2 0.2]);
hold on
bp = boxplot(THI_1,'Widths',boxWidth,'Positions',xposit-xshift,'Symbol','','Whisker',3);
set(bp,'LineWidth',linew,'LineStyle','-','Color','k');
plot(1:4,median(THI_1,'omitnan'),'k:','LineWidth',1.5)
plot(1:4,median(THI_0,'omitnan'),':','LineWidth',1.5,'Color',[0.2 0.2 0.2])
hold off 
for i = 1:size(THI_1,1)
    for j = 1:4
        text(j-0.3+0.05*randn,THI_1(i,j),letters_1(i),'FontSize',12) 
    end
end
for i = 1:size(THI_0,1)
    for j = 1:4
        text(j+0.2+0.05*randn,THI_0(i,j),letters_0(i),'FontSize',12,'Color',[0.2 0.2 0.2]) 
    end
end
yticks(0:10:100)
%% AI plot
ha(2) = subplot(1,2,2);
bp = boxplot(AI_0,'Widths',boxWidth,'Positions',xposit+xshift,'Symbol','','Whisker',3);
h = findobj(gca,'Tag','Box'); 
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),'k','FaceAlpha',0.1,'EdgeColor','none');
end
set(bp,'LineWidth',linew,'LineStyle','-','Color',[0.2 0.2 0.2]);
hold on
bp = boxplot(AI_1,'Widths',boxWidth,'Positions',xposit-xshift,'Symbol','','Whisker',3);
set(bp,'LineWidth',linew,'LineStyle','-','Color','k');
plot(1:4,median(AI_1,'omitnan'),'k:','LineWidth',1.5)
plot(1:4,median(AI_0,'omitnan'),':','LineWidth',1.5,'Color',[0.2 0.2 0.2])
hold off 
for i = 1:size(AI_1,1)
    for j = 1:4
        text(j-0.3+0.05*randn,AI_1(i,j),letters_1(i),'FontSize',12) 
    end
end
for i = 1:size(AI_0,1)
    for j = 1:4
        text(j+0.2+0.05*randn,AI_0(i,j),letters_0(i),'FontSize',12,'Color',[0.2 0.2 0.2]) 
    end
end
yticks([0:10:70 85])
yticklabels({'0','10','20','30','40','50','60','70','100'})
%% Figure formatting
ha(1).Position = [xpos(1),ymin,xwid,ywid];
ha(2).Position = [xpos(2),ymin,xwid,ywid];
set(ha,'XTickLabels',{'Pre-Op','1 Mo Post-Op','6 Mo Post-Op','1 Yr Post-Op'},...
    'XTickLabelRotation',0,'FontSize',12,'box','on')
set(ha(1),'YLim',[-7 104])
set(ha(2),'YLim',[-7 88])
title(ha(1),'Tinnitus Handicap Index (THI)')
title(ha(2),'Autophony Index (AI)')
set(ha(1:2),'XGrid','on','XMinorGrid','off','YGrid','on')
fig.Renderer = 'painters';
fontsize(fig, 12, "points")
fontname(fig,'Times')