clear;
close all;

%% load in file
path1 = 'R:\Chow\MATLAB\Hearing\Data\';
%path1 = '/Volumes/labdata/Chow/MATLAB/Hearing/Data/';
path2 = '20200916_qselHearingTests.mat';
load([path1,path2],'AudioTab')

%% parameters
patients = {'MVI001','MVI002','MVI003','MVI004','MVI005','MVI006','MVI007','MVI008'};
% visits = [0 3 6 9 10;
%     0 3 6 9 10;
%     0 3 6 9 10;
%     0 3 7 9 10;
%     0 4 7 9 10;
%     0 4 7 9 10;
%     0 3 7 9 9;
%     0 3 7 7 7];
visits = [0 3 9 10;
    0 3 9 10;
    0 3 9 10;
    0 3 9 10;
    0 4 9 10;
    0 4 9 10;
    0 3 9 9;
    0 3 8 8];
groups = [1 1 1 1 0 1 0 0];
%visitLabels = {'Pre-op','1 mo post-op','2 mo post-op','6 mo post-op'};
visitLabels = {'Pre-op','~3 wk post-op','6 mo post-op','1 year post-op'};
% Implanted Ear
implantEar = [1 1 1 1 0 0 1 0]; % 1 = left, 0 = right
% Look at Contralateral Ear
%implantEar = [0 0 0 0 1 1 0 1];
side = {'Right','Left'}; %index using implantEar + 1
scoreSide = {'_RT','_LFT'}; %index using implantEar + 1
conduction = {'BC','AC'};
freq = [125,250,500,1000,2000,3000,4000,6000,8000]; % index for array
preOpArray = zeros(length(patients),length(conduction)*length(freq));
mo6ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo1ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo2ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
yr1ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo6Array = zeros(length(patients),length(conduction)*length(freq));
mo1Array = zeros(length(patients),length(conduction)*length(freq));
mo2Array = zeros(length(patients),length(conduction)*length(freq));
yr1Array = zeros(length(patients),length(conduction)*length(freq));
cncw = zeros(length(patients),length(visits(1,:)));
azbin = zeros(length(patients),length(visits(1,:)));
azbiq = zeros(length(patients),length(visits(1,:)));
azbbn = zeros(length(patients),length(visits(1,:)));
azbbq = zeros(length(patients),length(visits(1,:)));
fontSize = 12;
ptaIdx = [3,4,5,7];

%% extract data
% row of array is patient, columns are AC/BC (2) x each freq (9) for 0.5 yrs and 1 yrs
for i = 1:length(patients)
    for j = 1:length(visits(1,:))
        for k = 1:length(conduction)
            [x,y] = getFreqArray(patients{i},visits(i,j),side{implantEar(i)+1},conduction(k),AudioTab);
            if ~isempty(x)
                for l = 1:length(x)
                    if y(1,l) > 1000
                        y(1,l) = y(1,l)/1000;
                    end
                    switch j % BC then AC
                        case 1
                            preOpArray(i,find(freq==x(1,l))*2+(k-2)) = y(1,l); % bone, then air, alternating
                        case 3
                            mo6ArrayfromPreOp(i,find(freq==x(1,l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(1,l))*2+(k-2));
                            mo6Array(i,find(freq==x(1,l))*2+(k-2)) = y(1,l);
                        case 2
                            mo1ArrayfromPreOp(i,find(freq==x(1,l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(1,l))*2+(k-2));
                            mo1Array(i,find(freq==x(1,l))*2+(k-2)) = y(1,l);
                        %case 3
                        %    mo2ArrayfromPreOp(i,find(freq==x(1,l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(1,l))*2+(k-2));
                        %    mo2Array(i,find(freq==x(1,l))*2+(k-2)) = y(1,l);
                        case 4
                            yr1ArrayfromPreOp(i,find(freq==x(1,l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(1,l))*2+(k-2));
                            yr1Array(i,find(freq==x(1,l))*2+(k-2)) = y(1,l);
                    end
                end
            end
            [cncw(i,j),azbin(i,j),azbiq(i,j),azbbn(i,j),azbbq(i,j)] = getWordScoreArray(patients{i},visits(i,j),scoreSide{implantEar(i)+1},AudioTab);
        end
    end
end
%hard code in to remove 7 and 8 from visit 10
cncw(7:8,4) = nan;
azbin(7:8,4) = nan;
azbiq(7:8,4) = nan;
azbbn(7:8,4) = nan;
azbbq(7:8,4) = nan;
cncwfromPreOp = cncw-cncw(:,1);
azbinfromPreOp = azbin-azbin(:,1);
azbiqfromPreOp = azbiq-azbiq(:,1);
azbbnfromPreOp = azbbn-azbbn(:,1);
azbbqfromPreOp = azbbq-azbbq(:,1);

% Calculate Pure Tones
% First, in sV006 report style (.5, 1, 2, 4 kHz)
puretone(:,1) = mean(preOpArray(:,ptaIdx*2),2,'omitnan');
puretone(:,3) = mean(mo6Array(:,ptaIdx*2),2,'omitnan');
puretone(:,2) = mean(mo1Array(:,ptaIdx*2),2,'omitnan');
%puretone(:,3) = mean(mo2Array(:,ptaIdx*2),2,'omitnan');
puretone(:,4) = mean(yr1Array(:,ptaIdx*2),2,'omitnan');
puretone(puretone == 0) = nan;
puretone(7:8,4) = nan;
puretoneACfromPreOp = puretone-puretone(:,1);
puretoneBC(:,1) = mean(preOpArray(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(:,3) = mean(mo6Array(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(:,2) = mean(mo1Array(:,(ptaIdx*2)-1),2,'omitnan');
%puretoneBC(:,3) = mean(mo2Array(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(:,4) = mean(yr1Array(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(puretoneBC == 0) = nan;
puretoneBC(7:8,4) = nan;
puretoneBCfromPreOp = puretoneBC-puretoneBC(:,1);

spacev = 0.02;
spaceh = 0.02;
marginTB = 0.07;
margin = 0.03;

% column one - not split by outcome
figure; %cncw & azbio boxplots
subaxis(4,2,5,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); %cncw %
hold on;
plotCNCWScoreBPfromPreOp(cncwfromPreOp,ones(1,8),true,false,visitLabels);
ylabel('CNCWD Implanted Ear (%)');


subaxis(4,2,7,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); %azbio
hold on;
plotAZBioScoreBPfromPreOp(azbbnfromPreOp,ones(1,8),true,true,visitLabels);
ylabel('AZBio in Soundfield (%)');

subaxis(4,2,1,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); % puretone 2 ways
hold on;
plotPTABPfromPreOp(puretoneACfromPreOp,ones(1,8),true,false,visitLabels);
ylabel('Air-Conducted PTA Implanted Ear (dB HL)');
pause(1);

subaxis(4,2,3,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); % puretone 2 ways
hold on;
plotPTABPfromPreOp(puretoneBCfromPreOp,ones(1,8),true,false,visitLabels);
ylabel('Bone-Conducted PTA of Implanted Ear (dB HL)');
pause(1);

% column two - split by outcome
subaxis(4,2,6,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); %cncw %
hold on;
plotCNCWScoreBPfromPreOp(cncwfromPreOp,groups,false,false,visitLabels);


subaxis(4,2,8,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); %azbio
hold on;
plotAZBioScoreBPfromPreOp(azbbnfromPreOp,groups,false,true,visitLabels);

subaxis(4,2,2,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); % puretone 2 ways
hold on;
plotPTABPfromPreOp(puretoneACfromPreOp,groups,false,false,visitLabels);
pause(1);

subaxis(4,2,4,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginTop',marginTB,'MarginBottom',marginTB); % puretone 2 ways
hold on;
plotPTABPfromPreOp(puretoneBCfromPreOp,groups,false,false,visitLabels);
pause(1);


%% Stats and Tabulation
cncwOutput = zeros(length(cncw(1,:)),6);
azbinOutput = zeros(length(azbin(1,:)),6);
azbiqOutput = zeros(length(azbiq(1,:)),6);
azbbnOutput = zeros(length(azbbn(1,:)),6);
azbbqOutput = zeros(length(azbbq(1,:)),6);
ptavS006ACOutput = zeros(length(puretone(1,:)),6);
ptavS006BCOutput = zeros(length(puretoneBC(1,:)),6);
for i = 1:length(cncw(1,:))
    if i == length(cncw(1,:))
        cncwOutput(i,:) = MedianIQRCIpForArray(cncw(1:end-2,i));
        azbinOutput(i,:) = MedianIQRCIpForArray(azbin(1:end-2,i));
        azbiqOutput(i,:) = MedianIQRCIpForArray(azbiq(1:end-2,i));
        azbbnOutput(i,:) = MedianIQRCIpForArray(azbbn(1:end-2,i));
        azbbqOutput(i,:) = MedianIQRCIpForArray(azbbq(1:end-2,i));
        ptavS006ACOutput(i,:) = MedianIQRCIpForArray(puretone(1:end-2,i));
        ptavS006BCOutput(i,:) = MedianIQRCIpForArray(puretoneBC(1:end-2,i));
    else
        
        cncwOutput(i,:) = MedianIQRCIpForArray(cncw(:,i));
        azbinOutput(i,:) = MedianIQRCIpForArray(azbin(:,i));
        azbiqOutput(i,:) = MedianIQRCIpForArray(azbiq(:,i));
        azbbnOutput(i,:) = MedianIQRCIpForArray(azbbn(:,i));
        azbbqOutput(i,:) = MedianIQRCIpForArray(azbbq(:,i));
        ptavS006ACOutput(i,:) = MedianIQRCIpForArray(puretone(:,i));
        ptavS006BCOutput(i,:) = MedianIQRCIpForArray(puretoneBC(:,i));
    end
end

% Paired Data - compare to pre-op & compare AC to BC
% ptaPairedOutputACvBC = zeros(length(puretone(1,:)),8);
% for i = 1:length(puretone(1,:))
%     ptaPairedOutputACvBC(i,:) = MedianIQRCIpForPairedData(puretone(:,i),puretoneBC(:,i));
% end

% Paired Data - compare to pre-op
cncwPairedOutput = zeros(length(cncw(1,:))-1,9);
azbinPairedOutput = zeros(length(cncw(1,:))-1,9);
azbiqPairedOutput = zeros(length(cncw(1,:))-1,9);
azbbnPairedOutput = zeros(length(cncw(1,:))-1,9);
azbbqPairedOutput = zeros(length(cncw(1,:))-1,9);
ptaACPairedOutput = zeros(length(cncw(1,:))-1,9);
ptaBCPairedOutput = zeros(length(cncw(1,:))-1,9);
for i = 2:length(cncw(1,:))
    cncwPairedOutput(i-1,:) = MedianIQRCIpForPairedData(cncw(:,1),cncw(:,i));
    azbinPairedOutput(i-1,:) = MedianIQRCIpForPairedData(azbin(:,1),azbin(:,i));
    azbiqPairedOutput(i-1,:) = MedianIQRCIpForPairedData(azbiq(:,1),azbiq(:,i));
    azbbnPairedOutput(i-1,:) = MedianIQRCIpForPairedData(azbbn(:,1),azbbn(:,i));
    azbbqPairedOutput(i-1,:) = MedianIQRCIpForPairedData(azbbq(:,1),azbbq(:,i));
    ptaACPairedOutput(i-1,:) = MedianIQRCIpForPairedData(puretone(:,1),puretone(:,i));
    ptaBCPairedOutput(i-1,:) = MedianIQRCIpForPairedData(puretoneBC(:,1),puretoneBC(:,i));
end

% Paired Data - quiet v noise
% azbiPairedOutput = zeros(5,8);
% azbbPairedOutput = zeros(5,8);
% for i = 1:4
%     azbiPairedOutput(i,:) = MedianIQRCIpForPairedData(azbin(:,i),azbiq(:,i));
%     azbbPairedOutput(i,:) = MedianIQRCIpForPairedData(azbbn(:,i),azbbq(:,i));
% end

%% function for plotting audiograms
function [x,y] = getFreqArray(patient,visit,implantedEar,conduction,dataTbl) % get audiogram @ all frequencies
patientRow = ismember(dataTbl.Subject,patient);
visitRow = dataTbl.VisitNum==visit;
earRow = ismember(dataTbl.Side,implantedEar);
conductRow = ismember(dataTbl.Type,conduction);
tempTbl = dataTbl(patientRow & visitRow & earRow & conductRow,:);

freq = [125,250,500,1000,2000,3000,4000,6000,8000];

if ~isempty(tempTbl)
    resp = tempTbl{:,6:2:22};
    
    for i = 1 % first response only
        x = freq;
        y = resp;
    end
else
    x = [nan nan nan nan nan nan nan nan nan];
    y = [nan nan nan nan nan nan nan nan nan];
end
end

function [CNCWPrct,AZBioIEN, AZBioIEQ, AZBioBEN, AZBioBEQ] = getWordScoreArray(patient,visit,implantedEar,dataTbl) % get word scores
patientRow = ismember(dataTbl.Subject,patient);
visitRow = dataTbl.VisitNum==visit;
tempTbl = dataTbl(patientRow & visitRow,:);
wrdprcntLab = strcat('tempTbl.WRPCNT',implantedEar,'(1)');
azbioNLab = strcat('tempTbl.Azbio_N',implantedEar(1:2),'(1)');
azbioQLab = strcat('tempTbl.Azbio_Q',implantedEar(1:2),'(1)');
azbioBNLab = 'tempTbl.Azbio_N_B(1)';
azbioBQLab = 'tempTbl.Azbio_Q_B(1)';
wrdbhlLab = strcat('tempTbl.WRDBHL',implantedEar,'(1)');

if ~isempty(tempTbl)
    for i = 1
        CNCWPrct = eval(wrdprcntLab);
        AZBioIEN = eval(azbioNLab);
        AZBioIEQ = eval(azbioQLab);
        AZBioBEN = eval(azbioBNLab);
        AZBioBEQ = eval(azbioBQLab);
        WRdbHL = eval(wrdbhlLab);
    end
else
    CNCWPrct = nan;
    AZBioIEN = nan;
    AZBioIEQ = nan;
    AZBioBEN = nan;
    AZBioBEQ = nan;
    WRdbHL = nan;
end
end



function [] = plotCNCWScoreBPfromPreOp(array,groups,ylab,xlab,titles) % plot word score summaries
boxWidth = 0.1;
shapes = {'x','d','o','^','p','s','+','h'};
markshift = 0.2;
markSize = 8;
xshift = 0.06;
linew = 1;
xpos = [0 1 2 3];

medianArrayHear = median(array(groups==1,:),1,'omitnan');
medianArrayNoHear = median(array(groups==0,:),1,'omitnan');

maxArrayHear = max(array(groups==1,:),[],1,'omitnan');
maxArrayNoHear = max(array(groups==0,:),[],1,'omitnan');

minArrayHear = min(array(groups==1,:),[],1,'omitnan');
minArrayNoHear = min(array(groups==0,:),[],1,'omitnan');

for i=1:length(xpos)
    text(xpos(i)-xshift,maxArrayHear(i),'-','HorizontalAlignment','right','VerticalAlignment','middle');
    text(xpos(i)-xshift,minArrayHear(i),'-','HorizontalAlignment','right','VerticalAlignment','middle');
    plot([xpos(i) xpos(i)]-xshift,[maxArrayHear(i) minArrayHear(i)],'k-');
end
if ~isempty(minArrayNoHear)
for i=1:length(xpos)
    text(xpos(i)+xshift,maxArrayNoHear(i),'-','HorizontalAlignment','left','VerticalAlignment','middle','Color',[0.2,0.2,0.2]);
    text(xpos(i)+xshift,minArrayNoHear(i),'-','HorizontalAlignment','left','VerticalAlignment','middle','Color',[0.2,0.2,0.2]);
    plot([xpos(i) xpos(i)]+xshift,[maxArrayNoHear(i) minArrayNoHear(i)],'-','Color',[0.2 0.2 0.2]);
end
end

plot(xpos(1:end-1)-xshift,medianArrayHear(1:end-1),'k.-','LineWidth',linew,'markerSize',14);
plot(xpos(1:end-1)+xshift,medianArrayNoHear(1:end-1),'.:','LineWidth',linew,'Color',[0.2 0.2 0.2],'markerSize',14);
plot(xpos(length(xpos))-xshift,medianArrayHear(length(medianArrayHear)),'k.','LineWidth',linew,'markerSize',14);
plot(xpos(length(xpos))+xshift,medianArrayNoHear(length(medianArrayNoHear)),'.','LineWidth',linew,'Color',[0.2 0.2 0.2],'markerSize',14);

for i = 1:length(array(:,1))
    for j = 1:length(array(1,:))
        if groups(i) == 1
            plot(xpos(j)-markshift,array(i,j),'Marker',shapes{i},'Color','k');
        else
            plot(xpos(j)+markshift,array(i,j),'Marker',shapes{i},'Color','k');
        end
    end
end

rl = refline(0,0);
set(rl,'LineWidth',1,'LineStyle',':','Color','k');


ax = gca;
set(ax,'XTick',xpos);
if xlab == 1
    set(ax,'XTickLabel',titles);
else
    set(ax,'XTickLabel','');
end
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on')
set(ax,'YTick',-100:10:20,'YLim',[-100, 15])
set(ax,'XLim',[-0.3,3.3]);
if ylab == 1
    ylabe = string(ax.YAxis.TickLabels);
    set(ax,'YTickLabel',ylabe);
else
    set(ax,'YTickLabel','');
end

end

function [] = plotAZBioScoreBPfromPreOp(noiseArray,groups,ylab,xlab,titles) % plot word score summaries
boxWidth = 0.1;
shapes = {'x','d','o','^','p','s','+','h'};
markshift = 0.2;
markSize = 8;
linew = 1.5;
xshift = 0.06;
xpos = [0 1 2 3];

medianNArrayHear = median(noiseArray(groups==1,:),1,'omitnan');
medianNArrayNoHear = median(noiseArray(groups==0,:),1,'omitnan');

maxArrayHear = max(noiseArray(groups==1,:),[],1,'omitnan');
maxArrayNoHear = max(noiseArray(groups==0,:),[],1,'omitnan');

minArrayHear = min(noiseArray(groups==1,:),[],1,'omitnan');
minArrayNoHear = min(noiseArray(groups==0,:),[],1,'omitnan');

for i=1:length(xpos)
    text(xpos(i)-xshift,maxArrayHear(i),'-','HorizontalAlignment','right','VerticalAlignment','middle');
    text(xpos(i)-xshift,minArrayHear(i),'-','HorizontalAlignment','right','VerticalAlignment','middle');
    plot([xpos(i) xpos(i)]-xshift,[maxArrayHear(i) minArrayHear(i)],'k-');
end
if ~isempty(minArrayNoHear)
for i=1:length(xpos)
    text(xpos(i)+xshift,maxArrayNoHear(i),'-','HorizontalAlignment','left','VerticalAlignment','middle','Color',[0.2,0.2,0.2]);
    text(xpos(i)+xshift,minArrayNoHear(i),'-','HorizontalAlignment','left','VerticalAlignment','middle','Color',[0.2,0.2,0.2]);
    plot([xpos(i) xpos(i)]+xshift,[maxArrayNoHear(i) minArrayNoHear(i)],'-','Color',[0.2 0.2 0.2]);
end
end

plot(xpos(1:end-1)-xshift,medianNArrayHear(1:end-1),'k.-','LineWidth',linew,'markerSize',14);
plot(xpos(1:end-1)+xshift,medianNArrayNoHear(1:end-1),'.:','LineWidth',linew,'Color',[0.2 0.2 0.2],'markerSize',14);
plot(xpos(length(xpos))-xshift,medianNArrayHear(length(medianNArrayHear)),'k.','LineWidth',linew,'markerSize',14);
plot(xpos(length(xpos))+xshift,medianNArrayNoHear(length(medianNArrayNoHear)),'.','LineWidth',linew,'Color',[0.2 0.2 0.2],'markerSize',14);

for i = 1:length(noiseArray(:,1))
    for j = 1:length(noiseArray(1,:))
        if groups(i) == 1
            plot(xpos(j)-markshift,noiseArray(i,j),'Marker',shapes{i},'Color','k');
        else
            plot(xpos(j)+markshift,noiseArray(i,j),'Marker',shapes{i},'Color','k');
        end
    end
end

set(gca,'children',flipud(get(gca,'children')))

rl = refline(0,0);
set(rl,'LineWidth',1,'LineStyle',':','Color','k');

ax = gca;
set(ax,'XTick',xpos);
if xlab == 1
    set(ax,'XTickLabel',titles);
else
    set(ax,'XTickLabel','');
end
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on')
set(ax,'YTick',-100:10:20,'YLim',[-100, 15])
set(ax,'XLim',[-0.3,3.3]);
if ylab == 1
    ylabe = string(ax.YAxis.TickLabels);
    set(ax,'YTickLabel',ylabe);
else
    set(ax,'YTickLabel','');
end

end


function [] = plotPTABPfromPreOp(array,groups,ylab,xlab,titles) % plot pure tone average summaries
boxWidth = 0.1;
shapes = {'x','d','o','^','p','s','+','h'};
markshift = 0.2;
markSize = 8;
linew = 1.5;
xshift = 0.06;
xpos = [0 1 2 3];

medianArrayHear = median(array(groups==1,:),1,'omitnan');
medianArrayNoHear = median(array(groups==0,:),1,'omitnan');

maxArrayHear = max(array(groups==1,:),[],1,'omitnan');
maxArrayNoHear = max(array(groups==0,:),[],1,'omitnan');

minArrayHear = min(array(groups==1,:),[],1,'omitnan');
minArrayNoHear = min(array(groups==0,:),[],1,'omitnan');

for i=1:length(xpos)
    text(xpos(i)-xshift,maxArrayHear(i),'-','HorizontalAlignment','right','VerticalAlignment','middle');
    text(xpos(i)-xshift,minArrayHear(i),'-','HorizontalAlignment','right','VerticalAlignment','middle');
    plot([xpos(i) xpos(i)]-xshift,[maxArrayHear(i) minArrayHear(i)],'k-');
end
if ~isempty(minArrayNoHear)
for i=1:length(xpos)
    text(xpos(i)+xshift,maxArrayNoHear(i),'-','HorizontalAlignment','left','VerticalAlignment','middle','Color',[0.2,0.2,0.2]);
    text(xpos(i)+xshift,minArrayNoHear(i),'-','HorizontalAlignment','left','VerticalAlignment','middle','Color',[0.2,0.2,0.2]);
    plot([xpos(i) xpos(i)]+xshift,[maxArrayNoHear(i) minArrayNoHear(i)],'-','Color',[0.2 0.2 0.2]);
end
end

plot(xpos(1:end-1)-xshift,medianArrayHear(1:end-1),'k.-','LineWidth',linew,'markerSize',14);
plot(xpos(1:end-1)+xshift,medianArrayNoHear(1:end-1),'.:','LineWidth',linew,'Color',[0.2 0.2 0.2],'markerSize',14);
plot(xpos(length(xpos))-xshift,medianArrayHear(length(medianArrayHear)),'k.','LineWidth',linew,'markerSize',14);
plot(xpos(length(xpos))+xshift,medianArrayNoHear(length(medianArrayNoHear)),'.','LineWidth',linew,'Color',[0.2 0.2 0.2],'markerSize',14);

for i = 1:length(array(:,1))
    for j = 1:length(array(1,:))
        if groups(i) == 1
            plot(xpos(j)-markshift,array(i,j),'Marker',shapes{i},'Color','k');
        else
            plot(xpos(j)+markshift,array(i,j),'Marker',shapes{i},'Color','k');
        end
    end
end


rl = refline(0,0);
set(rl,'LineWidth',1,'LineStyle',':','Color','k');

ax = gca;
set(ax,'YDir','reverse','XAxisLocation','bottom')
set(ax,'XTick',xpos);
if xlab == 1
    set(ax,'XTickLabel',titles);
else
    set(ax,'XTickLabel','');
end
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on')
set(ax,'YTick',0:10:120,'YLim',[-5, 115])
set(ax,'XLim',[-0.3,3.3]);
if ylab == 1
    ylabe = string(ax.YAxis.TickLabels);
    set(ax,'YTickLabel',ylabe);
else
    set(ax,'YTickLabel','');
end

end


function output = MedianIQRCIpForPairedData (dat1,dat2)
% outputs Median, 25th percentile, 75th percentile, lower end of 95% CI, upper end of 95% CI, and p using Wilcoxon Sign Rank test
% and approach in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2545906/
% and http://www.real-statistics.com/non-parametric-tests/wilcoxon-signed-ranks-test/signed-ranks-median-confidence-interval/
% day1 and dat2 shoud be columen vectors of the same liength (because they are paired data)

N=sum(~isnan(dat1) & ~isnan(dat2));
if ~iscolumn(dat1) || ~iscolumn(dat2) || N < 4 %|| N<6 || sum(~isnan(dat1)) < 6 || sum(~isnan(dat2)) < 6
    beep;
    output = [nan nan nan nan nan nan nan nan nan];
    disp('error in function MedianIQRCIpForPairedData - dat1 and dat2 should be paired data in column vectors of equal length >5');
else %if
    Kstartable=[ 6  1; %from Appendix 2 of https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2545906/
        7  3;
        8  4;
        9  6;
        10  9;
        11 11;
        12 14;
        13 18;
        14 22;
        15 26;
        16 30;
        17 35;
        18 41;
        19 47;
        20 53];
    if N < 6
        Kstar = 1;
    elseif N<21
        Kstar=Kstartable(find(Kstartable(:,1)==N),2);
    else
        Kstar= ceil(N*(N+1)/4-(1.96*sqrt(N*(N+1)*(2*N+1)/24)) );
    end %if
    %first report all data, median, 25%ile, 75%ile, and lower and upper 95% conf intervals and p for each data set alone
    %     dat1
    %     [quantile(dat1,[0.5 0.05 0.25 0.75 0.95]) signrank(dat1)]
    %     dat2
    %     [quantile(dat2,[0.5 0.05 0.25 0.75 0.95]) signrank(dat2)]
    
    %now compute the change from dat1 to dat2 (these are paired data, should be no missing data)
    deldat=dat2-dat1; %could choose the sign to be the other way; here I'm saying dat2 exceeds dat1 if chagne is positive
    deldat=deldat(~isnan(deldat));
    tmp=triu(repmat(deldat,1,N)+repmat(deldat',N,1))/2;
    tmp=tmp./triu(ones(length(deldat)));%set the lower triangle of dattmp to NaNs
    tmp2=sort(reshape(tmp(~isnan(tmp)),[],1));
    output = [quantile(deldat,[0.5 0.25 0.75 0.05 0.95]) tmp2(Kstar) tmp2(end-Kstar) signrank(dat1,dat2) median(tmp2)];
    %     disp('[N   N*(N+1)/2   Kstar    mediandiffdat1todat2  diff95%CIlower  diff95%CIupper p=signrank(dat1,dat2)]');
    %     disp(output);
end
end %function

function output = MedianIQRCIpForArray (dat1)
% outputs Median, 25th percentile, 75th percentile, lower end of 95% CI, upper end of 95% CI, and p using Wilcoxon Sign Rank test
if sum(~isnan(dat1))
    output = [quantile(dat1,[0.5 0.25 0.75 0.05 0.95]) signrank(dat1)];
else
    output = [nan nan nan nan nan nan];
end
end %function

function output = MedianIQRCIpForUnpairedData (dat1,dat2)
% outputs Median, 25th percentile, 75th percentile, lower end of 95% CI, upper end of 95% CI, and p using Wilcoxon Sign Rank test
% and approach in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2545906/
% and http://www.real-statistics.com/non-parametric-tests/wilcoxon-signed-ranks-test/signed-ranks-median-confidence-interval/
% day1 and dat2 shoud be columen vectors of the same liength (because they are paired data)
dat1 = dat1(~isnan(dat1));
dat2 = dat2(~isnan(dat2));
N1=length(dat1);
N2=length(dat2);
if ~iscolumn(dat1) || ~iscolumn(dat2) || N1<5 || N2<5
    beep;
    disp('error in function MedianIQRCIpForUnpairedData - dat1 and dat2 should be in column vectors of length >4');
end %if
Ktable=[nan 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20;
    5 3 4 6 7 8 9 10 12 13 14 15 16 18 19 20 21;
    6 4 6 7 9 11 12 14 15 17 18 20 22 23 25 26 28;
    7 6 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35;
    8 7 9 11 14 16 18 20 23 25 27 30 32 35 37 39 42
    9 8 11 13 16 18 21 24 27 29 32 35 38 40 43 46 49;
    10 9 12 15 18 21 24 27 30 34 37 40 43 46 49 53 56;
    11 10 14 17 20 24 27 31 34 38 41 45 48 52 56 59 63;
    12 12 15 19 23 27 30 34 38 42 46 50 54 58 62 66 70;
    13 13 17 21 25 29 34 38 42 46 51 55 60 64 68 73 77;
    14 14 18 23 27 32 37 41 46 51 56 60 65 70 75 79 84;
    15 15 20 25 30 35 40 45 50 55 60 65 71 76 81 86 91;
    16 16 22 27 32 38 43 48 54 60 65 71 76 82 87 93 99;
    17 18 23 29 35 40 46 52 58 64 70 76 82 88 94 100 106;
    18 19 25 31 37 43 49 56 62 68 75 81 87 94 100 107 113;
    19 20 26 33 39 46 53 59 66 73 79 86 93 100 107 114 120;
    20 21 28 35 42 49 56 63 70 77 84 91 99 106 113 120 128];
if N1 <21 && N2 <21
    K=Ktable(Ktable(:,1)==N1,Ktable(1,:)==N2);
else
    K= ceil(((N1*N2)/2)-(1.96*sqrt((N1*N2*(N1+N2+1))/12)));
end %if
%first report all data, median, 25%ile, 75%ile, and lower and upper 95% conf intervals and p for each data set alone
%     dat1
%     [quantile(dat1,[0.5 0.05 0.25 0.75 0.95]) signrank(dat1)]
%     dat2
%     [quantile(dat2,[0.5 0.05 0.25 0.75 0.95]) signrank(dat2)]

%now compute the change from dat1 to dat2 (these are paired data, should be no missing data)
tmp1 = sort(dat1);
tmp2 = sort(dat2);
for i = 1:length(tmp1)
    for j = 1:length(tmp2)
        delmat(i,j) = tmp2(j)-tmp1(i);
    end
end
delmat = reshape(delmat(~isnan(delmat)),[],1);
tmpmat = sort(delmat);

if isempty(K)
    output = [quantile(delmat,[0.5 0.25 0.75 0.05 0.95]) ranksum(dat1,dat2)];
else
    output = [quantile(delmat,[0.5 0.25 0.75]) tmpmat(K) tmpmat(end-K) ranksum(dat1,dat2)];
end
%     disp('[N   N*(N+1)/2   Kstar    mediandiffdat1todat2  diff95%CIlower  diff95%CIupper p=signrank(dat1,dat2)]');
%     disp(output);
end %function