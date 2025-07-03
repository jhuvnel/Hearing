clear;
close all;

%% load in file
%path1 = 'R:\Chow\MATLAB\Hearing\Data\';
path1 = '/Volumes/labdata/Chow/MATLAB/Hearing/Data/';
path2 = '20220324_OnOffqselHearingTests.mat';
load([path1,path2],'AudioTab')

%% parameters
patients = {'MVI001','MVI002','MVI003','MVI004','MVI005','MVI006','MVI007','MVI008'};
implantEar = [1 1 1 1 0 0 1 0 0]; % 1 = left, 0 = right
side = {'Right','Left'}; %index using implantEar + 1
on = zeros(length(patients),9);
off = zeros(length(patients),9);

%% create figure
figure(1);
set(gcf,'DefaultAxesFontSize',16);
for i = 1:length(patients)
        subaxis(2,ceil(length(patients)/2),i,'SpacingVert',0.05,'SpacingHoriz',0.01,'Margin',0.03,'MarginLeft',0.05);
        hold on;
        if i == 1 || i == ceil(length(patients)/2)+1
            dispy = 1;
            ylabel('Threshold (dB HL)','FontSize',16);
        else
            dispy = 0;
        end
        if i > 4
            dispx = 1;
        else
            dispx = 0;
        end
        [on(i,:),off(i,:)]=plotaudio(patients{i},side(implantEar(i)+1),'AC',AudioTab,dispx,dispy);
        title(patients{i},'FontSize',16)
        
end
legend('Device Off','Device On');

on(:,6) = []; %get rid of 300hz for boxplots
off(:,6) = [];

figure;
subaxis(2,1,1,'SpacingVert',0.02,'Margin',0.07);
hold on;
plotBP(off,on);

subaxis(2,1,2,'SpacingVert',0.02,'Margin',0.07);
hold on;
plotBPfromPreOp(off-on);

%% function for plotting audiograms
function [ony,offy] = plotaudio(patient,ear,conduction,dataTbl,dispx,dispy)
tempTbl = dataTbl(ismember(dataTbl.Subject,patient) & ismember(dataTbl.Side,ear) & ismember(dataTbl.Type,conduction) & ~isundefined(dataTbl.OnOff),:);

freqs = [125,250,500,1000,2000,3000,4000,6000,8000];
freqlab = strrep(split(num2str(freqs)),'000','k');
ax = gca;
set(ax,'YDir','reverse','XAxisLocation','top','Xscale','log')
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on','XLim',[100,9000])
set(ax,'XTick',freqs,'XTickLabel',freqlab,'YTick',-10:10:120,'YLim',[-15, 125])
set(ax,'XAxisLocation','bottom');
ylab = string(ax.YAxis.TickLabels);
for i = 1:2:length(ylab)
    ylab(i) = '';
end
set(ax,'YTickLabel',ylab);
if dispx == 0
    set(ax,'XTickLabel',[]);
end
if dispy == 0
    set(ax,'YTickLabel',[]);
end

markersize = 12;
markerthick = 0.5;
linethick = 1.5;
fontSize = 8;

plot_pos = ax.Position;
YLim = ax.YLim; %lower number first
XLim = ax.XLim;
y_pos = @(y) plot_pos(2)+plot_pos(4)/(YLim(2)-YLim(1))*(YLim(2) - y);
x_pos = @(x) plot_pos(1)+plot_pos(3)/(log(XLim(2))-log(XLim(1)))*(log(x)-log(XLim(1)));

resp = tempTbl{:,6:2:22};

for i = 1:height(tempTbl)
    if ismember(tempTbl.OnOff(i),'ON')
        linestyle = '-';
        marker = 'o';
    else
        linestyle = '--';
        marker = 'x';
    end
    %Find points that are at the end of the audiometer
    out_bound = (resp(i,:)>1000);
    if any(out_bound)
        new_resp = resp(i,:)./1000;
        new_resp(~out_bound) = resp(i,~out_bound);
        out_bound_freqs = freqs(out_bound);
        out_bound_resp = new_resp(1,out_bound);
        plot(freqs(~isnan(new_resp)),new_resp(~isnan(new_resp)),'k','Marker',marker,'LineStyle',linestyle,'LineWidth',linethick,'MarkerSize',markersize)
        %plot(out_bound_freqs,out_bound_resp,'k','Marker',marker,...
        %    'MarkerSize',markersize,'LineWidth',markerthick)%,...
        %'MarkerFaceColor',[1 1 1])
        for j = 1:sum(out_bound)
            annotation('textarrow','Color','k','String','',...
                'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
        end
        y = new_resp;
    else
        plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'k','Marker',marker,'LineStyle',linestyle,'LineWidth',linethick,'MarkerSize',markersize)
        y = resp(i,:);
    end
    if ismember(tempTbl.OnOff(i),'ON')
        ony = y;
    else
        offy = y;
    end
end
end

function [] = plotBPfromPreOp(array) % plot audiogram boxplot summaries from preop
boxWidth = 0.1;
freq = [125,250,500,1000,2000,4000,6000,8000];
shapes = {'A','B','C','D','E','F','G','H'};
xpos = log(freq);
freqlab = strrep(split(num2str(freq)),'000','k');
xshift = 0.06;
markshift = 0.2;
markSize = 8;
colorArray = repmat([0 0 0; 0.2 0.2 0.2],8,1);
linew = 1.5;

medianArray = median(array,1,'omitnan');


bp = boxplot(array,'Widths',boxWidth,'Positions',xpos,'Symbol','');
set(bp,'LineWidth',linew,'LineStyle','-','Color','k');

plot(xpos,medianArray,'k-','LineWidth',linew);

for i = 1:length(array(:,1))
    for j = 1:length(freq)
        text(xpos(j)-markshift,array(i,j),shapes{i},'Color','k','HorizontalAlignment','center');
    end
end


ax = gca;
set(ax,'YDir','reverse','XAxisLocation','bottom')
set(ax,'XTick',xpos,'XTickLabel',freqlab)
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on')
set(ax,'YTick',-20:10:20,'YLim',[-20, 20])
ylab = string(ax.YAxis.TickLabels);
set(ax,'XLim',[4.6 9.4]);
% for i = 1:2:length(ylab)
%     ylab(i) = '';
% end
set(ax,'YTickLabel',ylab);
ylabel('Change in Threshold (dB)','fontSize',14);
xlabel('Frequencies (Hz)','fontSize',14);

rl = refline(0,0);
set(rl,'LineWidth',1,'LineStyle',':','Color','k');
set(gca,'children',flipud(get(gca,'children')))

end

function [] = plotBP(array1,array2) % plot audiogram boxplot summaries
boxWidth = 0.1;
freq = [125,250,500,1000,2000,4000,6000,8000];
shapes = {'A','B','C','D','E','F','G','H'};
xpos = log(freq);
freqlab = strrep(split(num2str(freq)),'000','k');
xshift = 0.06;
markshift = 0.2;
markSize = 8;
linew = 1.5;

median1Array = median(array1,1,'omitnan');
median2Array = median(array2,1,'omitnan');


bp = boxplot(array1,'Widths',boxWidth,'Positions',xpos-xshift,'Symbol','');
set(bp,'LineWidth',linew,'LineStyle','-','Color','k');
bp = boxplot(array2,'Widths',boxWidth,'Positions',xpos+xshift,'Symbol','');
set(bp,'LineWidth',linew,'LineStyle','-','Color',[0.2 0.2 0.2]);

plot(xpos-xshift,median1Array,'k-','LineWidth',linew);
plot(xpos+xshift,median2Array,':','LineWidth',linew,'Color',[0.2 0.2 0.2]);


for i = 1:length(array1(:,1))
    for j = 1:length(freq)
        text(xpos(j)-markshift,array1(i,j),shapes{i},'Color','k','HorizontalAlignment','center');
        text(xpos(j)+markshift,array2(i,j),shapes{i},'Color',[0.2 0.2 0.2],'HorizontalAlignment','center');
    end
end

h = findobj(gca,'Tag','Box'); 
for j=1:length(h)/2
patch(get(h(j),'XData'),get(h(j),'YData'),'k','FaceAlpha',0.1,'EdgeColor','none');
end 

ax = gca;
set(ax,'YDir','reverse','XAxisLocation','bottom')
set(ax,'XTick',xpos,'XTickLabel',freqlab)
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on')
set(ax,'YTick',-10:10:120,'YLim',[-15, 125])
set(ax,'XLim',[4.6 9.4]);
ylab = string(ax.YAxis.TickLabels);
% for i = 1:2:length(ylab)
%     ylab(i) = '';
% end
set(ax,'YTickLabel',ylab);
set(ax,'XTickLabel','');
ylabel('Threshold (dB)','fontSize',14);

end