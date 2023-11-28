clear variables
close all

%% Paths definition
myDataPath = '~';
BBcharPath = fullfile(myDataPath,'BBchar');
BBcharCodePath = fullfile(BBcharPath,'Code');
thisPath = pwd;
scerpaPath = fullfile(myDataPath,'scerpa');
libraryPath = fullfile(BBcharPath, 'Lib');

outputPath = fullfile(BBcharPath,'Layouts','Lwire_dxup');
file = 'Lwire_dxup.qll';


%% Clock signal parameters

%definitions
clock_low = -2;
clock_high = +2;
clock_step = 5; 

%Step simulation implementation
pSwitch =  linspace(clock_low, clock_high, clock_step); % if step = 1 -> [-2 -1 0 1 2]
pHold =   linspace(clock_high, clock_high, clock_step); % if step = 1 -> [2 2 2 2 2]
pRelease =  linspace(clock_high, clock_low, clock_step); % if step = 1 -> [2 1 0 -1 -2]
driverPara.pReset =   linspace(clock_low, clock_low, clock_step); % if step = 1 -> [-2 -2 -2 -2 -2]

%Cycle to simulate
driverPara.pCycle = [pSwitch pHold pRelease driverPara.pReset]; % if step = 1 -> [-2 -1 0 1 2 -> 2 2 2 2 2 -> 2 1 0 -1 -2 -> -2 -2 -2 -2 -2 ]

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
driverPara.cycleLength = length(driverPara.pCycle);
driverPara.clockStep = clock_step;
driverPara.NclockRegions = 4; % number of clock regions in the layout 
driverPara.phasesRepetition = 1; % How many time NclockRegions repeat in the layout?
driverPara.maxVoltage = 1; % maximum voltage (absolute value) the driver will assume in volts

%% Termination settings
terminationSettings.enableTermination = 1;  %set to '1' if you want to add a termination to the layout for bistability
%terminationSettings.customTermination = 0; %set to '1' if you want to use a custom layout file to choose the termination.
                                    %If set up to '0', a number of molecule equal to the ones of the last phase before the termiination will be used for the
                                    %termination. (TO DO)
                                    
terminationSettings.customLength = 0; %specify a custom number of cells to realize each the termination. Default is 8 molecules
terminationSettings.busLayout = 1; %set to 1 for bus layouts, set to 0 for single line layouts

%% SCERPA settings
%layout (MagCAD)
circuit.qllFile = fullfile(pwd,file);
circuit.magcadImporter = 1;
circuit.doubleMolDriverMode = driverPara.doubleMolDriver;  
circuit.outIsPin = 0; %if 1, the output is the pin, otherwise is the last cell of the circuit

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
plotSettings.plot_waveform_index = 1;
plotSettings.plot_3dfig = 0;
plotSettings.plot_1DCharge = 0;
plotSettings.plot_logic = 1;
plotSettings.plot_potential = 1;
plotSettings.plotSpan = clock_step;
plotSettings.fig_saver = 0;
plotSettings.HQimage = 0;

%copy outputh path from algorithm settings if specified by the user
if isfield(settings,'out_path') 
    plotSettings.out_path = settings.out_path;
end

%% Characterization settings
charSettings.LibPath = libraryPath;
charSettings.LibDeviceName = 'Lwire_dxup';
charSettings.out_path = outputPath;
% charSettings.sel_Vin = 0; % set to '1' if you want to use the Vin computed starting from QD's charge of the driver. '0' means to use the same Vin used as Values_Dr
% charSettings.allHoldValues = 0; %set to '1' if you want to plot every Vout when the output is in the Hold state. '0' means just the last one
% charSettings.plotOnOut = 0; %Set to '1' if you want to plot the Vout on 'out' (after the last molecule) or to '0' for the Vout on the last molecule

%% Launch the BBchar software
simulate = 0;
characterize = 1;

cd(BBcharCodePath)
circuit.Values_Dr = buildDriver(driverPara);
circuit.stack_phase = buildClock(driverPara);
if terminationSettings.enableTermination % if the user want to add the termination
    [circuit, terminationCircuit] = add_termination(circuit,terminationSettings,driverPara.pCycle,length(driverPara.pReset)); 
else %termination not enabled
    termination.num = 0;
end
cd(thisPath)
    
% launcher
if simulate  
    if terminationSettings.enableTermination
        circuit.qllFile = terminationCircuit.filepath;
        settings.out_path = outputPath;
        plotSettings.out_path = settings.out_path;
    end
    cd(scerpaPath)
    diary on
    SCERPA('generateLaunchView',circuit,settings,plotSettings);
    % SCERPA('plotSteps',plotSettings)
    diary off
    if isfield(settings,'out_path') 
        movefile('diary',fullfile(settings.out_path,'logfile.log'))
    end
    cd(thisPath)
elseif characterize
    cd(BBcharCodePath)
    tic
    characterization(charSettings,terminationSettings,terminationCircuit,driverPara,circuit.Values_Dr);
    charTime = toc;
    cd(thisPath)
end