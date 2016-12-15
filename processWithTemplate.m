function processWithTemplate
% processWithTemplate.m
% use OUTPACE_CTD.txt as template to adjust file without all bottles

%
% create readODV object from fileName
ctd = odvReader('files/OUTPACE_CTD.txt',true).read();
%sec = odvReader('files/Bacterial_production.txt',false).read();
sec = odvReader('files/Pigments_BSi_LSi_POC_PON.txt',false).read();
%sec = odvReader('files/Flow_cytometry.txt',false).read();
nbFile = 2;

% write ODV header
%fid_odv = write_odv_header('files/Bacterial_production_new.txt');
fid_odv = write_odv_header('files/Pigments_BSi_LSi_POC_PON_new.txt');
%fid_odv = write_odv_header('files/Flow_cytometry_new.txt');

str = sprintf(repmat('%s',1,nbFile), ctd.finalHeader, sec.finalHeader);

% remove the extra tabulation and write to file
fprintf(fid_odv, '%s\n', regexprep(str, '(.*)\t', '$1'));

% loop over composite keys
for theKey = keys(ctd)
  k = char(theKey);
  if isKey(sec,k)
    str = sprintf(repmat('%s',1,nbFile), ctd(k),sec(k));
    % remove the extra tabulation and write to file
    fprintf( fid_odv, '%s\n', regexprep(str, '(.*)\t', '$1'));
  else
    tab = sprintf(repmat('\t',1,sec.columns));
    fprintf( fid_odv, strcat(repmat('%s',1,nbFile),'\n'), ctd(k), tab);
  end
  
end

fclose(fid_odv);

% create header for ODV file
% --------------------------
  function [fid] = write_odv_header( odv_filename)
    
    % Open the file
    % -------------
    fid = fopen( odv_filename, 'wt' );
    
  end % end of write_odv_header

end % end of main processWithTemplate
