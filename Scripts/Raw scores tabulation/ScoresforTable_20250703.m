% Script for obtaining scores for tabulation starting from MVIFIHBox Audiometry
% Data. Note that you will need to have the Functions subfolder within 
% mvi\DATA SUMMARY\IN PROGRESS\Hearing\Functions added to your MATLAB path
% in order to run this script successfully. 
% This script is made to output AzBio, PTA, and WRS scores for the selected
% subset of patients and visits. Could be modified to include other
% outcomes. Please find output variables in tableVariables structure.

% Last updated on 2025-07-03 by CFB (celia@jhmi.edu)

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

% Each patient has an assigned letter for plots
letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

% Implanted side
implantEar = [1 1 1 1 0 0 1 0 1 0 1 0 1 1 1 0 0 0 1 1]; % 1 = left, 0 = right

% Visits we want to display, if you want to change this then simply set
% select_visits as an empty input
unique_visits = unique(AudioTab.VisitNum(~isnan(AudioTab.VisitNum)));
select_visits = {0, 3, 9, 10, 'most recent'};

% Next, pick visits that we always want to be replaced (normally because of
% missing data, e.g., due to COVID-19 pandemic)
substitutions = [8 9 7; % MVI008, replace visit 9 with visit 7
    7 10 11]; % MVI007, replace visit 10 with visit 11

% Now we can generate table of visits
visits = SelectSubjectVisits(AudioTab, substitutions, select_visits);
visits = table2array(visits);

side = {'Right','Left'}; %index using implantEar + 1
scoreSide = {'_RT','_LFT'}; %index using implantEar + 1
conduction = {'BC','AC'};

% Initialize arrays
freq = [125,250,500,1000,2000,3000,4000,6000,8000]; % index for array
preOpArray = zeros(length(patients),length(conduction)*length(freq));
mo6ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
yr1ArrayfromPreOp = zeros(length(patients),length(conduction)*length(freq));
mo6Array = zeros(length(patients),length(conduction)*length(freq));
yr1Array = zeros(length(patients),length(conduction)*length(freq));
cncw = zeros(length(patients),length(visits(1,:)));
azbin = zeros(length(patients),length(visits(1,:)));
azbiq = zeros(length(patients),length(visits(1,:)));
azbbn = zeros(length(patients),length(visits(1,:)));
azbbq = zeros(length(patients),length(visits(1,:)));

azbioquiet = nan(length(patients),length(visits(1,:)));
azbionoise = nan(length(patients),length(visits(1,:)));
ptaac = nan(length(patients),3*length(visits(1,:)));
ptabc = nan(length(patients),3*length(visits(1,:)));
ptaacmean = nan(length(patients),length(visits(1,:)));
ptabcmean = nan(length(patients),length(visits(1,:)));
wrs = nan(length(patients),length(visits(1,:)));

ptaIdx = [3,4,5,7];
fontSize = 14;
%% Extract data
% row of array is patient, columns are AC/BC (2) x each freq (9) for 0.5 yrs and 1 yrs
for i = 1:length(patients)
    for j = 1:length(visits(1,:))
        if ~isnan(visits(i,j))
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
                            case 2
                                mo6ArrayfromPreOp(i,find(freq==x(1,l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(1,l))*2+(k-2));
                                mo6Array(i,find(freq==x(1,l))*2+(k-2)) = y(1,l);
                            case 3
                                yr1ArrayfromPreOp(i,find(freq==x(1,l))*2+(k-2)) = y(1,l)-preOpArray(i,find(freq==x(1,l))*2+(k-2));
                                yr1Array(i,find(freq==x(1,l))*2+(k-2)) = y(1,l);
                        end
                    end
                end
                [cncw(i,j),azbin(i,j),azbiq(i,j),azbbn(i,j),azbbq(i,j)] = getWordScoreArray(patients{i},visits(i,j),scoreSide{implantEar(i)+1},AudioTab);
            end
                [ptaactemp, ptabctemp,wrstemp,azbioquiettemp,azbionoisetemp] = getTableScore(patients{i},visits(i,j),implantEar(i),AudioTab);
                wrs(i,j) = wrstemp;
                azbioquiet(i,j) = azbioquiettemp;
                azbionoise(i,j) = azbionoisetemp;
                ptaacmean(i,j) = ptaactemp;
                ptabcmean(i,j) = ptabctemp;
        else
            wrs(i,j) = nan;
            azbioquiet(i,j) = nan;
            azbionoise(i,j) = nan;
            ptaacmean(i,j) = nan;
            ptabcmean(i,j) = nan;
        end
    end
end
cncwfromPreOp = cncw-cncw(:,1);
azbinfromPreOp = azbin-azbin(:,1);
azbiqfromPreOp = azbiq-azbiq(:,1);
azbbnfromPreOp = azbbn-azbbn(:,1);
azbbqfromPreOp = azbbq-azbbq(:,1);

% Calculate Pure Tones
% First, in sV006 report style (.5, 1, 2, 4 kHz)
puretone(:,1) = mean(preOpArray(:,ptaIdx*2),2,'omitnan');
puretone(:,2) = mean(mo6Array(:,ptaIdx*2),2,'omitnan');
puretone(:,3) = mean(yr1Array(:,ptaIdx*2),2,'omitnan');
puretone(puretone == 0) = nan;
puretoneACfromPreOp = puretone-puretone(:,1);
puretoneBC(:,1) = mean(preOpArray(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(:,2) = mean(mo6Array(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(:,3) = mean(yr1Array(:,(ptaIdx*2)-1),2,'omitnan');
puretoneBC(puretoneBC == 0) = nan;
puretoneBCfromPreOp = puretoneBC-puretoneBC(:,1);

% Finally, save output arrays to a single structure
tableVariables.AzBioQuiet = azbioquiet;
tableVariables.AzBioNoise = azbionoise;
tableVariables.PTAAirMean = ptaacmean;
tableVariables.PTABoneMean = ptabcmean;
tableVariables.WRS = wrs;
%% Functions for extracting data for tables -- left unmodified since MRC
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

function [ptaacmean, ptabcmean,wrs,azbioquiet,azbionoise] = getTableScore(patient,visit,implantedEar,dataTbl) % get word scores
patientRow = ismember(dataTbl.Subject,patient);
visitRow = dataTbl.VisitNum==visit;
tempTbl = dataTbl(patientRow & visitRow,:);
if height(tempTbl) >4
    tempTbl = tempTbl(tempTbl.AudiogramDate==tempTbl.AudiogramDate(1),:); % in case there are multiple days for one visit (i.e., activation)
end
if implantedEar
    azbioquiet = mode(tempTbl.Azbio_Q_L); 
    azbionoise = mode(tempTbl.Azbio_N_L); 
    wrs = mode(tempTbl.WRPCNT_LFT);
    ptaacmean = table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'AC'),24));
    ptabcmean = table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'BC'),24));
    ptaac = [min(table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'AC'),[10 12 14 18]))),...
        nanmedian(table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'AC'),[10 12 14 18]))), ...
        max(table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'AC'),[10 12 14 18])))];
    ptabc = [min(table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'BC'),[10 12 14 18]))),...
        nanmedian(table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'BC'),[10 12 14 18]))), ...
        max(table2array(tempTbl(strcmp(tempTbl.Side,'Left') & strcmp(tempTbl.Type,'BC'),[10 12 14 18])))];
elseif ~implantedEar
    azbioquiet = mode(tempTbl.Azbio_Q_R); 
    azbionoise = mode(tempTbl.Azbio_N_R); 
    wrs = mode(tempTbl.WRPCNT_RT);
    ptaacmean = table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'AC'),24));
    ptabcmean = table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'BC'),24));
    ptaac = [min(table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'AC'),[10 12 14 18]))),...
        nanmedian(table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'AC'),[10 12 14 18]))), ...
        max(table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'AC'),[10 12 14 18])))];
    ptabc = [min(table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'BC'),[10 12 14 18]))),...
        nanmedian(table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'BC'),[10 12 14 18]))), ...
        max(table2array(tempTbl(strcmp(tempTbl.Side,'Right') & strcmp(tempTbl.Type,'BC'),[10 12 14 18])))];
end
end