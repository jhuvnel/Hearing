clear;
close all;

%% load in file
%path1 = 'R:\Chow\MATLAB\Hearing\Data\';
path1 = '/Volumes/labdata/Chow/MATLAB/Hearing/Data/';
path2 = '20210914_qselHearingTests.mat';
load([path1,path2],'AudioTab')

%% parameters
patients = {'MVI001','MVI002','MVI003','MVI004','MVI005','MVI006','MVI007','MVI008','MVI009','MVI010'};
groups = [1 1 1 1 0 1 0 0 0 1];
visits = [0 3 6 9 10;
    0 3 6 9 10;
    0 3 6 9 10;
    0 3 7 9 10;
    0 4 7 9 10;
    0 4 7 9 10;
    0 3 7 9 10;
    0 3 7 9 10;
    0 3 7 9 10;
    0 3 5 9 10];
visitLabels = {'Pre-op','1 mo post-op','2 mo post-op','6 mo post-op','1 yr post-op'};
implantEar = [1 1 1 1 0 0 1 0 1 0]; % 1 = left, 0 = right
side = {'Right','Left'}; %index using implantEar + 1
scoreSide = {'_RT','_LFT'}; %index using implantEar + 1
conduction = {'BC','AC'};
freq = [125,250,500,1000,2000,4000,6000,8000]; % index for array %6/14/20 removed 3000
preOpArray = zeros(length(patients),length(conduction)*length(freq));
mo6ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo6Array = zeros(length(patients),length(conduction)*length(freq));
mo1ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo1Array = zeros(length(patients),length(conduction)*length(freq));
mo2ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo2Array = zeros(length(patients),length(conduction)*length(freq));
yr1ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
yr1Array = zeros(length(patients),length(conduction)*length(freq));
fontSize = 14;

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
                            preOpArray(i,find(freq==x(l))*2+(k-2)) = y(1,l); % bone, then air, alternating
                        case 4
                            mo6ArrayfromPreOp(i,find(freq==x(l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(l))*2+(k-2));
                            mo6Array(i,find(freq==x(l))*2+(k-2)) = y(1,l);
                        case 2
                            mo1ArrayfromPreOp(i,find(freq==x(l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(l))*2+(k-2));
                            mo1Array(i,find(freq==x(l))*2+(k-2)) = y(1,l);
                        case 3
                            mo2ArrayfromPreOp(i,find(freq==x(l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(l))*2+(k-2));
                            mo2Array(i,find(freq==x(l))*2+(k-2)) = y(1,l);
                        case 5
                            %if i < 7
                                yr1ArrayfromPreOp(i,find(freq==x(l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(l))*2+(k-2));
                                yr1Array(i,find(freq==x(l))*2+(k-2)) = y(1,l);
                            %end
                    end
                end
            end
        end
    end
end

spacev = 0.01;
spaceh = 0.01;
marginL = 0.05;
margin = 0.03;

for i = 1:2 %AC/BC
    for j = 1:2 %Hear/Nohear
        figure; %air/bone change from preop
        subaxis(3,1,3,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginLeft',marginL);
        hold on;
        plotBPfromPreOp(mo6ArrayfromPreOp,groups,j-1,i)
        ylabel('6 Mo Change from Pre-Op (dB HL)','FontSize',fontSize)
        
        %raw
        subaxis(3,1,1,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginLeft',marginL);
        hold on;
        plotBP(preOpArray,groups,j-1,i);
        ylabel('Pre-Op Threshold (dB HL)','FontSize',fontSize);
        
        subaxis(3,1,2,'SpacingVert',spacev,'SpacingHoriz',spaceh,'Margin',margin,'MarginLeft',marginL);
        hold on;
        plotBP(mo6Array,groups,j-1,i)
        ylabel('6 Mo Threshold (dB HL)','FontSize',fontSize);
    end
end

% figure; % raw top, change from pre op bottom, 1 mo left, 2 mo right
% subplot(2,3,1);
% hold on;
% plotBP(mo1Array,groups)
% title('1 mo Post-Op','FontSize',fontSize)
% ylabel('Threshold (dB HL)','FontSize',fontSize);
% 
% subplot(2,3,2);
% hold on;
% plotBP(mo2Array,groups)
% title('2 mo Post-Op','FontSize',fontSize)
% 
% subplot(2,3,3);
% hold on;
% plotBP(yr1Array,groups)
% title('1 yr Post-Op','FontSize',fontSize)
% 
% subplot(2,3,4);
% hold on;
% plotBPfromPreOp(mo1ArrayfromPreOp,groups)
% ylabel('Change from Pre-Op Threshold (dB HL)','FontSize',fontSize);
% 
% subplot(2,3,5);
% hold on;
% plotBPfromPreOp(mo2ArrayfromPreOp,groups)
% 
% subplot(2,3,6);
% hold on;
% plotBPfromPreOp(yr1ArrayfromPreOp,groups)



%% Stats and Tabulation
preOpOutput = zeros(length(preOpArray(1,:)),6);
mo6Output = zeros(length(mo6Array(1,:)),6);
mo1Output = zeros(length(mo1Array(1,:)),6);
mo2Output = zeros(length(mo2Array(1,:)),6);
for i = 1:length(preOpArray(1,:))
    preOpOutput(i,:) = MedianIQRCIpForArray(preOpArray(:,i));
    mo6Output(i,:) = MedianIQRCIpForArray(mo6Array(:,i));
    mo1Output(i,:) = MedianIQRCIpForArray(mo1Array(:,i));
    mo2Output(i,:) = MedianIQRCIpForArray(mo2Array(:,i));
end

% Paired Data - compare to pre-op & compare AC to BC
mo6PairedOutput = zeros(length(mo6Array(1,:)),6);
mo1PairedOutput = zeros(length(mo1Array(1,:)),6);
mo2PairedOutput = zeros(length(mo2Array(1,:)),6);
preOpPairedOutputACvBC = zeros(length(preOpArray(1,:))/2,6);
mo6PairedOutputACvBC = zeros(length(mo6Array(1,:))/2,6);
mo1PairedOutputACvBC = zeros(length(mo1Array(1,:))/2,6);
mo2PairedOutputACvBC = zeros(length(mo2Array(1,:))/2,6);
for i = 1:length(preOpArray(1,:))
    mo6PairedOutput(i,:) = MedianIQRCIpForPairedData(preOpArray(:,i),mo6Array(:,i));
    mo1PairedOutput(i,:) = MedianIQRCIpForPairedData(preOpArray(:,i),mo1Array(:,i));
    mo2PairedOutput(i,:) = MedianIQRCIpForPairedData(preOpArray(:,i),mo2Array(:,i));
    if mod(i,2) %all odd numbers
        preOpPairedOutputACvBC((i+1)/2,:) = MedianIQRCIpForPairedData(preOpArray(:,i),preOpArray(:,i+1));
        mo6PairedOutputACvBC((i+1)/2,:) = MedianIQRCIpForPairedData(mo6Array(:,i),mo6Array(:,i+1));
        mo1PairedOutputACvBC((i+1)/2,:) = MedianIQRCIpForPairedData(mo1Array(:,i),mo1Array(:,i+1));
        mo2PairedOutputACvBC((i+1)/2,:) = MedianIQRCIpForPairedData(mo2Array(:,i),mo2Array(:,i+1));
    end
end



%% function for plotting audiograms
function [x,y] = getFreqArray(patient,visit,implantedEar,conduction,dataTbl) % get audiogram @ all frequencies
patientRow = ismember(dataTbl.Subject,patient);
visitRow = dataTbl.VisitNum==visit;
earRow = ismember(dataTbl.Side,implantedEar);
conductRow = ismember(dataTbl.Type,conduction);
tempTbl = dataTbl(patientRow & visitRow & earRow & conductRow,:);

freq = [125,250,500,1000,2000,4000,6000,8000];

if ~isempty(tempTbl)
    resp = tempTbl{:,6:2:22};
    resp(6) = [];
    
%     for i = 1 % first response only
%         %Find points that are at the end of the audiometer
%         out_bound = isnan(resp(i,:));
%         %Takes out erroneous no response values
%         for j = 2:length(freq)-1
%             out_bound(j) = out_bound(j)&&(sum(out_bound(1:j-1))==length(out_bound(1:j-1))||sum(out_bound(j+1:end))==length(out_bound(j+1:end)));
%         end
%         if ismember(tempTbl.Type(i),'AC')
%             new_resp = [NaN,100,105,110,120,105,105,100,95]; % the air thresholds
%         else
%             new_resp = [NaN,50,60,70,70,70,60,NaN,NaN]; %the bone thresholds
%             %Bone conduction doesn't happen at 125, 6k or 8k Hz
%             out_bound([1,8,9]) = 0;
%         end
%         if any(out_bound)
%             %Make the response equal to the maximum threshold measured
%             %by the audiometer
%             new_resp(~out_bound) = resp(i,~out_bound);
%             x = freq;
%             y = new_resp;
%         else
%             x = freq;
%             y = resp;
%         end
%         
%     end
    x = freq;
    y = resp;
else
    x = [nan nan nan nan nan nan nan nan nan];
    y = [nan nan nan nan nan nan nan nan nan];
end
end



function [] = plotBPfromPreOp(array,groups,groupNum,Con) % plot audiogram boxplot summaries from preop
boxWidth = 0.1;
freq = [125,250,500,1000,2000,4000,6000,8000];
shapes = {'A','B','C','D','E','F','G','H','I'};
xpos = log(freq);
freqlab = strrep(split(num2str(freq)),'000','k');
xshift = 0.06;
markshift = 0.2;
markSize = 8;
%colorArray = repmat([0 0 0; 0.2 0.2 0.2],8,1);
if Con == 1 %AC
    colorArray = [0.2 0.2 0.2];
    array = array(:,2:2:end);
else %BC
    colorArray = [0 0 0];
    array = array(:,1:2:end);
end
linew = 1.5;

medianArray = median(array(groups==groupNum,:),1,'omitnan');

bp = boxplot(array(groups==groupNum,:),'Colors',colorArray,'Widths',boxWidth,'Positions',xpos,'Symbol','','Whisker',3);
set(bp,'LineWidth',linew,'LineStyle','-');

plot(xpos,medianArray(1:end),'k-','LineWidth',linew);

for i = 1:length(array(:,1))
    for j = 1:length(array(1,:))
        if groups(i) == groupNum
            text(xpos(j)+markshift,array(i,j),shapes{i},'Color','k','HorizontalAlignment','center');
        end
    end
end


ax = gca;
set(ax,'YDir','reverse','XAxisLocation','bottom')
set(ax,'XTick',xpos,'XTickLabel',freqlab)
set(ax,'XGrid','on','XMinorGrid','off','YGrid','on')
set(ax,'YTick',-10:10:120,'YLim',[-15, 115])
ylab = string(ax.YAxis.TickLabels);
set(ax,'XLim',[4.6 9.4]);
% for i = 1:2:length(ylab)
%     ylab(i) = '';
% end
set(ax,'YTickLabel',ylab);

rl = refline(0,0);
set(rl,'LineWidth',1,'LineStyle',':','Color','k');
set(gca,'children',flipud(get(gca,'children')))

end

function [] = plotBP(array,groups,groupNum,Con) % plot audiogram boxplot summaries
boxWidth = 0.1;
freq = [125,250,500,1000,2000,4000,6000,8000];
shapes = {'A','B','C','D','E','F','G','H','I'};
xpos = log(freq);
freqlab = strrep(split(num2str(freq)),'000','k');
xshift = 0.06;
markshift = 0.2;
markSize = 8;
%colorArray = repmat([0 0 0; 0.2 0.2 0.2],8,1);
if Con == 1 %AC
    colorArray = [0.2 0.2 0.2];
    array = array(:,2:2:end);
else %BC
    colorArray = [0 0 0];
    array = array(:,1:2:end);
end
linew = 1.5;

medianArray = median(array(groups==groupNum,:),1,'omitnan');


bp = boxplot(array(groups==groupNum,:),'Colors',colorArray,'Widths',boxWidth,'Positions',xpos,'Symbol','','Whisker',3);
set(bp,'LineWidth',linew,'LineStyle','-');

plot(xpos,medianArray(1:end),'k-','LineWidth',linew);

for i = 1:length(array(:,1))
    for j = 1:length(array(1,:))
        if groups(i) == groupNum
            text(xpos(j)+markshift,array(i,j),shapes{i},'Color','k','HorizontalAlignment','center');
        end
    end
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

end




function output = MedianIQRCIpForPairedData (dat1,dat2)
% outputs Median, 25th percentile, 75th percentile, lower end of 95% CI, upper end of 95% CI, and p using Wilcoxon Sign Rank test
% and approach in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2545906/
% and http://www.real-statistics.com/non-parametric-tests/wilcoxon-signed-ranks-test/signed-ranks-median-confidence-interval/
% day1 and dat2 shoud be columen vectors of the same liength (because they are paired data)

N=sum(~isnan(dat1) & ~isnan(dat2));
if ~iscolumn(dat1) || ~iscolumn(dat2) || N < 4 %|| N<6 || sum(~isnan(dat1)) < 6 || sum(~isnan(dat2)) < 6
    beep;
    output = [nan nan nan nan nan nan];
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
    output = [quantile(deldat,[0.5 0.25 0.75]) tmp2(Kstar) tmp2(end-Kstar) signrank(dat1,dat2)];
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