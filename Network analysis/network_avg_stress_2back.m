% written by liangying,9/26/2019
clear;
clc;

load('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\result\fc2_stress.mat');

fc2_stress(isnan(fc2_stress)) = 0;

num = 36;    
avg_FPN = zeros(1,num);     % 预分配内存提高效率
avg_SN = zeros(1,num);
avg_DMN = zeros(1,num);
avg_FPN_DMN = zeros(1,num);
avg_FPN_SN = zeros(1,num);
avg_SN_DMN = zeros(1,num);


for i=1:num
    
    r = fc2_stress(:,:,i);
    
    FPN = r(3:4,3:4); 
    s = (sum(FPN(:)))/2;
    avg_FPN(i) = s/1;
    
    SN = r(5:6,5:6);  
    s = (sum(SN(:)))/2 ;
    avg_SN(i) = s/1;
    
    DMN = r(1:2,1:2);
    s = (sum(DMN(:)))/2;
    avg_DMN(i) = s/1;
    
    FPN_SN = r(3:4,5:6);
    s = sum(FPN_SN(:));
    avg_FPN_SN(i) = s/4;
    
    FPN_DMN = r(3:4,1:2);
    s = sum(FPN_DMN(:));
    avg_FPN_DMN(i) = s/4;
    
    SN_DMN = r(5:6,1:2);
    s = sum(SN_DMN(:));
    avg_SN_DMN(i) = s/4;
    
end

avg_FPN = avg_FPN'
avg_SN = avg_SN'
avg_DMN = avg_DMN'
avg_FPN_SN = avg_FPN_SN'
avg_FPN_DMN = avg_FPN_DMN'
avg_SN_DMN = avg_SN_DMN'
all = [avg_FPN,avg_SN,avg_DMN ,avg_FPN_SN,avg_FPN_DMN,avg_SN_DMN]

    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\avg_FPN.mat', 'avg_FPN'); 
    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\avg_SN.mat', 'avg_SN');
    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\avg_DMN.mat', 'avg_DMN');
    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\avg_FPN_SN.mat', 'avg_FPN_SN');
    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\avg_FPN_DMN.mat', 'avg_FPN_DMN');
    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\avg_SN_DMN.mat', 'avg_SN_DMN');
    save('C:\Users\liuxiaomiao\Desktop\haiyang\RESULT\Network2\stress\result\stress_2back\all.mat','all');

