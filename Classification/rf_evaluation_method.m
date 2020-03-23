%% rf_evaluation_method
% This function returns the evaluation function for the random forest
% classification
%
% eval_function = rf_evaluation_method(method)
%
% input:
%   method is the selected evaluation method's name
%
% output:
%   eval_function is the evaluation function (it is the training-test
%       split method by default)


function eval_function = rf_evaluation_method(method)
    functions = {@rf_train_test_split, @rf_leave_one_out};
    values = {'split', 'leaveoneout'};
    eval_function = @rf_train_test_split;
    for i = 1:length(functions)
        if strcmpi(method, values{i})
            eval_function = functions{i};
            break;
        end
    end
end