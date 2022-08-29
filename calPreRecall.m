function [pre_list, recall_list,aupr, aupr1] = calPreRecall(score_list, train_list, test_list)
    score_list = score_list + 0.0001; %keep the zero candidate edges
    %Accuracy=TP+TN/(TP+TN+FP+FN)
    %Precision=TP/(TP+FP)
    %���룬scoreMat, disease��Ӧ������Ȼֵ��train��ӦΪdisease��Ӧ����train,
    %testΪdisease��Ӧ����test
    
    
    score_list = score_list.*~train_list;%only consider candiate edges
    [row, ~, weight] = find(score_list);
    test_label = test_list(row);
    [~, y] = sort(weight,'descend');
    candidate_len = length(weight);
    tnum = nnz(test_list);
    pre_num = 1:candidate_len;
    pre_list = tnum./pre_num;
    recall_list = ones(1,candidate_len);
    correct_rate = 0;
    for j = 1:candidate_len
        if test_list(row(y(j)))>0
            correct_rate = correct_rate + 1;
        end
        recall_list(j)=correct_rate/tnum;
        pre_list(j)=correct_rate/j;
        if correct_rate==tnum
            break;
        end
    end
    
    roc_y = test_list(row(y));
    %% ��x��recall�ĸ����㣬��y��precison�ĸ����㡣��PR���������aupr
    P=[1:length(roc_y)]';   %ʵ��������(TP+FP)��������Ԥ��Ϊ���ĸ�������Ϊ��ֵ���ǽ���������ֵ��Ӧ���±꼴��TP+FP��
    stack_x = cumsum(roc_y == 1)/sum(roc_y == 1); %x�᣺TPR=recall=TP/(TP+FN)=Ԥ��Ϊ��������/��������
    stack_y = cumsum(roc_y == 1)./P; %y�᣺precision=TP/(TP+FP)=Ԥ��Ϊ��������/����Ԥ��Ϊ��
    aupr=sum((stack_x(2:length(roc_y))-stack_x(1:length(roc_y)-1)).*stack_y(2:length(roc_y)));  %PR���������
    aupr1 = trapz(recall_list, pre_list);
end
    