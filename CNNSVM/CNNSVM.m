clear all;
close all;
clc;

addpath ./data
addpath ./util
addpath ./CNN
addpath ./cnn-model
addpath ./svm

load mnist_uint8.mat;
load epoch10.mat

train_x = double(reshape(train_x',28,28,60000))/255;
test_x = double(reshape(test_x',28,28,10000))/255;
train_y = double(train_y');
test_y = double(test_y');


%% ����cnn�����Ͷ�Ӧ�ı�ǩ
cnn_feature = generate_cnn_feature(cnn, train_x);
cnn_feature = cnn_feature';
cnn_label   = [1:10] * cnn_label;
cnn_label   = cnn_label';
numTrain = 6000;
numTest  = 1000;
numLabels = 10;

trainFeaSel = cnn_feature(1:numTrain,:); 
trainLabelSel = cnn_label(1:numTrain);

model = cell(numLabels,1);
for k=1:numLabels
    disp(strcat('ѵ���׶εĵ�', num2str(k),'�i'));
    trainLabelSelBin=double(trainLabelSel==k);
    model{k} = svmtrain(trainLabelSelBin, trainFeaSel, '-c 1 -g 0.2 -b 1');
end


%% ���ɲ������ݶ�Ӧ��cnn�����Ͷ�Ӧ�ı�ǩ

testFeaSel = generate_cnn_feature(cnn, test_x);
testFeaSel = testFeaSel';
testFeaSel = testFeaSel(1:numTest,:);
testLabelSel   = [1:10] * test_y;
testLabelSel = testLabelSel';
testLabelSel = testLabelSel(1:numTest);
%# get probability estimates of test instances using each model
prob = zeros(numTest,numLabels);
for k=1:numLabels
    disp(strcat('���Խ׶εĵ�', num2str(k),'�i'));
    testLabelSelBin = double(testLabelSel==k);
    [~,~,p] = svmpredict(testLabelSelBin, testFeaSel, model{k}, '-b 1');
    prob(:,k) = p(:,model{k}.Label==1);    %# probability of class==k
end

%% ���ز���׼ȷ�ʺͶ�Ӧ�Ļ�������
[~,pred] = max(prob,[],2);
acc = sum(pred == testLabelSel) ./ numel(testLabelSel)  
C = confusionmat(testLabelSel, pred)                  