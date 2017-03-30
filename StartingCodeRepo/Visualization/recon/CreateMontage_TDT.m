function CreateMontage_TDT (sbjid, trodes)
    %load in your trodes.mat file and this will generate a montage file to be
    %used with various analyses
    
    %Note: with the TDT system, we now can record for all channels in a
    %montage. So this script pumps out a montage file with all channels
      
    %ReconSide = input('Which hemisphere do you want to show? ("l" or "r") ','s');
    %biHemi = input('Is this a strips pt with bilateral coverage (y/n)? ','s');
    
    %created 12/2/15 -by KEW at UW & Grid Lab
    
    
    %filepath = promptForBCI2000Recording;
    %load(filepath);
    load(trodes)
    
    tempMont = [];
    tempStr = [];
    
    %sbjid = extractSubjid(filepath); %this may work depending on where you keep the trodes.mat file
    %sbjid = input('What is your subject ID#? ','s');
    
    for i = 1:size(TrodeNames,2)
        
        tmp = size(eval(strcat(TrodeNames{i})),1); %size of current array
        tmpName = strcat(TrodeNames{i}); %name of current array
        
        tempMont = [tempMont tmp]; %load array size into a scrolling array
        tempTok(i) = {strcat(tmpName,sprintf('(1:%d)', tmp))}; %load array name into a scrolling strucutred cell 
        
    end
        tempStr =  sprintf(' %s ', tempTok{1:i}); %generate array for string names
            
        Montage.Montage = tempMont;
        Montage.MontageTokenized = tempTok;
        Montage.MontageString = tempStr;
        Montage.MontageTrodes = AllTrodes;
        Montage.BadChannels = [];
        %Montage.Default = true;
        
        save([sbjid '_Montage.mat'], 'Montage');
    
end

