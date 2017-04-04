function p3 = calculate_p3(trans_sent,trans_google,trans_ref)     
C=0;
origin_google=strjoin(trans_google,' ');
origin_ref=strjoin(trans_ref,' ');
for i=1:length(trans_sent)-1-1
    compare=[trans_sent(i),' ',trans_sent(i+1),' ',trans_sent(i+2)];
    compare=strjoin(compare);
    compare=regexprep(compare,' +',' ');

    if ~isempty(strfind(origin_google,compare))||~isempty(strfind(origin_ref,compare))
        C=C+1;
        disp('---------p3---------')
        disp(compare);
    end
end
p3=C/(length(trans_sent)-1-1);