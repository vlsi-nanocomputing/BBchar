%% VIN/VOUT - CHARACTERISTIC
function characterization( circuitSettings, charSettings,termination)
        
    % Simulation path setting
    simulation_path = fullfile(charSettings.out_path,'SCERPA_OUTPUT_FILES');
    
    % Tables loading
    table = readtable(fullfile(simulation_path,'Additional_Information.txt')); %Create a table from the file to read voltages
    tableNMol = load(fullfile(simulation_path,'simulation_output.mat')); %Load the table with every simulated value for the layout
    
    % per ogni uscita
    % - trova le due molecole prima della terminazione che vanno messe in 
    % lib (attenzione a strutture a bus)
    % - trova gli indici dei tempi in cui le molecole di uscita volute sono
    % in hold (attenzione a fasi ripetute)

    for outLoop = 1: termination.numOutput
    
    end
end