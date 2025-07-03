% Script for plotting Gurgel Chart starting from MVIFIHBox Audiometry
% Data. Note that you will need to have the Functions subfolder within 
% mvi\DATA SUMMARY\IN PROGRESS\Hearing\Functions added to your MATLAB path
% in order to run this script successfully

% Last updated on 2025-07-02 by CFB (celia@jhmi.edu)

%% Load in file - spreadsheet downloaded from MVIFIHBox
close all; clear all; clc
[path2,path1] = uigetfile('*.xlsx','Select File With Audiometry Data.');
if(path1==0)
    error('No file selected. Try process again')
end
AudioTab = readtable([path1 path2]);

%% Update parameters as needed
% Patient IDs to include
patients = unique(AudioTab.Subject(contains(AudioTab.Subject,'MVI')));

% Next, pick visits that we always want to be replaced (normally because of
% missing data, e.g., due to COVID-19 pandemic)
substitutions = [7 10 9 % MVI007, replace visit 10 with visit 9
    8 9 10]; % MVI008, replace visit 9 with visit 10

% Now we can generate table of visits
visits = SelectSubjectVisits(AudioTab, substitutions, {0,10,'most recent'})
visits = table2array(visits);
visitLabels = {'Pre-op','1 yr post-op','Most Recent'};

implantEar = [1 1 1 1 0 0 1 0 1 0 1 0 1 1 1 0 0 0 1 1]; % 1 = left, 0 = right
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

%% Extract data
% row of array is patient, columns are AC (1) x each freq (9) for 0.5, 1
% yr, and most recent
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

% Output variables (either raw scores or change relative to preop)

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