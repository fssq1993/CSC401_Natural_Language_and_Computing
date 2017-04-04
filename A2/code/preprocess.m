function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French)
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz
%   The Presiding Officer (Mr. Caccia):
global CSC401_A2_DEFNS

% first, convert the input sentence to lower-case and add sentence marks
inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

% trim whitespaces down
inSentence = regexprep( inSentence, '\s+', ' ');

% initialize outSentence
outSentence = inSentence;

% perform language-agnostic changes
% TODO: your code here
%    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');

%Separate sentence-final punctuation.
%   last=outSentence(end-8);
%   fprintf(last);
%   if(~(('0'<=last && last<='9')||('a'<=last && last<='z')||('A'<=last && last<='Z')))
%       outSentence=[outSentence(1:end-9) ' ' last outSentence(end-7:end)];
%   end
%这里分离的是最后一个非字母和数字的字符，可能会与下面冲突

%Separate sentence-final punctuation
outSentence = regexprep(outSentence,'!',' !');
outSentence = regexprep(outSentence,'?',' ?');
outSentence = regexprep(outSentence,'\.',' \.');

%Separate commas.
outSentence = regexprep(outSentence,',',' ,');

%Separate colons
outSentence = regexprep(outSentence,':',' :');

%Separate semicolons
outSentence = regexprep(outSentence,';',' ;');

%Separate parentheses
outSentence = regexprep(outSentence,')',' )');
outSentence = regexprep(outSentence,'(','( ');

%Separate dashes between parentheses
if(~isempty(regexp(outSentence,'\((.*?)\)', 'once')))
    [startIndex,endIndex]=regexp(outSentence,'\((.*?)\)');
    substr=regexprep(outSentence(startIndex:endIndex),'-',' - ');
    outSentence=[outSentence(1:startIndex-1),substr,outSentence(endIndex+1:end)];
end
% outSentence = regexprep(outSentence,'\((.*?)\)','');
% (-)这种情况怎么办？有时候会有两个空格
% 如果没有找到这种情况怎么办？不应该执行，好像可以

%Separate mathematical operators
operators={'+','-','<','>','='};
for k=1:5
    position = find(outSentence == operators{k});
    size_position=size(position);
    size_position=size_position(2);
    for i=1:size_position
        index=position(i);
        if (isstrprop(outSentence(index-1),'digit')) && (isstrprop(outSentence(index+1),'digit'))
            outSentence = [outSentence(1:index-1),' ',operators{k},' ',outSentence(index+1:end)];
%             outSentence = regexprep(outSentence,['\d',operators{k},'\d'],[' ',operators{k},' ']);
        end
    end
end

%Separate quotation marks
% if(~isempty(regexp(outSentence,'\"(.*?)\"', 'once')))
%     [startIndex,endIndex]=(regexp(outSentence,'\"(.*?)\"'));
%     outSentence=[outSentence(1:startIndex-1),'" ',outSentence(startIndex+1:endIndex-1),' "',outSentence(endIndex+1:end)];
% end
outSentence = regexprep(outSentence,'"',' " ');


clitics_e = {'s'' ','''s ', '''re ', '''m ', '''ve ', '''d ', '''ll ', 'n''t '};
size_clitics_e=size(clitics_e);
number_e=size_clitics_e(2);

switch language
    case 'e'
        % TODO: your code here
        for k=1:number_e
            if k==1
                outSentence = regexprep(outSentence,clitics_e(k),'s '' ');
            else outSentence = regexprep(outSentence,clitics_e(k),' $0');
            end
        end
        
    case 'f'
        % TODO: your code here
        %Clitics and possessives
        outSentence = regexprep(outSentence,'l''','l'' ');
        
        %Single-consonant words ending in e-'muet'
        outSentence = regexprep(outSentence,'je t''','je t'' ');
        outSentence = regexprep(outSentence,'j''','j'' ');
        outSentence = regexprep(outSentence,'d''hi','d'' hi');
        outSentence = regexprep(outSentence,'m''','m'' ');
        outSentence = regexprep(outSentence,'t''','t'' ');

        
        outSentence = regexprep(outSentence,'qu''','qu'' ');
        outSentence = regexprep(outSentence,'''on',''' on');
        outSentence = regexprep(outSentence,'''il',''' il');
        
end
outSentence=regexprep(outSentence,' +',' ');

% change unpleasant characters to codes that can be keys in dictionaries
outSentence = convertSymbols( outSentence );
