close all
clc
clear
clear all
global rowN rowNum
%% Given Contants
Cd=
TrNeed=
V=28.5;
rho=1.18;
nu=15.2E-6;   
%% Calculate Maximum Re/RPM for Scaling Smaller Props
dMax=.6069;
nMax=2800/60;
ReMax=nMax*0.6096^2/nu;
ds=[1:1:24]./39.37;
nMaxVec=ReMax*nu./(ds.^2);
%% Uncomment for first run
% Diam=[];
% currN=[1000:1000:22000]./60;
% [pNames pSave]=importProps('Props.txt');
% % Allocate matrix sizes
% numP=length(pNames);
% numRPM=600;
% % Downloads all prop data from APC
% for c0=1: numP
%     url = 'https://www.apcprop.com/files/'+pNames(c0);
%     filename = pSave(c0)+'.txt';
%     outfilename = websave(filename,url);
%     c1=char(pSave(c0));
%     I=find(c1=='x');
%     Diam=[Diam str2double(c1(1:I-1))];
%     if Diam(c0)/39.37>dMax
%         c0=numP;
%     end
% end
%% Uncomment for first run
%Reads all downloaded data and saves performance parameters in matrix
% Adv=zeros(numRPM,numP);
% Ct=zeros(numRPM,numP);
% Cp=zeros(numRPM,numP);
% temp=zeros(numRPM,numP);
% for c0=1: numP
%     disp("Propeller: " +c0)
%     [temp(1:rowNum,c0), Adv(1:rowNum,c0), temp(1:rowNum,c0), Ct(1:rowNum,c0), Cp(1:rowNum,c0), temp(1:rowNum,c0), temp(1:rowNum,c0)]=importAPCCr(pSave(c0)+'.txt');
% end
% save('Perf.mat','Adv','Cp','Ct','Diam','pNames','pSave','currN');
%% Finds Propeller with max thrust to power meeting all requirements
load('Perf.mat');
PwrCrVec=[]; 
for c0=1: length(pNames)
    rpm=1;
    for c=1: length(Ct)
        if rpm~=22
            rpm=fix(c/30)+1;
        end
        currD=round(Diam(c0)*39.37);
        ReCurr=currN(rpm)*Diam(c0)^2/nu;
        dScale=sqrt(ReCurr*nu/nMax);
        J=V/(currN(rpm)*dScale);
        if currN(rpm)<nMaxVec(round(currD)) && dScale<dMax
            if Adv(c,c0)==J | (Adv(c,c0)<=1.02*J && Adv(c,c0)>=.98*J)
                ThrCr=Ct(c,c0)*rho*currN(rpm)^2*Diam(c0)^4;
                if TrNeed<ThrCr
                    PwrCr=Cp(c,c0)*rho*currN(rpm)^3*Diam(c0)^5;
                    PwrCrVec=[PwrCrVec PwrCr];
                    if PwrCrVec(end)==min(PwrCrVec)
                        disp("Horiz Propeller Name: "+pNames(c0))
                        disp("All Values Are for UnScaled Prop, Scaled Prop RPM=2800")
                        disp("Thrust Coef: "+Ct(c,c0))
                        disp("RPM: "+currN(rpm)*60)
                        disp("Power Coef: "+Cp(c,c0))
                        disp("Thrust: "+ThrCr+" N");
                        disp("Power: "+PwrCr+" Watts");
                        disp("Thrust to Power: "+ThrCr/PwrCr);
                        disp("Scaled Diameter Needed: "+dScale);
                        disp("Operating at Advance Ratio: "+Adv(c,c0))
                        disp(" ");
                    end
                end
            end
        end
    end
end