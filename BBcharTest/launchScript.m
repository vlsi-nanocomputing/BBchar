clear variables
close all

%% Paths definition
myDataPath = '/media/giuliana/DATA';
BBcharPath = fullfile(myDataPath,'BBchar');
thisPath = pwd;
scerpaPath = fullfile(myDataPath,'scerpa');
outputPath = fullfile(myDataPath,'PhD','tmp','testBBchar');
% driver_handling_path = fullfile(characterization_path, 'Driver_handling');
%library_path = fullfile(myDataPath,'BBchar', 'Lib');

%% Clock signal parameters

%definitions
clock_low = -2;
clock_high = +2;
clock_step = 2; %how many values for the 'p'?

%Step simulation implementation
pSwitch =  linspace(clock_low, clock_high, clock_step); % if step = 1 -> [-2 -1 0 1 2]
pHold =   linspace(clock_high, clock_high, clock_step); % if step = 1 -> [2 2 2 2 2]
pRelease =  linspace(clock_high, clock_low, clock_step); % if step = 1 -> [2 1 0 -1 -2]
pReset =   linspace(clock_low, clock_low, clock_step); % if step = 1 -> [-2 -2 -2 -2 -2]

%Cycle to simulate
pCycle = [pSwitch pHold pRelease];% pReset]; % if step = 1 -> [-2 -1 0 1 2 -> 2 2 2 2 2 -> 2 1 0 -1 -2 -> -2 -2 -2 -2 -2 ]

%% Driver parameters
driverPara.doubleMolDriver = 1;
driverPara.Ninputs = 1; %Number of physical input of the layout
driverPara.driverNames = [{'Dr1'}]; %list of the drivers name as they are in the .qll file
driverPara.driverModes = [{'sweep'}]; %list of the mode for each driver, same order as driverName
% Definition of drivers modes to use in debug mode 
%       '1'      -> driver value fixed to '1'-logic;
%       '0'      -> driver value fixed to '0'-logic;
%     'sweep'    -> the driver sweep from -1 ('0'-logic) to 1 ('1'-logic);
%   'not_sweep'  -> the driver sweep from 1 ('1'-logic) to -1 ('0'-logic);

driverPara.sweepType = 'lin'; %sweep creation following a linspace ('lin') or a logspace ('log') -> Nstep adviced 50
driverPara.NsweepSteps = 10;
driverPara.cycleLength = length(pCycle);
driverPara.clockStep = clock_step;
driverPara.NclockRegions = 3; % number of clock regions in the layout 
driverPara.phasesRepetition = 1; % How many time NclockRegions repeat in the layout?
driverPara.maxVoltage = 1.5; % maximum voltage (absolute value) the driver will assume in volts

%% Termination settings
terminationSettings.enableTermination = 1;  %set to '1' if you want to add a termination to the layout for bistability
%terminationSettings.customTermination = 0; %set to '1' if you want to use a custom layout file to choose the termination.
                                    %If set up to '0', a number of molecule equal to the ones of the last phase will be used for the
                                    %termination. (TO DO)
                                    
terminationSettings.customLength = 0; %specify a custom number of cells to realize each the termination. Default is 8 molecules
terminationSettings.busLayout = 1; %set to 1 for bus layouts, set to 0 for single line layouts

%% SCERPA settings
%layout (MagCAD)
file = 'bus.qll';
circuit.qllFile = fullfile(pwd,file);
circuit.magcadImporter = 1;
circuit.doubleMolDriverMode = driverPara.doubleMolDriver;  

%algorithm settings
settings.out_path = outputPath; 
settings.damping = 0.6;
settings.verbosity = 0;
settings.dumpDriver = 1;
settings.dumpOutput = 1;
settings.dumpClock = 1;
settings.dumpVout = 1;

%viewer settings
plotSettings.plot_waveform = 1;
plotSettings.plot_3dfig = 0;
plotSettings.plot_1DCharge = 0;
plotSettings.plot_logic = 0;
plotSettings.plot_potential = 1;
plotSettings.plotSpan = clock_step;
plotSettings.fig_saver = 0;
plotSettings.HQimage = 0;

%copy outputh path from algorithm settings if specified by the user
if isfield(settings,'out_path') 
    plotSettings.out_path = settings.out_path;
end

%% Characterization settings
charSettings.enableCharacterization = 1;
charSettings.LibPath = fullfile(outputPath,'Lib');
charSettings.LibDeviceName = "TestLib";
charSettings.out_path = fullfile(outputPath,'termination');
charSettings.sel_Vin = 0; % set to '1' if you want to use the Vin computed starting from QD's charge of the driver. '0' means to use the same Vin used as Values_Dr
charSettings.AllHoldValues = 0; %set to '1' if you want to plot every Vout when the output is in the Hold state. '0' means just the last one
charSettings.plotOnOut = 0; %Set to '1' if you want to plot the Vout on 'out' (after the last molecule) or to '0' for the Vout on the last molecule

%% Launch the BBchar software
charSettings.debugMode = 0; % - characteristic visually plotted instead of tabled
charSettings.LibEvaluation = 0; % Evaluate the behaviour starting from the library

%debugMode LibEvaluation
%   0           0          --> Characterize the layout creating the .csv
%   0           1          --> Use the library instead of SCERPA to eval Vout (InOut_eval.m)
%   1           0          --> Evaluate the layout correctness, launch SCERPA
%   1           1          --> Test every input combination with libraries (InOut_eval.m)


cd(BBcharPath)
circuit.Values_Dr = buildDriver(driverPara);
%clock matrix (row -> clock zone, column -> time step). 
circuit.stack_phase = buildClock(driverPara.NclockRegions,driverPara.NsweepSteps,driverPara.phasesRepetition,pReset,pCycle);
cd Terminations/
[circuit, terminationCircuit] = add_termination(circuit,terminationSettings,pCycle,length(pReset)); %It will handle internally the case circuit.termination == 0
cd ..
    
if charSettings.debugMode %debug = 1
    if charSettings.LibEvaluation %libEval = 1
%TODO% test library, plot waveform?        
    else %libEval = 0
        if terminationSettings.enableTermination
            circuit.qllFile = terminationCircuit.filepath;
            settings.out_path = fullfile(outputPath,'termination');
            plotSettings.out_path = settings.out_path;
        end   
        cd(scerpaPath)
        SCERPA('generateLaunchView',circuit,settings,plotSettings);
        cd(thisPath)
    end

else %debug = 0

    if charSettings.LibEvaluation %libEval = 1 
%TODO%         Vout = InOut_eval([-0.52 0.52], circuit, charactSettings);
    else %libEval = 0
        circuit.qllFile = fullfile(thisPath,'bus_termination.qll');
        characterization(circuit,charSettings,terminationCircuit);
    end

end
cd(thisPath)