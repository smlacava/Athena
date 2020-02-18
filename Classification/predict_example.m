%% predict_example
% This function predict the class of an example by using a decision tree
%
% answer = predict_example(example, tree)
%
% input:
%   example is the example array to classify
%   tree is the decision tree to use as classifier
%
% output:
%   answer is the resulting class label


function answer = predict_example(example, tree)
    if iscell(tree)
        aux = tree{1};
    else
        aux = tree;
    end
    if iscell(aux)
        aux = aux{1};
    end
    aux = split(aux, " ");
    value = str2double(aux{3});
    
    if example(1) <= value
        answer = tree{2};
    else
        answer = tree{3};
    end
    
    if iscell(answer)
        residual_tree = answer;
        answer = predict_example(example, residual_tree);
    end
        
end

