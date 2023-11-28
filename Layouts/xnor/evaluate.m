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
VoutINV1 = InOut_eval(libraryPath,'inv',DrA);
VoutL1 = InOut_eval(libraryPath,'Lwire_dxdw_xnor',VoutINV1);
VoutInvDr = InOut_eval(libraryPath,'invDr',DrB);
VoutInvDr_neg = VoutInvDr(1:2,:);
VoutInvDr_dr = VoutInvDr(3:4,:);
VoutHwire1 = InOut_eval(libraryPath,'Hwire_xnor',VoutInvDr_neg);
VoutMV1 = InOut_eval(libraryPath,'MVlongdw',[VoutL1; VoutHwire1; DrC0]);

VoutHwire2 = InOut_eval(libraryPath,'Hwire_xnor',VoutInvDr_dr);
VoutHwire3 = InOut_eval(libraryPath,'Hwire_xnor',DrA);
VoutL2 = InOut_eval(libraryPath,'Lwire_dxup',VoutHwire3);
VoutMV2 = InOut_eval(libraryPath,'MVlongup',[DrC0; VoutHwire2; VoutL2]);
Vout_Lib = InOut_eval(libraryPath,'MVlongdx',[VoutMV1; DrC1; VoutMV2]);

Vout_scerpa = InOut_eval(libraryPath,'xnor',[DrA; DrB; DrC0; DrC1]);

error_avg = mean(abs(Vout_Lib-Vout_scerpa),"all");
error_min = min(min(abs(Vout_Lib-Vout_scerpa)));
error_max = max(max(abs(Vout_Lib-Vout_scerpa)));

time = toc

fprintf("\nMean error: %e\nMin error: %e\nMax error: %e\n\n",error_avg,error_min,error_max);

cd(thisPath)

avg = [6.6575e-05 4.2e-05 1.1555e-04 9.3625e-05];
min = [1.67e-05 1.8e-06 2.55e-05 1.27e-05];
max = [1.08e-04 1.469e-04 2.047e-04 2.389e-04];
plot(1:4,avg,'k',1:4,min,':k',1:4,max,'-.k','LineWidth',1.5)

