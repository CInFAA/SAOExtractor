%% SAO file extractor
% Usage:
%       > SAOstruct=SAOExtractor(FILENAME) extract all the information of a
%       SAO (Standard Archiving Output) file. The output is a struct
%       variable with all the available information. The "Scaled" field is
%       a nested struct with all the 49 variables registered on SAO format 
%       4.3
function SAOstruct=SAOExtractor(file)
format='%[^\r\n]'; delimiter=''; eol='\r\n';
fid=fopen(file);
D=textscan(fid,format,'HeaderLines',0,'Delimiter',delimiter,'EndOfLine',eol);
SAOarch=D{1};
Dindex1=textscan(pad(SAOarch{1},120,'left',' '),repmat('%3c',1,40),'WhiteSpace','','Delimiter','');
Dindex2=textscan(pad(SAOarch{2},120,'left',' '),repmat('%3c',1,40),'WhiteSpace','','Delimiter','');
Dindex1=cellfun(@str2num,Dindex1,'UniformOutput',false);
Dindex2=cellfun(@str2num,Dindex2,'UniformOutput',false);
noe=[cell2mat(Dindex1),cell2mat(Dindex2)];
fmt_cell={'%7.3f','%120c','%1c','%8.3f','%2d','%7.3f',... %Data Index, Geof. Const.,Description,Time and Sounder,Scaled,Flags,Doppler Table.
          '%8.3f','%8.3f','%3d','%1d','%8.3f',...         %O trace F2
          '%8.3f','%8.3f','%3d','%1d','%8.3f',...         %O trace F1
          '%8.3f','%8.3f','%3d','%1d','%8.3f',...         %O trace E
          '%8.3f','%3d','%1d','%8.3f',...                 %X trace F2
          '%8.3f','%3d','%1d','%8.3f',...                 %X trace F1
          '%8.3f','%3d','%1d','%8.3f',...                 %X trace E
          '%3d','%3d','%3d',...                           %Median Amplitude of F, E and Es
          '%11.6f','%11.6f','%11.6f',...                  %T. Height Coeff. UMLCAR
          '%20.12f',...                                   %Quazi-parabolic segments
          '%1d',...                                       %Edit Flags
          '%11.6f',...                                    %Valley description
          '%8.3f','%3d','%1d','%8.3f',...                 %O trace Es
          '%8.3f','%3d','%1d','%8.3f',...                 %O trace E Auroral
          '%8.3f','%8.3f','%8.3f',...                     %True Height Profile
          '%1c','%1c','%1c',...                           %URSI Q/D Letters and Edit Flags Traces/Profile
          '%11.6f','%8.3f','%8.3f','%8.3f'};              %Auroral E Profile Data
%NOTE: Comments above are the same for "var_cell"
var_cell={'geophcon','sysdes','timesound','Scaled','aflags','dopptab',...
          'OTF2vh','OTF2th','OTF2amp','OTF2dpn','OTF2fq',...
          'OTF1vh','OTF1th','OTF1amp','OTF1dpn','OTF1fq',...
          'OTEvh','OTEth','OTEamp','OTEdpn','OTEfq',...
          'XTF2vh','XTF2amp','XTF2dpn','XTF2fq',...
          'XTF1vh','XTF1amp','XTF1dpn','XTF1fq',...
          'XTEvh','XTEamp','XTEdpn','XTEfq',...
          'mdampF','mdampE','mdampEs',...
          'thcf2','thcf1','thce',...
          'QPS',...
          'edflags',...
          'vlydesc',...
          'OTEsvh','OTEsamp','OTEsdpn','OTEsfq',...
          'OTEavh','OTEaamp','OTEadpn','OTEafq',...
          'TH','PF','ED',...
          'Qletter','Dletter','edflagstp',...
          'thcea','thea','pfea','edea'};
scal_cell={'foF','foF1','M3000F','MUF3000','fmin','foEs','fminF','fminE',...
           'foE','fxI','hF','hF2','hE','hEs','hmE','ymE',...
           'QF','QE','downF','downE','downEs','FF','FE','D',...
           'fMUF','hMUF','dfoF','foEp','fhF','fhF2','foF1p','hmF2',...
           'hmF1','h05NmF2','foFp','fminEs','ymF2','ymF1','TEC','Ht',...
           'B0','B1','D1','foEa','hEa','foP','hP','fbEs','TypeEs'};
count=2;
for i0=1:length(fmt_cell)
    if noe(i0)==0
        continue;
    end
    switch fmt_cell{i0}
        case '%7.3f'
            num_ch=7;
        case '%8.3f'
            num_ch=8;
        case '%11.6f'
            num_ch=11;
        case '%20.12f'
            num_ch=20;
        case '%120c'
            num_ch=120;
        case '%1c'
            num_ch=1;
        case '%1d'
            num_ch=1;
        case '%2d'
            num_ch=2;
        case '%3d'
            num_ch=3;
    end
    line_in=SAOarch{count+1};
    fixln=length(line_in);
    if mod(fixln,num_ch)~=0
        line_in=pad(line_in,num_ch*ceil(fixln/num_ch),'left',' ');
    end
    if strcmp(var_cell{i0},'Qletter') || strcmp(var_cell{i0},'Dletter')
       line_in=pad(line_in,noe(i0),'left',' ');
    end
    if strcmp(var_cell{i0},'Scaled')==0
        in_off=0;
        for i1=1:noe(i0)
            i2=i1+in_off;
            if i2*num_ch>length(line_in)
                in_off=in_off-ceil(fixln/num_ch);
                count=count+1;
                line_in=SAOarch{count+1};
                fixln=length(line_in);
                if mod(fixln,num_ch)~=0
                    line_in=pad(line_in,ceil(fixln/num_ch)*num_ch,'left',' ');
                end
                i2=i1+in_off;
            end
            aux_out=textscan(line_in((1+num_ch*(i2-1)):(num_ch*i2)),fmt_cell{i0},'WhiteSpace','','Delimiter','');
            if ischar(aux_out{1}) && isempty(aux_out{1})
                aux_out{1}=' ';
            end
            SAOstruct.(var_cell{i0})(:,i1)=aux_out{1};
        end
    else
        in_off=0;
        for i1=1:noe(i0)
            i2=i1+in_off;
            if i2*num_ch>length(line_in)
                in_off=in_off-ceil(fixln/num_ch);
                count=count+1;
                line_in=SAOarch{count+1};
                fixln=length(line_in);
                if mod(fixln,num_ch)~=0
                    line_in=pad(line_in,ceil(fixln/num_ch)*num_ch,'left',' ');
                end
                i2=i1+in_off;
            end
            aux_out=textscan(line_in((1+num_ch*(i2-1)):(num_ch*i2)),fmt_cell{i0},'WhiteSpace','','Delimiter','');
            SAOstruct.(var_cell{i0}).(scal_cell{i1})(1)=aux_out{1};
        end
    end
    count=count+1;
end
SAOstruct.sysdes=SAOstruct.sysdes'; %Correction for the System Description field
end