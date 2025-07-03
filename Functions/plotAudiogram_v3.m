[path2,path1] = uigetfile('*.mat','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
load([path1,path2],'AudioTab')
%% Subject/Date Selection
%Pick a subject
subs = unique(AudioTab.Subject);
% [indx,tf] = listdlg('PromptString','Select a subject to plot:',...
%                            'SelectionMode','single',...
%                            'ListSize',[300 300],...
%                            'ListString',subs);  
%If the user selects cancel
% if ~tf
%     error('No subject selected.')
%     %return; 
% end
for indx = 1:length(subs)
sub_tab = AudioTab(AudioTab.Subject==subs(indx),:);
sub = subs(indx);

%Pick a date
dates = unique(sub_tab.AudiogramDate,'stable');
% [indx2,tf2] = listdlg('PromptString','Select a date to plot:',...
%                            'SelectionMode','single',...
%                            'ListSize',[300 300],...
%                            'ListString',dates);  
% %If the user selects cancel
% if ~tf2
%     error('No subject selected.')
%     %return; 
% end
for indx2 = 1:length(dates)

date = datestr(dates(indx2),'mmmm dd, yyyy'); %For title
plot_tab = sub_tab(sub_tab.AudiogramDate==dates(indx2),:);
%Do right side and bone conduction first
plot_tab = sortrows(plot_tab,'Side','descend');
plot_tab = sortrows(plot_tab,'Type','ascend');
% Plot
markersize = 15;
markerthick = 1.5;
linethick = 1.5;
freqs = [125,250,500,1000,2000,3000,4000,6000,8000];
freqlab = strrep(split(num2str(freqs)),'000','k');
resp = table2array(plot_tab(:,6:2:22));
mask = table2array(plot_tab(:,7:2:23));
%Only plot L/R BC and L/R AC
figure;
ax = gca;
set(ax,'YDir','reverse','XAxisLocation','top','Xscale','log')
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on','XLim',[100,9000])
set(ax,'XTick',freqs,'XTickLabel',freqlab,'YTick',-10:10:120,'YLim',[-15, 125])
set(ax,'Position',[0.13,0.03,0.7750,0.7872])
ylabel('Hearing Level (dB HL)')
xlabel ('Frequency (Hz)')
title([sub,' Audiogram ',date])
%Make an x-axis and y-axis data to fig position coordinate set for bone
%conduction
plot_pos = ax.Position;
YLim = ax.YLim; %lower number first
XLim = ax.XLim;
y_pos = @(y) plot_pos(2)+plot_pos(4)/(YLim(2)-YLim(1))*(YLim(2) - y);
x_pos = @(x) plot_pos(1)+plot_pos(3)/(log(XLim(2))-log(XLim(1)))*(log(x)-log(XLim(1)));
hold on
for i = 1:size(plot_tab,1)
    masked = ~isnan(mask(i,:));
    %Find points that are at the end of the audiometer
    out_bound = isnan(resp(i,:));
    %Takes out erroneous no response values
    for j = 2:length(freqs)-1
        out_bound(j) = out_bound(j)&&(sum(out_bound(1:j-1))==length(out_bound(1:j-1))||sum(out_bound(j+1:end))==length(out_bound(j+1:end)));
    end
    if plot_tab.Type(i)=='AC'
        if plot_tab.Side(i)=='Left'
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer 
                new_resp = [90,100,105,110,120,105,105,100,95]; %the air thresholds
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(freqs,new_resp,'b-','LineWidth',linethick)
                plot(out_bound_freqs,out_bound_resp,'k.','Marker','s',...
                    'MarkerSize',markersize,'LineWidth',markerthick,...
                    'MarkerFaceColor',[1 1 1])
                for j = 1:sum(out_bound)
                    annotation('textarrow','Color','k','String','',...
                        'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'b-','LineWidth',linethick)
            end
        elseif plot_tab.Side(i)=='Right'
            if any(out_bound)
                %Make the response equal to the maximum threshold measured
                %by the audiometer 
                new_resp = [90,100,105,110,120,105,105,100,95]; %the air thresholds
                new_resp(~out_bound) = resp(i,~out_bound);
                out_bound_freqs = freqs(out_bound);
                out_bound_resp = new_resp(1,out_bound);
                plot(freqs,new_resp,'r-','LineWidth',linethick)
                plot(out_bound_freqs,out_bound_resp,'k.','Marker','^',...
                    'MarkerSize',markersize,'LineWidth',markerthick,...
                    'MarkerFaceColor',[1 1 1])
                for j = 1:sum(out_bound)
                    annotation('textarrow','Color','k','String','',...
                        'X',[x_pos(out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'r-','LineWidth',linethick)
            end
        end
    elseif plot_tab.Type(i)=='BC'
        %Bone conduction doesn't happen at 125, 6k or 8k Hz
        out_bound([1,8,9]) = 0;
        if plot_tab.Side(i)=='Left'
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
                        'Color','k','FontSize',20);                    
                    annotation('textarrow','Color','k','String','',...
                        'X',[x_pos(1.1*out_bound_freqs(j)),x_pos(out_bound_freqs(j))-0.005],...
                        'Y',[y_pos(out_bound_resp(j)+5),y_pos(out_bound_resp(j)+10)],...
                        'HeadStyle','vback3','HeadLength',5,'LineWidth',1);
                end
            else
                plot(1.1*freqs(~isnan(resp(i,:))),resp(i,~isnan(resp(i,:))),'b:','LineWidth',linethick)
            end
        elseif plot_tab.Side(i)=='Right'
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
                        'Color','k','FontSize',20);                    
                    annotation('textarrow','Color','k','String','',...
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
for i = 1:size(plot_tab,1)
    masked = ~isnan(mask(i,:));
    if plot_tab.Type(i)=='AC'
        if plot_tab.Side(i)=='Left'
            plot(freqs(~masked),resp(i,~masked),'k.','Marker','x',...
                'MarkerSize',markersize,'LineWidth',markerthick,...
                'MarkerFaceColor',[1 1 1])
            plot(freqs(masked),resp(i,masked),'k.','Marker','s',...
                'MarkerSize',markersize,'LineWidth',markerthick,...
                'MarkerFaceColor',[1 1 1])
        elseif plot_tab.Side(i)=='Right'
            plot(freqs(~masked),resp(i,~masked),'k.','Marker','o',...
                'MarkerSize',markersize,'LineWidth',markerthick,...
                'MarkerFaceColor',[1 1 1])
            plot(freqs(masked),resp(i,masked),'k.','Marker','^',...
                'MarkerSize',markersize,'LineWidth',markerthick,...
                'MarkerFaceColor',[1 1 1])
        end
    elseif plot_tab.Type(i)=='BC'
        if plot_tab.Side(i)=='Left'
            not_masked_freqs = freqs(~masked);
            not_masked_resp = resp(i,~masked);
            masked_freqs = freqs(masked);
            masked_resp = resp(i,masked); 
            if ~isempty(not_masked_freqs)
                for j = 1:length(not_masked_freqs)
                    text(1.1*not_masked_freqs(j),not_masked_resp(j),'>','Color','k','FontSize',20);
                end
            end
            if ~isempty(masked_freqs)
                for j = 1:length(masked_freqs)
                    text(1.1*masked_freqs(j),masked_resp(j),']','Color','k','FontSize',20);
                end
            end
        elseif plot_tab.Side(i)=='Right'
            not_masked_freqs = freqs(~masked);
            not_masked_resp = resp(i,~masked);
            masked_freqs = freqs(masked);
            masked_resp = resp(i,masked); 
            if ~isempty(not_masked_freqs)
                for j = 1:length(not_masked_freqs)
                    text(1.1*not_masked_freqs(j),not_masked_resp(j),'<','Color','k','FontSize',20);
                end
            end
            if ~isempty(masked_freqs)
                for j = 1:length(masked_freqs)
                    text(1.1*masked_freqs(j),masked_resp(j),'[','Color','k','FontSize',20);
                end
            end
        end
    end    
end
hold off
saveas(gcf,[sub,' ',strrep(date,',',''),'.jpg'])
close
end
end



