clear variables
close all

%% Paths definition
myDataPath = '~';
BBcharPath = fullfile(myDataPath,'BBchar');
BBcharCodePath = fullfile(BBcharPath,'Code');
thisPath = pwd;
libraryPath = fullfile(BBcharPath, 'Lib');

%% lib values
%       H       L
DrA = [+1 -1; +1 -1]; 
DrB = [-1 +1; -1 +1]; 
DrC0 = [-1 +1; -1 +1]; 
DrC1 = [+1 -1; +1 -1]; 

tic            
cd(BBcharCodePath)
VoutL1 = InOut_eval(libraryPath,'Lwire_dxdw',DrA);
VoutINV1 = InOut_eval(libraryPath,'inv',DrB);
VoutMV1 = InOut_eval(libraryPath,'MVlongdw',[VoutL1; VoutINV1; DrC0]);
VoutL2 = InOut_eval(libraryPath,'Lwire_dxup',DrB);
VoutINV2 = InOut_eval(libraryPath,'inv',DrA);
VoutMV2 = InOut_eval(libraryPath,'MVlongup',[DrC0; VoutINV2; VoutL2]);
Vout_Lib = InOut_eval(libraryPath,'MVlongdx',[VoutMV1; DrC1; VoutMV2]);

Vout_scerpa = InOut_eval(libraryPath,'xor',[DrA; DrB; DrC0; DrC1]);

error_avg = mean(abs(Vout_Lib-Vout_scerpa),"all");
error_min = min(min(abs(Vout_Lib-Vout_scerpa)));
error_max = max(max(abs(Vout_Lib-Vout_scerpa)));

time = toc

fprintf("\nMean error: %e\nMin error: %e\nMax error: %e\n\n",error_avg,error_min,error_max);

cd(thisPath)

avg = [1.28825e-04 1.2055e-04 6.35e-05 4.52e-05];
min = [2.89e-05 4.1e-06 1.58e-05 8.0e-07];
max = [2.36e-04 3.861e-04 1.022e-04 1.586e-04];
plot(1:4,avg,'k',1:4,min,':k',1:4,max,'-.k','LineWidth',1.5)

