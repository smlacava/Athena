function [rejected, nonrejected, scrs, predictions] = ...
    update_rejected(dataTest, rejected, reject_value, scrs, predictions)

    reject_ind = 1:length(predictions);
    nonreject_ind = reject_ind;
    reject_ind = reject_ind((scrs(:, 2) < reject_value) .* ...
        (scrs(:, 2) > (1-reject_value)) == 1);
    nonreject_ind(reject_ind) = [];
    
    rejected = [rejected; dataTest.group(reject_ind)];
    nonrejected = dataTest.group(nonreject_ind);
    predictions(reject_ind) = [];
    scrs(reject_ind, :) = [];
end