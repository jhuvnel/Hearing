%Plot Minimal Standard for Reporting Hearing Loss
[path2,path1] = uigetfile('*.mat','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
load([path1,path2],'AudioTab')
%Assumes they are already in date order from .mat creation
subs = unique(AudioTab.Subject);
[~,sub_inds] = ismember(AudioTab.Subject,subs);
%Find the before and now values for each subject
keep_inds = zeros(8,length(subs));
for i = 1:length(subs)
    a = find(sub_inds==i);
    keep_inds(:,i) = [a(1:4);a(end-3:end)]';
end
keep_inds = reshape(keep_inds,[],1);
keep_inds(~contains(AudioTab.Type(keep_inds),'AC')) = [];
rel_tab = AudioTab(keep_inds,:); %this still has both ears though
stim_ind = zeros(size(rel_tab,1),1);
for i = 1:size(rel_tab,1)
    sub = rel_tab.Subject{i};
    ear = rel_tab.Side{i};
    switch sub
        case {'MVI001','MVI002','MVI003','MVI004','MVI007'} %Left Ear
            if contains(ear,'Left')
                stim_ind(i) = 1;
            end
        case {'MVI005','MVI006','MVI008'} %Right Ear
            if contains(ear,'Right')
                stim_ind(i) = 1;
            end
    end
end
stim_tab = rel_tab(logical(stim_ind),:);
%% Calculate PTA like Gurgel et al

%Average 0.5, 1, 2, and 3, (if no 3, average 2 and 4 for 3 value)
f_3000Hz = stim_tab.f_3000Hz;
f_3000Hz(isnan(f_3000Hz)) = (stim_tab.f_2000Hz(isnan(f_3000Hz)) + stim_tab.f_4000Hz(isnan(f_3000Hz)))/2;
PTA = round((stim_tab.f_500Hz + stim_tab.f_1000Hz + stim_tab.f_2000Hz + f_3000Hz)/4,0);
%PTA may also be NaN if all values are NaN. In that case average the
%audiometer maximums
PTA(isnan(PTA)) = round((105 + 110 + 120 + 105)/4,0);
d_PTA = PTA(2:2:end) - PTA(1:2:end);

%Get the WRS score from the implanted ear
stim_ind2 = zeros(size(stim_tab,1),1);
for i = 1:size(stim_tab,1)
    sub = stim_tab.Subject{i};
    switch sub
        case {'MVI001','MVI002','MVI003','MVI004','MVI007'} %Left Ear
            stim_ind2(i) = 1;
        case {'MVI005','MVI006','MVI008'} %Right Ear
            stim_ind2(i) = 2;
    end
end
WRS_stim = stim_tab.WRPCNT_LFT;
WRS_stim(stim_ind2==2) = stim_tab.WRPCNT_RT(stim_ind2==2);
WRS_stim(isnan(WRS_stim)) = 0; %Make it 0% accuracy
d_WRS = WRS_stim(2:2:end) - WRS_stim(1:2:end);
%% Now to make the histogram
%One way where each person gets their marker
sub_markers = ['x','d','o','^','p','s','+','h'];
fig1 = figure;
set(fig1,'Units','inches')
fig_pos1 = get(fig1,'Position');
set(fig1,'Position',[fig_pos1(1),fig_pos1(2),3.5,3.5])
hold on
for i = 1:length(d_WRS)
    plot(d_WRS(i),-d_PTA(i),'k','Marker',sub_markers(i),'MarkerSize',10)
end
hold off
axis([-110 110 -110 110])
ax = gca;
set(ax,'XAxisLocation','top','XDir','reverse','YTickLabelRotation',90)
grid(ax,'on')
set(ax,'FontSize',8,'Position',[0.09 0.02 0.89 0.89])
%Make the axis labels
set(ax,'XTick',-100:20:100,'XTickLabel',{'-100','-80','-60','-40','-20','0','20','40','60','80','100'})
set(ax,'YTick',-100:20:100,'YTickLabel',{'-100','-80','-60','-40','-20','0','20','40','60','80','100'})
xlabel('Word Recognition Score Change (%)')
ylabel('Pure-Tone Average Change (dB)')
%Make all the arrows
x_arrow_len = 0.18;
y_arrow_len = 0.15;
annotation('arrow',0.01*[1,1],[x_arrow_len 0]+ax.Position(2),...
    'HeadLength',5,'HeadWidth',5,'LineWidth',2);
annotation('textarrow',0.05*[1,1],[0.50*x_arrow_len 0]+ax.Position(2),...
      'string','worse','HeadStyle','none','LineStyle','none','TextRotation',90,...
      'FontSize',8,'HorizontalAlignment','center'); 
annotation('arrow',0.01*[1,1],[-x_arrow_len 0]+ax.Position(2)+ax.Position(4),...
    'HeadLength',5,'HeadWidth',5,'LineWidth',2);
annotation('textarrow',0.01*[1,1],[-0.5*x_arrow_len 0]+ax.Position(2)+ax.Position(4),...
      'string','better','HeadStyle','none','LineStyle','none','TextRotation',90,...
      'FontSize',8,'HorizontalAlignment','center'); 
annotation('arrow',[y_arrow_len 0]+ax.Position(1),0.99*[1,1],'HeadLength',5,...
    'HeadWidth',5,'LineWidth',2);
annotation('textarrow',[0.25*y_arrow_len,0]+ax.Position(1),0.97*[1,1],...
      'string','better','HeadStyle','none','LineStyle','none',...
      'FontSize',8,'HorizontalAlignment','center'); 
annotation('arrow',[-y_arrow_len 0]+ax.Position(1)+ax.Position(3),0.99*[1,1],...
    'HeadLength',5,'HeadWidth',5,'LineWidth',2);
annotation('textarrow',[-0.25*y_arrow_len,0]+ax.Position(1)+ax.Position(3),0.97*[1,1],...
      'string','worse','HeadStyle','none','LineStyle','none',...
      'FontSize',8,'HorizontalAlignment','center'); 
%% Make it the standard Gurgel way too
gurgel = zeros(11,11);
for i = 1:length(d_PTA)
    if d_PTA(i) <= -41
        x_ind = 1;
    elseif ismember(d_PTA(i),-40:-31)
        x_ind = 2;
    elseif ismember(d_PTA(i),-30:-21)
        x_ind = 3;
    elseif ismember(d_PTA(i),-20:-11)
        x_ind = 4;
    elseif ismember(d_PTA(i),-10:-1)
        x_ind = 5;
    elseif d_PTA(i)==0
        x_ind = 6;
    elseif ismember(d_PTA(i),1:10)
        x_ind = 7;
    elseif ismember(d_PTA(i),11:20)
        x_ind = 8;
    elseif ismember(d_PTA(i),21:30)
        x_ind = 9;
    elseif ismember(d_PTA(i),31:40)
        x_ind = 10;    
    elseif d_PTA(i) >= 41
        x_ind = 11;
    else
        x_ind = [];
    end
    
    if d_WRS(i) >= 41
        y_ind = 1;
    elseif ismember(d_WRS(i),31:40)
        y_ind = 2;
    elseif ismember(d_WRS(i),21:30)
        y_ind = 3;
    elseif ismember(d_WRS(i),11:20)
        y_ind = 4;
    elseif ismember(d_WRS(i),1:10)
        y_ind = 5;
    elseif d_WRS(i)==0
        y_ind = 6;
    elseif ismember(d_WRS(i),-10:-1)
        y_ind = 7;
    elseif ismember(d_WRS(i),-20:-11)
        y_ind = 8;
    elseif ismember(d_WRS(i),-30:-21)
        y_ind = 9;
    elseif ismember(d_WRS(i),-40:-31)
        y_ind = 10;    
    elseif d_WRS(i) <= -41
        y_ind = 11;
    else
        y_ind = [];
    end   
    gurgel(x_ind,y_ind) = gurgel(x_ind,y_ind) + 1;
end

%% Plot the Gurgel
sub_markers = ['x','d','o','^','p','s','+','h'];
fig2 = figure;
set(fig2,'Units','inches')
fig_pos1 = get(fig2,'Position');
set(fig2,'Position',[fig_pos1(1),fig_pos1(2),3.5,3.5])
axis([-55 55 -55 55])
ax = gca;
set(ax,'XAxisLocation','top','XDir','reverse','YTickLabelRotation',90)
set(ax,'XGrid','off','YGrid','off','TickLength',[0,0])
set(ax,'FontSize',8,'Position',[0.09 0.02 0.89 0.89],'box','on')
%Make the axis labels
set(ax,'XTick',-50:10:50,'XTickLabel',{'\geq50','40','30','20','10','0','10','20','30','40','\geq50'})
set(ax,'YTick',-50:10:50,'YTickLabel',{'\geq50','40','30','20','10','0','10','20','30','40','\geq50'})
xlabel('Word Recognition Score Change (%)')
ylabel('Pure-Tone Average Change (dB)')
%Make all the arrows 
x_arrow_len = 0.18;
y_arrow_len = 0.15;
annotation('arrow',0.01*[1,1],[x_arrow_len 0]+ax.Position(2),...
    'HeadLength',5,'HeadWidth',5,'LineWidth',2);
annotation('textarrow',0.05*[1,1],[0.50*x_arrow_len 0]+ax.Position(2),...
      'string','worse','HeadStyle','none','LineStyle','none','TextRotation',90,...
      'FontSize',8,'HorizontalAlignment','center'); 
annotation('arrow',0.01*[1,1],[-x_arrow_len 0]+ax.Position(2)+ax.Position(4),...
    'HeadLength',5,'HeadWidth',5,'LineWidth',2);
annotation('textarrow',0.01*[1,1],[-0.5*x_arrow_len 0]+ax.Position(2)+ax.Position(4),...
      'string','better','HeadStyle','none','LineStyle','none','TextRotation',90,...
      'FontSize',8,'HorizontalAlignment','center'); 
annotation('arrow',[y_arrow_len 0]+ax.Position(1),0.99*[1,1],'HeadLength',5,...
    'HeadWidth',5,'LineWidth',2);
annotation('textarrow',[0.25*y_arrow_len,0]+ax.Position(1),0.97*[1,1],...
      'string','better','HeadStyle','none','LineStyle','none',...
      'FontSize',8,'HorizontalAlignment','center'); 
annotation('arrow',[-y_arrow_len 0]+ax.Position(1)+ax.Position(3),0.99*[1,1],...
    'HeadLength',5,'HeadWidth',5,'LineWidth',2);
annotation('textarrow',[-0.25*y_arrow_len,0]+ax.Position(1)+ax.Position(3),0.97*[1,1],...
      'string','worse','HeadStyle','none','LineStyle','none',...
      'FontSize',8,'HorizontalAlignment','center'); 
%Make the grid
hold on
grid_lines = -55:10:55;
for i = 1:length(grid_lines)
    xline(grid_lines(i),'b');
    yline(grid_lines(i),'b');
end
graph_vals = 50:-10:-50;  
[ix,iy,val] = find(gurgel);
for i = 1:length(ix)
   a1 = text(graph_vals(iy(i)),graph_vals(ix(i)),num2str(val(i)),...
       'FontWeight','bold','HorizontalAlignment','center','FontSize',12); 
end