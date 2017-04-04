function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
  % Example: Boats took the place of trucks and trains, 这里不需要预处理吗？
%   disp(words);
  %   Maximum the Log likelihood
  if isempty(type)
      MLE=0;
      for i=2:numel(words)-2
           first_word=words(i);
           first_word=first_word{1};
           second_word=words(i+1);
           second_word=second_word{1};
%            disp(first_word);
           if isfield(LM.bi,first_word)
               if isfield(LM.bi.(first_word),second_word)
%                    disp(MLE);
                   MLE=MLE+log2(LM.bi.(first_word).(second_word)/LM.uni.(first_word));
               else
                   MLE=MLE-Inf;
               end
           else
               MLE=MLE-Inf;
           end
      end
      logProb=MLE;
  %Smoothing
  else
%       disp('Smooooooooooooooothing')
      Smooth=0;
      for i=1:numel(words)-1
          first_word=words(i);
          first_word=first_word{1};
          second_word=words(i+1);
          second_word=second_word{1};
%           disp(first_word);
          if isfield(LM.bi,first_word)
              if isfield(LM.bi.(first_word),second_word)
%                   disp(Smooth);
                  Smooth=Smooth+log2((LM.bi.(first_word).(second_word)+delta)/(LM.uni.(first_word)+delta*vocabSize));
              else
                  Smooth=Smooth+log2(delta/(LM.uni.(first_word)+delta*vocabSize));
              end
          else
              Smooth = Smooth + log2(1/vocabSize);
          end
      end
      logProb=Smooth;
  end

  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return