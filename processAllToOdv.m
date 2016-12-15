function processAllToOdv
% processAllToOdv
% rread all OUTPACE ODV txt files and write all data global file

% we don't use Dissolved_Fe, test station !
% dfe = odvReader('files/Dissolved_Fe.txt',false).read();

% create readODV object from fileName
ctd = odvReader('files/OUTPACE_CTD.txt',true).read();
n2f = odvReader('files/N2_Fixation.txt', false).read();
nh4 = odvReader('files/NH4.txt',false).read();
nut = odvReader('files/Nutrients.txt',false).read();
bac = odvReader('files/Bacterial_production_new.txt',false).read();
dor = odvReader('files/Dissolved_organic_carbon.txt',false).read();
pon = odvReader('files/PON_POP.txt',false).read();
don = odvReader('files/DON_DOP.txt',false).read();
ppr = odvReader('files/Primary_production.txt',false).read();
dip = odvReader('files/DIP_turnover.txt',false).read();
pig = odvReader('files/Pigments_BSi_LSi_POC_PON_new.txt',false).read();
cyt = odvReader('files/Flow_cytometry_new.txt',false).read();
nif = odvReader('files/Diazotrophs_nifH.txt',false).read();
tep = odvReader('files/TEP.txt',false).read();
nbFile = 14;
%nbFile = 11;

% write ODV header
fid_odv = write_odv_header('OUTPACE_ALL_odv.txt');

str = sprintf(repmat('%s',1,nbFile), ctd.finalHeader, n2f.finalHeader,...
  nh4.finalHeader,nut.finalHeader,bac.finalHeader,...
  dor.finalHeader,pon.finalHeader,don.finalHeader,ppr.finalHeader,...
  dip.finalHeader,pig.finalHeader,cyt.finalHeader,nif.finalHeader,...
  tep.finalHeader);
%{
str = sprintf(repmat('%s',1,nbFile), ctd.finalHeader, n2f.finalHeader,...
  nh4.finalHeader,nut.finalHeader,...
  dor.finalHeader,pon.finalHeader,don.finalHeader,ppr.finalHeader,...
  dip.finalHeader,nif.finalHeader,...
  tep.finalHeader);
  %}
  % remove the extra tabulation and write to file
  fprintf(fid_odv, '%s\n', regexprep(str, '(.*)\t', '$1'));
  
  % loop over composite keys
  for theKey = keys(ctd)
    k = char(theKey);
    disp(k)
    str = sprintf(repmat('%s',1,nbFile), ctd(k),n2f(k),nh4(k),...
      nut(k),bac(k),dor(k),pon(k),don(k),ppr(k),...
      dip(k),pig(k),cyt(k),nif(k),tep(k));
    %{
  str = sprintf(repmat('%s',1,nbFile), ctd(k),n2f(k),nh4(k),...
    nut(k),dor(k),pon(k),don(k),ppr(k),...
    dip(k),nif(k),tep(k));
      %}
      % remove the extra tabulation and write to file
      fprintf( fid_odv, '%s\n', regexprep(str, '(.*)\t', '$1'));
  end
  
  fclose(fid_odv);
  
  % create header for ODV file
  % --------------------------
  function [fid] = write_odv_header( odv_filename)
    
    % Open the file
    % -------------
    fid = fopen( odv_filename, 'wt' );
    if fid ~= -1
      
      % Display more info about write file on console
      % ---------------------------------------------
      fprintf('...writing ODV file: %s ... \n', odv_filename);
      
      today = datestr(now, 'YYYY-mm-ddTHH:MM:SS');
      fprintf(fid, '//ODV Spreadsheet file : %s\n', odv_filename);
      fprintf(fid, '//Data treated : %s\n', today);
      fprintf(fid, '//<InstrumentType>ODV global file</InstrumentType>\n');
      fprintf(fid, '//<Source>OUTPACE</Sources>\n');
      fprintf(fid, '//<Creator>Jacques.Grelet@ird.fr</Creator>\n');
      fprintf(fid, '//\n');
    end
    
  end % end of write_odv_header

end % end of main outpaceAll
