%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in
%  Task 5.

% some of your definitions
trainDir     = 'F:\UT_Courses\CSC2511 Natural Language Computing\A2_SMT\A2_SMT\data\Hansard\Training';
testDir      = 'F:\UT_Courses\CSC2511 Natural Language Computing\A2_SMT\A2_SMT\data\Hansard\Testing';
fn_LME       = 'Hansard_e.mat';
fn_LMF       = 'Hansard_f.mat';
fn_AM        = 'AM.mat';
lm_type      = '';
delta        = 0;
% vocabSize    = length(fieldnames(fn_LMF.uni));
all_numSentences = [1000,10000,15000,30000];
maxIt        = 10;
all_n        = [1,2,3]; %n-gram
all_bleu     = zeros(25, 4, 3);

% Train your language models. This is task 2 which makes use of task 1
% LME = lm_train( trainDir, 'e', fn_LME );
% LMF = lm_train( trainDir, 'f', fn_LMF );
LME = load('Hansard_e.mat');
LME = LME.LM;
LMF = load('Hansard_f.mat');
LMF = LMF.LM;
% for index_numSentences=1:length(all_numSentences)
for index_numSentences=1:4

    numSentences=all_numSentences(index_numSentences);
    
    % Train your alignment model of French, given English
    
%     AMFE = align_ibm1( trainDir, numSentences ,maxIt,fn_AM);
    AMFE = load(['am_' num2str(numSentences) '.mat']);
    AMFE = AMFE.AMFE;
    
    % ... TODO: more
    
%     save(['am_' num2str(numSentences) '.mat'], 'AMFE', '-mat');
    vocabSize    = length(fieldnames(AMFE));
    
    % TODO: a bit more work to grab the English and French sentences.
    %       You can probably reuse your previous code for this
    % task5_f = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f';
    % task5_e = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e';
    % task5_g = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e';
    
    task5_e = [testDir,'\Task5.e'];
    task5_g = [testDir,'\Task5.google.e'];
    task5_f = [testDir,'\Task5.f'];
    
    french_sens = textread(task5_f, '%s', 'delimiter', '\n');
    english_sens = textread(task5_e, '%s', 'delimiter', '\n');
    google_sens = textread(task5_g, '%s', 'delimiter', '\n');
    
    % unix_pre = 'env LD_LIBRARY_PATH='''' curl -u 6aaea5e9-df0e-4a9b-aefd-aecb761781db:WTceKuyFlVeu -X POST -F "text=';
    % unix_post = '" -F "source=fr" -F "target=en" https://gateway.watsonplatform.net/language-translation/api/v2/translate';
    
    % Decode the test sentence 'fre'
    % eng = decode( fre, LME, AMFE, 'smooth', delta, vocabSize );
    
    % TODO: perform some analysis
    % add BlueMix code here
    for index=1:length(french_sens)
        fre_sent = french_sens{index};
        
        fre_sent = preprocess(fre_sent, 'f');
        %     model_trans = decode2(fre, LME, AMFE, 'smooth', delta, vocabSize);
        trans_sent = decode2(fre_sent, LME, AMFE, '', delta, vocabSize);
        
        %     command = strjoin({unix_pre, french_sens{index}, unix_post});
        
        %     [status, bluemix_trans] = unix(command);
        trans_google = google_sens{index};
        trans_ref = english_sens{index};
        
        % Preprocess the translation
        trans_google = preprocess(trans_google,'e');
        trans_google = strsplit(' ',trans_google);
        %     trans_google(1)=[];
        %     trans_google(end)=[];
        
        trans_ref = preprocess(trans_ref,'e');
        trans_ref = strsplit(' ',trans_ref);
        %     trans_ref(1)=[];
        %     trans_ref(end)=[];
        
        %     bluemix_trans = initialize_trans(bluemix_trans);
        %     bluemix_trans = strsplit(' ',bluemix_trans);
        %     bluemix_trans(1)=[];
        %     bluemix_trans(end)=[];
        
        % Remove sentence marks for decoded translation
        trans_sent = strsplit(' ', trans_sent);
        %     trans_sent(1) = [];
        %     trans_sent(end) = [];
        
        %disp(strjoin(splitted_trans));
        
        %     refs = {trans_google, trans_ref, bluemix_trans};
        
        % Calculate BLEU score
        
        % Calculate Brevity (bp)
        len_google=length(trans_google)-2;
        len_ref=length(trans_ref)-2;
        len_sent=length(trans_sent)-2;
        if abs(len_google-len_sent)>abs(len_ref-len_sent)
            bp=len_ref/len_sent;
        else
            bp=len_google/len_sent;
        end
        if bp<1
            bp=1;
        else
            bp=exp(1-bp);
        end
        
        % Calculate the precision
        bleu=0;
        for index_n=1:length(all_n)
            n=all_n(index_n);
            
            disp([num2str(index) ' ' num2str(numSentences) ' ' num2str(index_n)]);
            disp(['google:',strjoin(trans_google,' ')]);
            disp(['ref:',strjoin(trans_ref,' ')]);
            disp(['trans:',strjoin(trans_sent,' ')]);
            
            if n==1
                p1=calculate_p1(trans_sent,trans_google,trans_ref);
                bleu=bp*p1;
            else
                if n==2
                    p1=calculate_p1(trans_sent,trans_google,trans_ref);
                    p2=calculate_p2(trans_sent,trans_google,trans_ref);
                    bleu=bp*(p1*p2)^(1/n);
                else
                    if n==3
                        p1=calculate_p1(trans_sent,trans_google,trans_ref);
                        p2=calculate_p2(trans_sent,trans_google,trans_ref);
                        p3=calculate_p3(trans_sent,trans_google,trans_ref);
                        bleu=bp*(p1*p2*p3)^(1/n);
                    end
                end
                
            end
            %     bleu = bleu_score(trans_sent, refs, 1);
            disp([index,' ',index_numSentences,' ',index_n]);
            disp(bleu);
            all_bleu(index,index_numSentences,index_n)=bleu;
        end        
    end
end
save('all_bleu.mat', 'all_bleu', '-mat');
% [status, result] = unix('')