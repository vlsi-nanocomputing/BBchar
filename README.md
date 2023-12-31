

[![DOI](https://zenodo.org/badge/731039379.svg)](https://zenodo.org/doi/10.5281/zenodo.10369741)


# BBchar Code Documentation
> Author: **Giuliana Beretta**

The provided code is a MATLAB program for characterizing and simulating the behavior of a molecular circuit layout using the BBchar software. The program applies to molecular Field-Coupled Nanocomputing (molFCN) circuits designed in [MagCAD](https://topolinano.polito.it/) and is able to:

- automatically generate input files for the simulation of the circuit in [SCERPA](https://github.com/vlsi-nanocomputing/SCERPA);
- automatically characterize the circuit in order to provide a look-up-table with the input/output description plus some additional informations regarding timing and area;
- provide the output of a circuit in the library given a geneic combination of the inputs.


Below is the documentation for the launching script code. 

## Contents 

The input script is organized into several sections, each addressing different aspects of the molFCN circuit simulation or characterization process. These sections include 
- [Paths definition](#paths-definition)
- [Clock signal parameters](#clock-signal-parameters)
- [Driver parameters](#driver-parameters)
- [Termination settings](#termination-settings)
- [SCERPA settings](#scerpa-settings)
- [Characterization settings](#characterization-settings)
- [Launch of the BBchar software](#launch-the-bbchar-software)
- [Example](#example)

## Paths Definition
The launching script begins by defining various file paths for data storage and retrieval

- **`myDataPath`**: The root path for data storage.
- **`BBcharPath`**: Path for BBchar-related files.
- **`BBcharCodePath`**: Path for BBchar code files.
- **`thisPath`**: Current working directory.
- **`scerpaPath`**: Path for SCERPA files.
- **`libraryPath`**: Path for the library files.
- **`outputPath`**: Path for storing simulation output.
- **`file`**: Name of the MagCAD layout file.


## Clock Signal Parameters
Define parameters related to the clock signal used in the simulation.

- **`clock_low`** and **`clock_high`**: Low and high voltage levels for the clock signal.
- **`clock_step`**: Number of steps in the clock signal.
- **`pSwitch`**, **`pHold`**, **`pRelease`**, and **`pReset`**: Clock signal profiles for different phases.
- **`pCycle`**: Combined clock signal for a full simulation cycle.


## Driver Parameters
Defines parameters related to the drivers of the circuit. All the variables must be a field of the same matlab structure.

- **`doubleMolDriver`**: Flag for using double-molecule driver.
- **`Ninputs`**: Number of physical inputs. If a driver is repeated several times in the circuit (repeated input, constant input, bus layout, etc.), it still counts as 1.

- **`driverNames`**: Names of the drivers as they are in the *.qll* layout file.
- **`maxVoltage`**: Maximum voltage value in volts for the drivers.
- **`driverModes`**: Values assumed by the drivers in the simulations, can be more than 1 value at a time. The possible values are:
    1. *sweep*: variation vector between '0' and '1' (voltage variation between -`maxVoltage` and `maxVoltage`)
    2. *not_sweep*: variation vector betwee '1' and '0' (voltage variation between `maxVoltage` and -`maxVoltage`)
    3. *0*: constant value equal to logic '0'
    4. *1*: constant value equal to logic '1'
- **`sweepType`**: Type of sweep for driver simulation. It can be `lin` for linear variations or `log` for logarithmic variations.
- **`NsweepSteps`**: Number of steps in the sweep.
- **`cycleLength`**: Length of a complete clock cycle.
- **`clockStep`**: Number of steps in the clock signal.
- **`NclockRegions`**: Number of clock regions.
- **`phasesRepetition`**: Number of times clock regions repeat.

## Termination Settings
Defines parameters related to termination of the circuit.  All the variables must be a field of the same matlab structure.

- **`enableTermination`**: Flag for enabling termination addition.
- **`customLength`**: Custom number of cells for termination.
- **`busLayout`**: Flag for bus or single line layouts.


## SCERPA Settings
Defines parameters related to the SCERPA simulation. Refer to the [SCERPA documentation](https://github.com/vlsi-nanocomputing/SCERPA/tree/release/Documentation) for details.

The program work only for layout generated with [MagCAD](https://topolinano.polito.it/), so the user must provide the `qllFile` and `magcadImporter` must be set to 1. Since the program used the *AdditionalInformation.txt* file generated by SCERPA, the algorithm settings must contain `dumpVout`. Plot settings are free.

## Characterization Settings
Defines parameters related to the molecular circuit characterization.  All the variables must be a field of the same matlab structure.
- **`LibPath`**: Path for the library files.
- **`LibDeviceName`**: Name of the library folder where the circuit characterization will be stored.
- **`out_path`**: Path where the simulation results to be used for the characterization are stored. 


## Launch the BBchar Software
Launches the BBchar software with specified settings and parameters. 
The possible commands of the program are related to the following three functionalities:
- **SIMULATE**: Launch a SCERPA simulation with the specified parameters
    - command *'simulate'*
- **CHARACTERIZE**: Starting from a previous SCERPA simulation, it characterize the device and store the library files where indicated.
    - command *'characterize'*
- **LIBRARY EVALUATION**: Provide the output of the specified device given the input combination.
    - command *'evaluate'*

Depending on the function required, the program automatically 
1. Checks for debug mode and library mode
2. Builds the driver and clock matrix.
3. Adds termination if enabled.
4. Executes BBchar software in the specified mode.

## Notes
Some sections include comments with "TODO" indicating incomplete parts of the code that need to be filled in.

## Example
The example below is the launching script for the simulation of a MUX21 circuit
### launchscript.m
    clear variables
    close all

#### Paths definition
    myDataPath = '~';
    BBcharPath = fullfile(myDataPath,'BBchar');
    BBcharCodePath = fullfile(BBcharPath,'Code');
    thisPath = pwd;
    scerpaPath = fullfile(myDataPath,'scerpa');
    libraryPath = fullfile(BBcharPath, 'Lib');
    outputPath = fullfile(BBcharPath,'Layouts','mux21');
    file = 'mux21.qll';

#### Clock signal parameters
    clock_low = -2;
    clock_high = +2;
    clock_step = 5; 

    pSwitch =  linspace(clock_low, clock_high, clock_step); 
    pHold =   linspace(clock_high, clock_high, clock_step); 
    pRelease =  linspace(clock_high, clock_low, clock_step);
    driverPara.pReset =   linspace(clock_low, clock_low, clock_step); 
    driverPara.pCycle = [pSwitch pHold pRelease pReset]; 

 #### Driver parameters
    driverPara.doubleMolDriver = 1;
    driverPara.Ninputs = 5; 
    driverPara.driverNames = [{'a'} {'b'} {'s'} {'C0'} {'C1'}]; 
    driverPara.driverModes = [{'0'} {'0'} {'0'} {'0'}; % combination for 'a'
                              {'0'} {'0'} {'1'} {'1'}; % combination for 'b'
                              {'0'} {'1'} {'0'} {'1'}; % combination for 's'
                              {'0'} {'0'} {'0'} {'0'}; % combination for 'C0'
                              {'1'} {'1'} {'1'} {'1'}];% combination for 'C1'
    driverPara.sweepType = 'lin'; 
    driverPara.NsweepSteps = 1;
    driverPara.cycleLength = length(pCycle);
    driverPara.clockStep = clock_step;
    driverPara.NclockRegions = 4;
    driverPara.phasesRepetition = 3; 
    driverPara.maxVoltage = 1; % value in volts

#### Termination settings
    terminationSettings.enableTermination = 1;
    terminationSettings.customLength = 0; 
    terminationSettings.busLayout = 1; 

 #### SCERPA settings
**Layout (MagCAD)**

    circuit.qllFile = fullfile(pwd,file);
    circuit.magcadImporter = 1;
    circuit.doubleMolDriverMode = driverPara.doubleMolDriver;  
    circuit.outIsPin = 0; 

 **Algorithm settings**

    settings.out_path = outputPath; 
    settings.damping = 0.6;
    settings.verbosity = 0;
    settings.dumpDriver = 1;
    settings.dumpOutput = 1;
    settings.dumpClock = 1;
    settings.dumpVout = 1;

**Viewer settings**

    plotSettings.plot_waveform = 1;
    plotSettings.plot_waveform_index = 1;
    plotSettings.plot_3dfig = 0;
    plotSettings.plot_1DCharge = 0;
    plotSettings.plot_logic = 1;
    plotSettings.plot_potential = 1;
    plotSettings.plotSpan = clock_step;
    plotSettings.fig_saver = 0;
    plotSettings.HQimage = 0;

    if isfield(settings,'out_path') 
        plotSettings.out_path = settings.out_path;
    end

#### Characterization settings
    charSettings.LibPath = libraryPath;
    charSettings.LibDeviceName = 'mux21';
    charSettings.out_path = outputPath;
   
#### Launch the BBchar software
    simulate = 1;
    characterize = 0;

    circuit.Values_Dr = buildDriver(driverPara);
    circuit.stack_phase = buildClock(driverPara);
    if terminationSettings.enableTermination % if the user want to add the termination
        [circuit, terminationCircuit] = add_termination(circuit,terminationSettings,driverPara.pCycle,length(pReset)); 
    else %termination not enabled
        termination.num = 0;
    end
        
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

The example below is the launching script for the evaluation of a MUX21 using the library.

### evaluate.m
    clear variables
    close all

 #### Paths definition
    myDataPath = '~';
    BBcharPath = fullfile(myDataPath,'BBchar');
    BBcharCodePath = fullfile(BBcharPath,'Code');
    thisPath = pwd;
    libraryPath = fullfile(BBcharPath, 'Lib');

 #### Input values
    %       H cell(molA molB)  L cell (molA molB)
    zero =  [-1 +1;             -1 +1]; 
    one =   [+1 -1;             +1 -1]; 
    DrA = one;
    DrB = zero; 
    DrS = zero;
    DrC0 = zero; 
    DrC1 = one; 

 #### Evaluation from block gates
    cd(BBcharCodePath)
    VoutL1 = InOut_eval(libraryPath,'Lwire_dxdw',DrA);
    VoutInvDr = InOut_eval(libraryPath,'invDr',DrS);
    VoutInvDr_neg = VoutInvDr(1:2,:);
    VoutInvDr_dr = VoutInvDr(3:4,:);
    VoutMV1 = InOut_eval(libraryPath,'MVlongdw',[VoutL1; VoutInvDr_neg; DrC0]);

    VoutL2 = InOut_eval(libraryPath,'Lwire_dxup',DrB);
    VoutMV2 = InOut_eval(libraryPath,'MVlongup',[DrC0; VoutInvDr_dr; VoutL2]);
    Vout_Lib = InOut_eval(libraryPath,'MVlongdx',[VoutMV1; DrC1; VoutMV2]);

 #### Evaluation of the entire gate
    Vout_scerpa = InOut_eval(libraryPath,'mux21',[DrA; DrB; DrS; DrC0; DrC1]);

#### Error calculation
    error_avg = mean(abs(Vout_Lib-Vout_scerpa),"all");
    error_min = min(min(abs(Vout_Lib-Vout_scerpa)));
    error_max = max(max(abs(Vout_Lib-Vout_scerpa)));

    fprintf("\nMean error: %e\nMin error: %e\nMax error: %e\n\n",error_avg,error_min,error_max);

    cd(thisPath)


## Acknowledgments
We extend our heartfelt appreciation to all contributors whose dedication and expertise have been instrumental in the development of the code, enriching our project with diverse perspectives and invaluable contributions. 

In casual order: Flavio Lupoli, Erik Lo Grasso.