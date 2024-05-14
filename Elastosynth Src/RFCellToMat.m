function RF_Matrix = RFCellToMat(RF_Data, Tstarts, transducer, imageopts)
    
    %  Read the data and adjust it in time

    truncation_length = FindTruncation(RF_Data)

    size(1:imageopts.decimation_factor:truncation_length,2)
    
    RF_Matrix = zeros(size(1:imageopts.decimation_factor:truncation_length,2), imageopts.no_lines);
    for i=1:imageopts.no_lines
    
      %  Load the result
    
      % cmd=['load rf_data/rf_ln',num2str(i),'.mat'];
      % disp(cmd)
      % eval(cmd)
      
      %  Find the envelope
    
      rf_data = RF_Data{i};
      tstart = Tstarts(i,1);
      RF_Matrix(:,i) = rf_data(1:imageopts.decimation_factor:truncation_length);
    end

end

function truncation_size = FindTruncation(RF_Data)

    min_length = size(RF_Data{1},1);

    for i = 2:length(RF_Data)

        curr_length = size(RF_Data{i},1);

        if (min_length > curr_length)
            min_length = curr_length;
        end

    end

    truncation_size = min_length(1);


end