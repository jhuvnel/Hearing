clear;
close all;

%% load in file
[path2,path1] = uigetfile('*.xlsx','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
AudioTab = readtable([path1 path2]);
AudioTab.Subject = char(AudioTab.Subject);
AudioTab.Side = char(AudioTab.Side);
AudioTab.Type = char(AudioTab.Type);

%% parameters
patients = {'MVI001','MVI002','MVI003','MVI004','MVI005','MVI006','MVI007','MVI008'};
visits = [0 9 10];
visitLabels = {'Pre-op','0.5 yr post-op','1 yr post-op'};


%% create figure
figure(1);
for i = 1:length(patients)
    for j = 1:length(visits)
        subaxis(length(patients),length(visits),i*(length(visits))-(length(visits)-j),'SpacingVert',0.01,'SpacingHoriz',0.01,'Margin',0.03,'MarginLeft',0.05);
        hold on;
        if j == 1
            dispy = 1;
        else
            dispy = 0;
        end
        if i == length(patients)
            dispx = 1;
        else
            dispx = 0;
        end
        if i > 7 && j == 2
            plotaudio(patients{i},visits(j)-2,AudioTab,dispx,dispy); % 8 doesn't have visit 9
        else
            plotaudio(patients{i},visits(j),AudioTab,dispx,dispy);
        end
        if i == 1
            title(visitLabels{j},'FontSize',16)
        end
        if j == 1
            ylabel(patients{i},'FontSize',16);
        end
    end
end

%% function for plotting audiograms
function [] = plotaudio(patient,visit,dataTbl,dispx,dispy)
tempTbl = dataTbl(ismember(dataTbl.Subject,patient) & dataTbl.VisitNum==visit,:);

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

markersize = 8;
markerthick = 0.5;
linethick = 1;
fontSize = 8;

plot_pos = ax.Position;
YLim = ax.YLim; %lower number first
XLim = ax.XLim;
y_pos = @(y) plot_pos(2)+plot_pos(4)/(YLim(2)-YLim(1))*(YLim(2) - y);
x_pos = @(x) plot_pos(1)+plot_pos(3)/(log(XLim(2))-log(XLim(1)))*(log(x)-log(XLim(1)));

resp = tempTbl{:,6:2:22};
mask = tempTbl{:,7:2:23};

for i = 1:height(tempTbl)
    %Find points that are at the end of the audiometer
    out_bound = isnan(resp(i,:));
    %Takes out erroneous no response values
    for j = 2:length(freqs)-1
        out_bound(j) = out_bound(j)&&(sum(out_bound(1:j-1))==length(out_bound(1:j-1))||sum(out_bound(j+1:end))==length(out_bound(j+1:end)));
    end
    if ismember(tempTbl.Type(i),'AC')
        if ismember(tempTbl.Side(i),'Left')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer 
                new_resp = [90,100,105,110,120,105,105,100,95]; %the air thresholds
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(freqs,new_resp,'b-','LineWidth',linethick)
                plot(out_bound_freqs,out_bound_resp,'b.','Marker','s',...
                    'MarkerSize',markersize,'LineWidth',markerthick)%,...
                    %'MarkerFaceColor',[1 1 1])
                for j = 1:sum(out_bound)
                    annotation('textarrow','Color','b','String','',...
                        'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'b-','LineWidth',linethick)
            end
        elseif ismember(tempTbl.Side(i),'Right')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer 
                new_resp = [90,100,105,110,120,105,105,100,95]; %the air thresholds
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(freqs,new_resp,'r-','LineWidth',linethick)
                plot(out_bound_freqs,out_bound_resp,'r.','Marker','^',...
                    'MarkerSize',markersize,'LineWidth',markerthick)%,...
                    %'MarkerFaceColor',[1 1 1])
                for j = 1:sum(out_bound)
                    annotation('textarrow','Color','r','String','',...
                        'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'r-','LineWidth',linethick)
            end
        end
    elseif ismember(tempTbl.Type(i),'BC')
        %Bone conduction doesn't happen at 125, 6k or 8k Hz
        out_bound([1,8,9]) = 0;
        if ismember(tempTbl.Side(i),'Left')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer (assumed to be a constant 100 across
                %freq)
                new_resp = [NaN,50,60,70,70,70,60,NaN,NaN]; %the bone thresholds
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(1.1*freqs,new_resp,'b:','LineWidth',linethick)                
                for j = 1:sum(out_bound)
                    text(1.1*out_bound_freqs(j),out_bound_resp(j),']',...
                        'Color','b','FontSize',fontSize);                    
                    annotation('textarrow','Color','b','String','',...
                        'X',[x_pos(1.1*out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(1.1*freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'b:','LineWidth',linethick)
            end
        elseif ismember(tempTbl.Side(i),'Right')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer (assumed to be a constant 100 across
                %freq)
                new_resp = [NaN,50,60,70,70,70,60,NaN,NaN]; %the bone thresholds
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(1.1*freqs,new_resp,'r:','LineWidth',linethick)                
                for j = 1:sum(out_bound)
                    text(1.1*out_bound_freqs(j),out_bound_resp(j),'[',...
                        'Color','r','FontSize',fontSize);                    
                    annotation('textarrow','Color','r','String','',...
                        'X',[x_pos(1.1*out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(1.1*freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'r:','LineWidth',linethick)
            end
        end
    end    
end
%Now make the markers
for i = 1:size(tempTbl,1)
    masked = ~isnan(mask(i,:));
    if ismember(tempTbl.Type(i),'AC')
        if ismember(tempTbl.Side(i),'Left')
            plot(freqs(~masked),resp(i,~masked),'b.','Marker','x',...
                'MarkerSize',markersize,'LineWidth',markerthick)%,...
                %'MarkerFaceColor',[1 1 1])
            plot(freqs(masked),resp(i,masked),'b.','Marker','s',...
                'MarkerSize',markersize,'LineWidth',markerthick)%,...
                %'MarkerFaceColor',[1 1 1])
        elseif ismember(tempTbl.Side(i),'Right')
            plot(freqs(~masked),resp(i,~masked),'r.','Marker','o',...
                'MarkerSize',markersize,'LineWidth',markerthick)%,...
                %'MarkerFaceColor',[1 1 1])
            plot(freqs(masked),resp(i,masked),'r.','Marker','^',...
                'MarkerSize',markersize,'LineWidth',markerthick)%,...
                %'MarkerFaceColor',[1 1 1])
        end
    elseif ismember(tempTbl.Type(i),'BC')
        if ismember(tempTbl.Side(i),'Left')
            not_masked_freqs = freqs(~masked);
            not_masked_resp = resp(i,~masked);
            masked_freqs = freqs(masked);
            masked_resp = resp(i,masked); 
            if ~isempty(not_masked_freqs)
                for j = 1:length(not_masked_freqs)
                    text(1.1*not_masked_freqs(j),not_masked_resp(j),'>','Color','b','FontSize',fontSize);
                end
            end
            if ~isempty(masked_freqs)
                for j = 1:length(masked_freqs)
                    text(1.1*masked_freqs(j),masked_resp(j),']','Color','b','FontSize',fontSize);
                end
            end
        elseif ismember(tempTbl.Side(i),'Right')
            not_masked_freqs = freqs(~masked);
            not_masked_resp = resp(i,~masked);
            masked_freqs = freqs(masked);
            masked_resp = resp(i,masked); 
            if ~isempty(not_masked_freqs)
                for j = 1:length(not_masked_freqs)
                    text(1.1*not_masked_freqs(j),not_masked_resp(j),'<','Color','r','FontSize',fontSize);
                end
            end
            if ~isempty(masked_freqs)
                for j = 1:length(masked_freqs)
                    text(1.1*masked_freqs(j),masked_resp(j),'[','Color','r','FontSize',fontSize);
                end
            end
        end
    end    
end

% print text SRT,CNCW, @
if ~isempty(tempTbl)
    xposes = [150 350 550 1100]+[80 -100 0 0];   % CDS052720 added +[0 -100 0 0] so LEFT ear score text doesn't overlap RIGHT ear scores
    yposes = [70 85 100 115]-10;                % CDS052720 added -10 so text doesn't overlap bottom of plot
    xposshift=0;                                % CDS052720 added so LEFT ear score text doesn't overlap RIGHT ear scores
    text(xposes(1),yposes(2),'SRT:','HorizontalAlignment','right');
    text(xposes(1),yposes(3),'CNCW:','HorizontalAlignment','right');
    text(xposes(1),yposes(4),'@:','HorizontalAlignment','right');
    text(xposes(2),yposes(1),'LEFT','Color','b','HorizontalAlignment','center');
    text(xposes(3),yposes(1),'RIGHT','Color','r');
    text(xposes(4),yposes(2),'dBHL');
    text(xposes(4),yposes(4),'dBHL');
    if ~isnan(tempTbl.WRPCNT_LFT(1))
        text(xposes(2)-xposshift,yposes(3),string(tempTbl.WRPCNT_LFT(1))+'%','Color','b'); %CDS052720 added "-xposshift" so LEFT ear score text doesn't overlap RIGHT ear scores
    end
    if ~isnan(tempTbl.WRPCNT_RT(1))
        text(xposes(3),yposes(3),string(tempTbl.WRPCNT_RT(1))+'%','Color','r');
    end
    if ~isnan(tempTbl.SPSRT_LFT(1))
        text(xposes(2)-xposshift,yposes(2),string(tempTbl.SPSRT_LFT(1)),'Color','b'); %CDS052720 added "-xposshift" so LEFT ear score text doesn't overlap RIGHT ear scores
    end
    if ~isnan(tempTbl.SPSRT_RT(1))
        text(xposes(3),yposes(2),string(tempTbl.SPSRT_RT(1)),'Color','r');
    end
    if ~isnan(tempTbl.WRDBHL_LFT(1))
        if isnan(tempTbl.WRDBEM_LFT(1))
            text(xposes(2)-xposshift,yposes(4),string(tempTbl.WRDBHL_LFT(1)),'Color','b'); %CDS052720 added "-xposshift" so LEFT ear score text doesn't overlap RIGHT ear scores
        else
            text(xposes(2)-xposshift,yposes(4),string(tempTbl.WRDBHL_LFT(1))+'+'+string(tempTbl.WRDBEM_LFT(1))+'m','Color','b'); %CDS052720 added "-xposshift" so LEFT ear score text doesn't overlap RIGHT ear scores
        end
    end
    if ~isnan(tempTbl.WRDBHL_RT(1))
        if isnan(tempTbl.WRDBEM_RT(1))
            text(xposes(3),yposes(4),string(tempTbl.WRDBHL_RT(1)),'Color','r');
        else
            text(xposes(3),yposes(4),string(tempTbl.WRDBHL_RT(1))+'+'+string(tempTbl.WRDBEM_RT(1))+'m','Color','r');
        end
    end
end
end