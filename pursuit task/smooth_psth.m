function [smooth_data]  = smooth_psth(raw_psth, SD, type, circular)
if(SD==0) % do not smooth
    smooth_data = raw_psth;
    return;
end
trans = 0;
if(size(raw_psth,1) ~=1)
    if(size(raw_psth,2)~=1)
        error(' can not run smooth_psth on matrix');
    end
   trans = 1; 
   raw_psth = raw_psth';  
end
 

%mean_FR = mean(raw_psth);
%SD = (1/mean_FR)*1000;
 

if(exist('circular', 'var') && circular)
     prefix = raw_psth(end-3*SD+1:1:end);
    postfix  = raw_psth(1:1:3*SD);
else
    

    prefix = raw_psth(3*SD:-1:1);
    postfix  = raw_psth(end:-1:end-3*SD+1);
end
 

 

raw_psth = [prefix,raw_psth,postfix];
if(~exist('type','var') || isempty(type))
    type ='GAUSS';
end
if(strcmp(type, 'GAUSS'))
    win=normpdf(-3*SD:3*SD,0,SD);
elseif(strcmp(type, 'MOV_AVG'))
    win = ones(1, 1+SD);   
else
    error([ 'smooth method: ' type ' unknown']);
end
is_nan = isnan(raw_psth);
INF_VAL = 10^50;
VERY_BIG_VAL =10^20;
raw_psth(is_nan) = INF_VAL; 
win = win/sum(win);
smooth_data =filtfilt(win,1,raw_psth);
smooth_data = smooth_data(3*SD+1:end-3*SD);
 

% FIX ME!!! add nans to the vector: not the safest way to to this - but it
% works in normal cases ...
smooth_data(smooth_data > VERY_BIG_VAL) = NaN;
if(trans) 
    smooth_data = smooth_data';
end
end