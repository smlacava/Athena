function er=test_error(y_pred, y)
    er=mean(y~=y_pred);
end