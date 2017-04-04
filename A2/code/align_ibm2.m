function AM = align_ibm2(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm2
% 
%  This function implements the training of the IBM-2 word alignment algorithm. 
%  We assume that we are implementing D(a_j|j,L_E,L_F)P(f_j|e_a_j)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%


  % TODO: your code goes here.
    eng = {};
    fre = {};
    
    list = dir( [ mydir, filesep, '*', 'e'] );
    count = 0;
    
    for index = 1:length(list)
        e_name = list(index).name;
        f_name = strrep(e_name, '.e', '.f');

    
        e_lines = textread([mydir, filesep, e_name], '%s','delimiter','\n');
        f_lines = textread([mydir, filesep, f_name], '%s','delimiter','\n');
        
        for i=1:length(e_lines)
            e_line = e_lines(i);
            e_line = e_line{1};
            disp(e_line);
            eng{count+1} = strsplit(' ', preprocess(e_line, 'e'));

            f_line = f_lines(i);
            f_line = f_line{1};
            disp(f_line);
            disp('--------------------------------------------------------------------');
            fre{count+1} = strsplit(' ', preprocess(f_line, 'f'));

            count = count + 1;
            if(count==numSentences)
                break;
            end
        end
        save('eng.mat', 'eng', '-mat');
        save('fre.mat', 'fre', '-mat');
        if(count==numSentences)
            break;
        end

        
    end

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)
    % TODO: your code goes here
    storage = struct();

    for line_index=1:length(eng)
        for element_index=2:length(eng{line_index})-1
        %for element_index=1:length(eng{line_index})
            if length(eng{line_index}{element_index})>63
                eng{line_index}{element_index}=eng{line_index}{element_index}(1:63);
            end
            if  ~isfield(AM, eng{line_index}{element_index})
%                 if strcmp(eng{line_index}{element_index},'bonaventureDASH_gaspeDASH_ilesDASH_deDASH_laDASH_madeleineDASH_pabok')
%                 disp('******************************************');
%                 disp(eng{line_index}{element_index});
%                 end
                AM.(eng{line_index}{element_index}) = struct();
                storage.(eng{line_index}{element_index}) = {};
            end 
            storage.(eng{line_index}{element_index}) = unique([storage.(eng{line_index}{element_index}), fre{line_index}(2:end-1)]);
%             if strcmp(eng{line_index}{element_index},'bonaventureDASH_gaspeDASH_ilesDASH_deDASH_laDASH_madeleineDASH_pabok')
%             disp(storage.(eng{line_index}{element_index}));
%             end
        end
        
    end
    save('storage.mat', 'storage', '-mat');
    eng_words = fieldnames(storage); 

    for i = 1:numel(eng_words)
%         [fre_word] = unique(storage.(eng_words{i}));
        fre_word = storage.(eng_words{i});
        for index = 1:length(fre_word)
            AM.(eng_words{i}).(fre_word{index}) = 1 / length(fre_word);
        end
    end
    
    AM.SENTSTART = struct();
    AM.SENTEND = struct();
    
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
    save('AM.mat', 'AM', '-mat');

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here
  tcount = struct();
  total = struct();
  
  for sentence_index=1:length(eng)
      disp(sentence_index);
      uni_en = unique(eng{sentence_index});
      uni_fr = unique(fre{sentence_index});
      
      % for each unique word f in F:
      for f_word_index=1:length(uni_fr)
          denom_c = 0;
          
          % Ignore sentence marks
          if strcmp(uni_fr{f_word_index}, 'SENTEND') || strcmp(uni_fr{f_word_index}, 'SENTSTART')
              continue;
          end
          
          % for each unique word e in E:
          for e_word_index = 1:length(uni_en)
              if strcmp(uni_en{e_word_index}, 'SENTEND') || strcmp(uni_en{e_word_index}, 'SENTSTART')
                  continue;
              end
              % denom_c += P(f|e) * F.count(f)
%               disp(uni_en{e_word_index});
%               disp(uni_fr{f_word_index});
%               disp('*******************************');
              denom_c = denom_c + t.(uni_en{e_word_index}).(uni_fr{f_word_index}) * sum(strcmp(fre{sentence_index}, uni_fr{f_word_index}));
          end
          % for each unique word e in E:
          for e_word_index = 1:length(uni_en)
              if strcmp(uni_en{e_word_index}, 'SENTEND') || strcmp(uni_en{e_word_index}, 'SENTSTART')
                  continue;
              end
              if ~isfield(tcount, uni_en{e_word_index})
                  tcount.(uni_en{e_word_index}) = struct();
              end
              if ~isfield(total, uni_en{e_word_index})
                  total.(uni_en{e_word_index}) = 0;
              end
              if ~isfield(tcount.(uni_en{e_word_index}), uni_fr{f_word_index})
                  tcount.(uni_en{e_word_index}).(uni_fr{f_word_index}) = 0;
              end
              
              p_fe = t.(uni_en{e_word_index}).(uni_fr{f_word_index});
              count_f = sum(strcmp(fre{sentence_index},uni_fr{f_word_index}));
              count_e = sum(strcmp(eng{sentence_index},uni_en{e_word_index}));
              
%               x = p_fe * count_f * count_e / denom_c;
              
              % tcount(f, e) += P(f|e) * F.count(f) * E.count(e) / denom_c
              tcount.(uni_en{e_word_index}).(uni_fr{f_word_index}) = tcount.(uni_en{e_word_index}).(uni_fr{f_word_index}) + p_fe*count_f*count_e/denom_c;
              % total(e) += P(f|e) * F.count(f) * E.count(e) / denom_c
              total.(uni_en{e_word_index}) = total.(uni_en{e_word_index}) + p_fe*count_f*count_e/denom_c;
          end
      end
  end
  
  e_fields = fieldnames(total);
  % for each e in domain(total(:))
  for i = 1: length(e_fields)
      
      e_word = e_fields{i};
      f_fields = fieldnames(tcount.(e_word));
      % for each f in domain(tcount(:,e)):
      for j = 1: length(f_fields)
          f_word = f_fields{j};
          % P(f|e) = tcount(f, e) / total(e)
          t.(e_word).(f_word) = tcount.(e_word).(f_word)/total.(e_word);
          
      end
  end
end


