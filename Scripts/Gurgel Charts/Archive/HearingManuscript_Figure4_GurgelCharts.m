clear;
close all;

%% load in file
%path1 = 'R:\Chow\MATLAB\Hearing\Data\';
path1 = '/Volumes/labdata/Chow/MATLAB/Hearing/Data/';
path2 = '20220328_qselHearingTests.mat';
load([path1,path2],'AudioTab')

%% parameters
patients = {'MVI001R019','MVI002R004','MVI003R140','MVI004R201','MVI005R107','MVI006R296','MVI007R765','MVI008R021','MVI009R908','MVI010R141'};
visits = [0 10 14;
    0 10 14;
    0 10 14;
    0 10 13;
    0 10 12;
    0 10 12;
    0 9 12; % should I do 11 or 9?
    0 10 11;
    0 10 10;
    0 9 9];
visitLabels = {'Pre-op','1 yr post-op','Most Recent'};
implantEar = [1 1 1 1 0 0 1 0 1 0]; % 1 = left, 0 = right
side = {'Right','Left'}; %index using implantEar + 1
scoreSide = {'_RT','_LFT'}; %index using implantEar + 1
conduction = {'AC'}; % need air conduction for pure-tone average
freq = [125,250,500,1000,2000,3000,4000,6000,8000]; % index for array
preOpArray = zeros(length(patients),length(conduction)*length(freq));
yr1ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mostRecArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
yr1Array = zeros(length(patients),length(conduction)*length(freq));
mostRecArray = zeros(length(patients),length(conduction)*length(freq));
cncw = zeros(length(patients),length(visits(1,:)));
fontSize = 16;
ptaIdxvS006 = [3,4,5,7];

%% extract data
% row of array is patient, columns are AC (1) x each freq (9) for 0.5 yrs and 1 yrs
for i = 1:length(patients)
    for j = 1:length(visits(1,:))
        for k = 1:length(conduction) % just air
            [x,y] = getFreqArray(patients{i},visits(i,j),side{implantEar(i)+1},conduction(k),AudioTab);
            if ~isempty(x)
                for l = 1:length(x(1,:))
                    switch j
                        case 1
                            preOpArray(i,find(freq==x(1,l))) = y(1,l); 
                        case 2
                            yr1ArrayfromPreOp(i,find(freq==x(1,l))) = y(1,l)-preOpArray(i,find(freq==x(1,l)));
                            yr1Array(i,find(freq==x(1,l))) = y(1,l);
                        case 3
                            mostRecArrayfromPreOp(i,find(freq==x(1,l))) = y(1,l)-preOpArray(i,find(freq==x(1,l)));
                            mostRecArray(i,find(freq==x(1,l))) = y(1,l);
                    end
                end
            end
            cncw(i,j) = getWordScoreArray(patients{i},visits(i,j),scoreSide{implantEar(i)+1},AudioTab);
        end
    end
end

% Calculate Pure Tones
% First, in sV006 report style (.5, 1, 2, 4 kHz)
puretone(:,1) = mean(preOpArray(:,ptaIdxvS006),2,'omitnan');
puretone(:,2) = mean(yr1Array(:,ptaIdxvS006),2,'omitnan');
puretone(:,3) = mean(mostRecArray(:,ptaIdxvS006),2,'omitnan');
puretone(puretone == 0) = nan;

cncwfromPreOp = cncw-cncw(:,1);
puretonefromPreOp = puretone-puretone(:,1);

gurgelRawPreOp = makeGurgelRaw(cncw(:,1),puretone(:,1));
gurgelRaw1Yr = makeGurgelRaw(cncw(:,2),puretone(:,2));
gurgelRawMostRec = makeGurgelRaw(cncw(:,3),puretone(:,3));

gurgelChange1Yr = makeGurgelChange(cncwfromPreOp(:,2),puretonefromPreOp(:,2));
gurgelChangeMostRec = makeGurgelChange(cncwfromPreOp(:,3),puretonefromPreOp(:,3));



%% function for plotting audiograms
function [x,y] = getFreqArray(patient,visit,implantedEar,conduction,dataTbl)
patientRow = ismember(dataTbl.Subject,patient);
visitRow = dataTbl.VisitNum==visit;
earRow = ismember(dataTbl.Side,implantedEar);
conductRow = ismember(dataTbl.Type,conduction);
tempTbl = dataTbl(patientRow & visitRow & earRow & conductRow,:);

freq = [125,250,500,1000,2000,3000,4000,6000,8000];

if ~isempty(tempTbl)
    resp = tempTbl{:,6:2:22};
    
    for i = 1 % first response only
        %Find points that are at the end of the audiometer
        out_bound = resp(i,:) > 1000;
        if any(out_bound)
            %Make the response equal to the maximum threshold measured
            %by the audiometer
            new_resp = resp(i,:);
            new_resp(out_bound) = new_resp(out_bound)./1000;
            x = freq;
            y = new_resp;
        else
            x = freq;
            y = resp(i,:);
        end
        
    end
else
    x = [nan nan nan nan nan nan nan nan nan];
    y = [nan nan nan nan nan nan nan nan nan];
end
end

function [CNCWPrct,AZBio, WRdbHL] = getWordScoreArray(patient,visit,implantedEar,dataTbl)
patientRow = ismember(dataTbl.Subject,patient);
visitRow = dataTbl.VisitNum==visit;
tempTbl = dataTbl(patientRow & visitRow,:);
wrdprcntLab = strcat('tempTbl.WRPCNT',implantedEar,'(1)');
azbioLab = strcat('tempTbl.Azbio_N',implantedEar(1:2),'(1)');
wrdbhlLab = strcat('tempTbl.WRDBHL',implantedEar,'(1)');

if ~isempty(tempTbl)
    for i = 1
        CNCWPrct = eval(wrdprcntLab);
        AZBio = eval(azbioLab);
        WRdbHL = eval(wrdbhlLab);
    end
else
    CNCWPrct = nan;
    AZBio = nan;
    WRdbHL = nan;
end
end

function [tab] = makeGurgelRaw(cncw,wrpt)
binCatTon = [11 21 31 41 51 61 71 81 91 101];
binCatWR = [89 79 69 59 49 39 29 19 9 -1];

tab = zeros(length(binCatTon),length(binCatWR));

for i = 1:length(cncw)
    if ~isnan(cncw(i)) && ~isnan(wrpt(i))
        for j = 1:length(binCatTon)
            if wrpt(i) < binCatTon(j)
                break;
            end
        end
        for k = 1:length(binCatWR)
            if cncw(i) > binCatWR(k)
                break;
            end
        end
        tab(j,k) = tab(j,k) + 1;
    end
end
end

function [tab] = makeGurgelChange(cncw,wrpt)
binCatTon = [-50 -40 -30 -20 -10 0 1 11 21 31 41 51 100];
binCatWR = [50 40 30 20 10 0 -1 -11 -21 -31 -41 -51 -100];

tab = zeros(length(binCatTon),length(binCatWR));

for i = 1:length(cncw)
    if ~isnan(cncw(i)) && ~isnan(wrpt(i))
        for j = 1:length(binCatTon)
            if wrpt(i) < binCatTon(j)
                break;
            end
        end
        for k = 1:length(binCatWR)
            if cncw(i) > binCatWR(k)
                break;
            end
        end
        tab(j,k) = tab(j,k) + 1;
    end
end
end