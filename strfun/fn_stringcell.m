% fn_stringcell
function vt_out	= fn_stringcell(vt_string,ch_delimiter)

if nargin < 1
    return;
elseif nargin < 2 
    vt_out	= cellstr(vt_string);
    return
end

vt_out  = cell(1);
ch_line = vt_string;
nm_it   = 1;

while true
    [ch_token,ch_line]	= strtok(ch_line, ch_delimiter);
    
    ch_token    = strtrim(ch_token);
    nm_numToken	= str2double(ch_token);
    
    if isnan(nm_numToken)
        vt_out{nm_it}   = ch_token;
    else
        vt_out{nm_it}	= nm_numToken;
    end
       
    if isempty(ch_line)
        break;
    end
    
    ch_line	= strtrim(ch_line);
    nm_it   = nm_it + 1;
    
end
