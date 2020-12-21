function AlgoParamCallback(src,~,Text,textval,addval)
    Text.String = [textval,' = ',num2str(floor(src.Value) + addval)];
end