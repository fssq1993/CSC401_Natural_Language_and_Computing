function p2 = calculate_p2(trans_sent,trans_google,trans_ref)     
C=0;
origin_google=strjoin(trans_google,' ');
origin_ref=strjoin(trans_ref,' ');
for i=1:length(trans_sent)-1
    compare=[trans_sent(i),' ',trans_sent(i+1)];
    compare=strjoin(compare);
    compare=regexprep(compare,' +',' ');

    if ~isempty(strfind(origin_google,compare))||~isempty(strfind(origin_ref,compare))
        C=C+1;
        disp('---------p2---------')
        disp(compare);
    end
end
p2=C/(length(trans_sent)-1);