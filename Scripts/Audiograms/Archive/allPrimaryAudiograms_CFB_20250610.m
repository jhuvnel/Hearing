clear;
close all;

%% load in file
[path2,path1] = uigetfile('*.xlsx','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
AudioTab = readtable([path1 path2]);

%% parameters
%% parameters
patients = {'MVI001R019','MVI002R004','MVI003R140','MVI004R201','MVI005R107','MVI006R296','MVI007R765','MVI008R021','MVI009R908','MVI010R141','MVI011R031','MVI012R897','MVI013R864','MVI014R1219','MVI015R1209','MVI016R873','MVI017R1283','MVI018R1313','MVI019R1211','MVI020R124'};
letters = 'ABCDEFGHIJKLMNOPQRS';
implantEar = [1 1 1 1 0 0 1 0 1 0 1 0 1 1 1 0 0 0 1 1]; % 1 = left, 0 = right% visits = [0 3 6 9 10;
%     0 3 6 9 10;
%     0 3 6 9 10;
%     0 3 7 9 10;
%     0 4 7 9 10;
%     0 4 7 9 10;
%     0 3 7 9 9;
%     0 3 7 7 7];
%visitLabels = {'Pre-op','1 mo post-op','2 mo post-op','6 mo post-op','1 yr post-op'};

%For NEJM
% visits = [0 3 9 10 13;
%     0 3 9 10 13;
%     0 3 9 10 13;
%     0 3 9 10 12;
%     0 3 9 10 11;
%     0 3 9 10 12;
%     0 3 9 10 11;
%     0 3 9 10 10.5;
%     0 3 9 10 9;
%     0 3 9 10 7];
% pre op and most recent
visits = [0 3 9 10 17; %1
    0 3 9 10 14;    %2
    0 3 9 10 16;    %3
    0 3 9 10 15;    %4
    0 3 9 10 15;    %5
    0 3 9 10 14;    %6
    0 3 9 11 14;    %7
    0 3 7 10 13;    %8
    0 3 9 10 12;    %9
    0 3 9 10 12;    %10
    0 3 9 10 10;    %11
    0 3 9 10 10;    %12
    0 3 9 10 10;    %13
    0 3 9 10 10;    %14
    0 3 9 10 10;   %15
    0 3 9 nan 9;   %16
    0 3 9 nan 9;   %17
    0 3 nan nan 7; %18
    0 3 nan nan 3; %19
    nan 3 nan nan 3]; %20
% visits = [0 3 9 10;
%     0 3 9 10;
%     0 3 9 10;
%     0 3 9 10;
%     0 3 9 10;
%     0 3 9 10;
%     0 3 9 10;
%     0 3 9 10;
%     0 3 9 10];
%visitLabels = {'Pre-op','1 mo post-op','6 mo post-op','1 yr post-op','most recent'};
visitLabels = {'Pre-op','1 mo post-op','6 mo post-op','1 year post-op','most recent'};

%% create figure
starti = -4;
for numfigs = 1:ceil(length(patients)/5)
    figure;
    starti = starti+5;
    count = 0;
    for i = starti:starti+4
        if i >length(patients)
            break
        end
        if implantEar(i)
            plotcolor = 'b';
        else
            plotcolor = 'r';
        end
        for j = 1:length(visits(1,:))
            count = count + 1;
            %if j < length(visits(1,:))
            %figure(1);
            %subaxis(length(patients),length(visits(1,:))-1,i*(length(visits(1,:)))-(length(visits(1,:))-j),'SpacingVert',0.01,'SpacingHoriz',0.01,'Margin',0.03,'MarginLeft',0.05);
%             subaxis(5,length(visits(1,:)),i*(length(visits(1,:)))-(length(visits(1,:))-j),'SpacingVert',0.01,'SpacingHoriz',0.01,'Margin',0.03,'MarginLeft',0.05);
            subaxis(5,length(visits(1,:)),count,'SpacingVert',0.01,'SpacingHoriz',0.01,'MarginBottom',0.08,'MarginTop',0.04,'MarginLeft',0.05,'MarginRight',0.01);
            %else
            %figure(2);
            %subaxis(length(patients),1,i,'SpacingVert',0.01,'SpacingHoriz',0.01,'Margin',0.03,'MarginLeft',0.07);
            %end
            hold on;
            %if i > 6 && j == 3
            %    continue;
            %end
            if j == 1 %|| j == length(visits(1,:))
                dispy = 1;
            else
                dispy = 0;
            end
            if (i == starti+4) || (i+1 > length(patients))
                dispx = 1;
            else
                dispx = 0;
            end
            %         if i == length(patients) && j ==1
            %             a=1;
            %         end
            plotaudio(patients{i},visits(i,j),AudioTab,dispx,dispy);
            if i == starti
                title(visitLabels{j},'FontSize',12)
            end
            if j == 1
                ylabel(patients{i}(1:6),'FontSize',12,'Color',plotcolor);
            end
            if i == starti+4 && j ==3
                xlabel('Frequency (Hz)','FontSize',12)
            elseif j==3 && (i+1 > length(patients))
                xlabel('Frequency (Hz)','FontSize',12)
            end

        end
    end

    fig = gcf
    fig.Renderer = 'painters'
    fig.Renderer
    set(fig,'units','inch')
    set(fig,'Position',[0 3 11 6])
end


%% function for plotting audiograms
function [] = plotaudio(patient,visit,dataTbl,dispx,dispy)
tempTbl = dataTbl(ismember(dataTbl.Subject,patient) & dataTbl.VisitNum==visit,:);
if ~isempty(tempTbl)
    tempTbl = tempTbl(1:4,:);
end

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
    out_bound = resp(i,:)>1000;
    %Takes out erroneous no response values
%     for j = 2:length(freqs)-1
%         out_bound(j) = out_bound(j)&&(sum(out_bound(1:j-1))==length(out_bound(1:j-1))||sum(out_bound(j+1:end))==length(out_bound(j+1:end)));
%     end
    if ismember(tempTbl.Type(i),'AC')
        if ismember(tempTbl.Side(i),'Left')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer 
                %new_resp = [NaN,100,105,110,120,105,105,100,95]; %the air thresholds
                new_resp = resp(i,:)./1000;
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(freqs,new_resp,'b-','LineWidth',linethick)
                plot(out_bound_freqs,out_bound_resp,'b.','Marker','s',...
                    'MarkerSize',markersize,'LineWidth',markerthick)%,...
                    %'MarkerFaceColor',[1 1 1])
                for j = 1:sum(out_bound)
                    if ~isnan(out_bound_resp(j))
                        annotation('textarrow','Color','b','String','',...
                            'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                            'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                            'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                    end
                end
            else
                plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'b-','LineWidth',linethick)
            end
        elseif ismember(tempTbl.Side(i),'Right')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer 
                %new_resp = [NaN,100,105,110,120,105,105,100,95]; %the air thresholds
                new_resp=resp(i,:)./1000;
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(freqs,new_resp,'r-','LineWidth',linethick)
                plot(out_bound_freqs,out_bound_resp,'r.','Marker','^',...
                    'MarkerSize',markersize,'LineWidth',markerthick)%,...
                    %'MarkerFaceColor',[1 1 1])
                for j = 1:sum(out_bound)
                    if ~isnan(out_bound_resp(j))
                        annotation('textarrow','Color','r','String','',...
                            'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                            'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                            'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                    end
                end
            else
                plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'r-','LineWidth',linethick)
            end
        end
    elseif ismember(tempTbl.Type(i),'BC')
        %Bone conduction doesn't happen at 125, 6k or 8k Hz
        %out_bound([1,8,9]) = 0;
        if ismember(tempTbl.Side(i),'Left')
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer (assumed to be a constant 100 across
                %freq)
                %new_resp = [NaN,50,60,70,70,70,60,NaN,NaN]; %the bone thresholds
                new_resp = resp(i,:)./1000;
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
                %new_resp = [NaN,50,60,70,70,70,60,NaN,NaN]; %the bone thresholds
                new_resp = resp(i,:)./1000;
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
    xposes = [270 285 700 1200 2500];   % CDS052720 changed from [150 350 550 1100] and changed text alignment so LEFT ear score text doesn't overlap RIGHT ear scores
    yposes = [70 85 100 115]-5;   % CDS052720 added -10 so text doesn't overlap bottom of plot
    xposshiftL=25;                   % CDS052720 added so LEFT ear score text doesn't overlap RIGHT ear scores
    xposshiftR=50;                   % CDS052720 added so LEFT ear score text doesn't overlap RIGHT ear scores
    text(xposes(1),yposes(2),'SRT:','HorizontalAlignment','right'); % CDS052720 changed from [150 350 550 1100] and changed text alignment so LEFT ear score text doesn't overlap RIGHT ear scores
    text(xposes(1),yposes(3),'CNC:','HorizontalAlignment','right'); % CDS052720 changed from [150 350 550 1100] and changed text alignment so LEFT ear score text doesn't overlap RIGHT ear scores
    text(xposes(1),yposes(4),'@:','HorizontalAlignment','right'); % CDS052720 changed from [150 350 550 1100] and changed text alignment so LEFT ear score text doesn't overlap RIGHT ear scores
    text(xposes(2),yposes(1),'LEFT','Color','b','HorizontalAlignment','left'); % CDS052720 changed from [150 350 550 1100] and changed text alignment so LEFT ear score text doesn't overlap RIGHT ear scores
    text(xposes(3),yposes(1),'RIGHT','Color','r');
    text(xposes(4),yposes(2),'dBHL');
    tmpx = 4;
    if ~isnan(tempTbl.WRPCNT_LFT(1))
        text(xposes(2)+xposshiftL,yposes(3),string(tempTbl.WRPCNT_LFT(1))+'%','Color','b'); %CDS052720 added "+xposshiftL" so LEFT ear score text doesn't overlap RIGHT ear scores
    end
    if ~isnan(tempTbl.WRPCNT_RT(1))
        text(xposes(3)+xposshiftR,yposes(3),string(tempTbl.WRPCNT_RT(1))+'%','Color','r');
    end
    if ~isnan(tempTbl.SPSRT_LFT(1))
        if tempTbl.SPSRT_LFT(1) > 100
            text(xposes(2)+xposshiftL,yposes(2),'NR','Color','b');
        else
            text(xposes(2)+xposshiftL,yposes(2),string(tempTbl.SPSRT_LFT(1)),'Color','b'); %CDS052720 added "+xposshiftL" so LEFT ear score text doesn't overlap RIGHT ear scores
        end
    end
    if ~isnan(tempTbl.SPSRT_RT(1))
        if tempTbl.SPSRT_RT(1) > 100
            text(xposes(3)+xposshiftR,yposes(2),'NR','Color','r');
        else
            text(xposes(3)+xposshiftR,yposes(2),string(tempTbl.SPSRT_RT(1)),'Color','r');
        end
    end
    if ~isnan(tempTbl.WRDBHL_LFT(1))
        if tempTbl.WRDBHL_LFT(1) == 0
        %elseif isnan(tempTbl.WRDBEM_LFT(1))
        else
            text(xposes(2)+xposshiftL,yposes(4),string(tempTbl.WRDBHL_LFT(1)),'Color','b'); %CDS052720 added "+xposshiftL" so LEFT ear score text doesn't overlap RIGHT ear scores
            if ~isnan(tempTbl.WRDBEM_LFT(1))
                text(xposes(4),yposes(4),'('+string(tempTbl.WRDBEM_LFT(1))+'m)','Color','b'); %CDS052720 added "+xposshiftL" so LEFT ear score text doesn't overlap RIGHT ear scores
                tmpx = 5;
            end
        end
    end
    if ~isnan(tempTbl.WRDBHL_RT(1))
        if tempTbl.WRDBHL_RT(1) == 0
        %elseif isnan(tempTbl.WRDBEM_RT(1))
        else
            text(xposes(3)+xposshiftR,yposes(4),string(tempTbl.WRDBHL_RT(1)),'Color','r');
            if ~isnan(tempTbl.WRDBEM_RT(1))
                text(xposes(4),yposes(4),'('+string(tempTbl.WRDBEM_RT(1))+'m)','Color','r');
                tmpx = 5;
            end
        end
    end
    text(xposes(tmpx),yposes(4),'dBHL');
end
end

