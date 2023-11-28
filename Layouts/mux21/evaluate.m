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
zero = [-1 +1; -1 +1]; 
one = [+1 -1; +1 -1]; 
DrA = one;
DrB = zero; 
DrS = zero;
DrC0 = zero; 
DrC1 = one; 

tic            
cd(BBcharCodePath)
VoutL1 = InOut_eval(libraryPath,'Lwire_dxdw',DrA);
VoutInvDr = InOut_eval(libraryPath,'invDr',DrS);
VoutInvDr_neg = VoutInvDr(1:2,:);
VoutInvDr_dr = VoutInvDr(3:4,:);
VoutMV1 = InOut_eval(libraryPath,'MVlongdw',[VoutL1; VoutInvDr_neg; DrC0]);

VoutL2 = InOut_eval(libraryPath,'Lwire_dxup',DrB);
VoutMV2 = InOut_eval(libraryPath,'MVlongup',[DrC0; VoutInvDr_dr; VoutL2]);
Vout_Lib = InOut_eval(libraryPath,'MVlongdx',[VoutMV1; DrC1; VoutMV2]);

Vout_scerpa = InOut_eval(libraryPath,'mux21',[DrA; DrB; DrS; DrC0; DrC1]);

error_avg = mean(abs(Vout_Lib-Vout_scerpa),"all");
error_min = min(min(abs(Vout_Lib-Vout_scerpa)));
error_max = max(max(abs(Vout_Lib-Vout_scerpa)));

time = toc

fprintf("\nMean error: %e\nMin error: %e\nMax error: %e\n\n",error_avg,error_min,error_max);

cd(thisPath)

avg = [4.3475e-5 4.565e-5 1.201e-4 1.21025e-4 6.9425e-5 9.51e-5 4.53e-5 9.45e-5];
min = [1.4e-6 2.6e-5 2.75e-5 3e-6 1.7e-5 1.19e-5 1.17e-5 1.32e-5];
max = [1.497e-4 1.56e-4 2.207e-4 3.997e-4 1.13e-4 3.068e-4 7.61e-5 2.417e-4];
plot(1:8,avg,'k',1:8,min,':k',1:8,max,'-.k','LineWidth',1.5)

