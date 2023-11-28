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
DrC0 = zero; 

tic            
cd(BBcharCodePath)
VoutT1 = InOut_eval(libraryPath,'T_dxdw',DrA);
VoutT1_dx = VoutT1(1:2,:);
VoutT1_dw = VoutT1(3:4,:);
VoutT2 = InOut_eval(libraryPath,'T_dxup',DrB);
VoutT2_up = VoutT2(1:2,:);
VoutT2_dx = VoutT2(3:4,:);

Voutnand1 =  InOut_eval(libraryPath,'nand_nor_big',[VoutT1_dw;DrC0;VoutT2_up]);

VoutH1 =  InOut_eval(libraryPath,'Hwire_xnor',VoutT1_dx);
VoutH2 =  InOut_eval(libraryPath,'Hwire_xnor',VoutH1);
VoutH3 =  InOut_eval(libraryPath,'Hwire_xnor',VoutH2);
VoutH4 =  InOut_eval(libraryPath,'Hwire_xnor',VoutT2_dx);
VoutH5 =  InOut_eval(libraryPath,'Hwire_xnor',VoutH4);
VoutH6 =  InOut_eval(libraryPath,'Hwire_xnor',VoutH5);

VoutT3 = InOut_eval(libraryPath,'T_updw',Voutnand1);
VoutT3_up = VoutT3(1:2,:);
VoutT3_dw = VoutT3(3:4,:);

Voutnand2 =  InOut_eval(libraryPath,'nand_nor_big',[DrC0;VoutH3;VoutT3_up]);
Voutnand3 =  InOut_eval(libraryPath,'nand_nor_big',[VoutT3_dw;VoutH6;DrC0]);

VoutL1 = InOut_eval(libraryPath,'Lwire_short_dxdw',Voutnand2);
VoutL2 = InOut_eval(libraryPath,'Lwire_short_dxup',Voutnand3);

Vout_Lib = InOut_eval(libraryPath,'nand_nor_big',[VoutL1; DrC0; VoutL2]);

Vout_scerpa = InOut_eval(libraryPath,'xor_2',[DrA; DrB; DrC0]);

error_avg = mean(abs(Vout_Lib-Vout_scerpa),"all");
error_min = min(min(abs(Vout_Lib-Vout_scerpa)));
error_max = max(max(abs(Vout_Lib-Vout_scerpa)));

time = toc

fprintf("\nMean error: %e\nMin error: %e\nMax error: %e\n\n",error_avg,error_min,error_max);

cd(thisPath)

avg = [2.202023e-2 1.35446e-2 1.357467e-2 2.193788e-2];
min = [6.2084e-3 4.0102e-3 3.8939e-3 6.0468e-3];
max = [5.63123e-2 2.65281e-2 2.61304e-2 5.63366e-2];
plot(1:4,avg,'k',1:4,min,':k',1:4,max,'-.k','LineWidth',1.5)

