function p1 = calculate_p1(trans_sent,trans_google,trans_ref)     
C=0;
for i=2:length(trans_sent)-1
    if ismember(trans_sent(i),trans_google)||ismember(trans_sent(i),trans_ref)
        C=C+1;
        disp('---------p1---------')
        disp(trans_sent(i));
    end
end
p1=C/(length(trans_sent)-2);