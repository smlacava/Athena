function accuracy = accuracy(predicted, labels)
    accuracy = sum(predicted == labels)/length(predicted);
end

