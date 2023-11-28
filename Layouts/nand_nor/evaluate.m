clear variables
close all

%% Paths definition
myDataPath = '~';
BBcharPath = fullfile(myDataPath,'BBchar');
BBcharCodePath = fullfile(BBcharPath,'Code');
thisPath = pwd;
libraryPath = fullfile(BBcharPath, 'Lib');

%% lib values
%           DrAH   DrAL   DrBH   DrBL   DrCH   DrCL
% input = [-1 +1; -1 +1; -1 +1; -1 +1; -1 +1; -1 +1]; %000
% input = [-1 +1; -1 +1; -1 +1; -1 +1; +1 -1; +1 -1]; %001 
% input = [-1 +1; -1 +1; +1 -1; +1 -1; -1 +1; -1 +1]; %010
% input = [-1 +1; -1 +1; +1 -1; +1 -1; +1 -1; +1 -1]; %011 
% input = [+1 -1; +1 -1; -1 +1; -1 +1; -1 +1; -1 +1]; %100 
% input = [+1 -1; +1 -1; -1 +1; -1 +1; +1 -1; +1 -1]; %101 
input = [+1 -1; +1 -1; +1 -1; +1 -1; -1 +1; -1 +1]; %110 
% input = [+1 -1; +1 -1; +1 -1; +1 -1; +1 -1; +1 -1]; %111 

tic            
cd(BBcharCodePath)
VoutMV = InOut_eval(libraryPath,'MVlongdx',input);
Vout_Lib = InOut_eval(libraryPath,'inv',VoutMV);

Vout_scerpa = InOut_eval(libraryPath,'nand_nor',input);

error_avg = mean(abs(Vout_Lib-Vout_scerpa),"all");
error_min = min(min(abs(Vout_Lib-Vout_scerpa)));
error_max = max(max(abs(Vout_Lib-Vout_scerpa)));

time = toc

fprintf("\nMean error: %e\nMin error: %e\nMax error: %e\n\n",error_avg,error_min,error_max);

cd(thisPath)

avg = [4.8625e-6 5.2075e-6 4.38975e-5 8.5875e-6 4.6120e-5 5.9655e-5 5.9565e-5 5.9565e-5];
min = [3.5e-6 1.8e-6 8.9e-6 1.05e-6 9.5e-6 1.52e-5 1.54e-5 1.54e-5];
max = [6.2e-6 1.11e-5 6.069e-5 2.66e-5 6.408e-5 8.722e-5 8.706e-5 8.706e-5];
plot(1:8,avg,'k',1:8,min,':k',1:8,max,'-.k','LineWidth',1.5)

