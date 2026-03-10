clear all
close all
clc
abr=1;

%% Int. pair 1R, ling. 1Y %-->FIGURE: figure_1
%intpair_id:'dtO','dyO','sigma_hat'
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'

name_template={'w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)'}; %u & y
name_y_F1={2,[2,2],2,3,[3,3],3,1,[1,1],1}; %u & y
name_r={'\Delta t_O [s]','\Delta y_O [m]','$\mathbf{\hat{\sigma}}$ \textsf{[\%]}'}; %'$\hat{\sigma}$ [\%]'}; %r

%KEINNEN: majd: +wexp!
[ling_x,ling_aggrfx,y_correct,uy_defuzz]=func_fuzzyfunction; %x-fx; gaining aggregated discretized function values from linguistic responses
[intpair_x,intpair_aggrfx,r_correct,r_defuzz]=func_possibfunction_intpair;   %x-fx; gaining aggregated discretized function values from interval pair responses

Ns=1000; %INFO, %IS number of particles
LB_R=[0,0,0]; %INFO?
UB_R=[30,2,100]; %INFO?
LB_UY=0; %INFO?
UB_UY=100; %INFO?

results_1P_1Y=[];

for j=[3] %R:[1,2,3]
for i=[2] %Y: [2,3,5,6,8,9]
U_k_id=[]; %INFO, %from ling_id, {1,4,7}; define one or two!(the third is determined by them)
Y_k_id=[i]; %INFO, %from ling_id, {2,3,5,6,8,9}
R_k_id=[j]; %INFO, %from intpair_id, {1,2,3}

%Importance sampling
k_max=20; %INFO
alfa=0.95; %INFO
% [U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY);
% %stopping: k_max
means=[];
R_k_all=cell(0,0);
Y_k_all=cell(0,0);
for ii=1:1
[U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa); %stopping: KS-test
% means=[means;mean(U_k{end},2),mean(R_k{end},2),mean(Y_k{end},2)];
R_k_all=[R_k_all;{R_k}];
Y_k_all=[Y_k_all;{Y_k}];
end
% results_1P_1Y=[results_1P_1Y;[{U_k_id,R_k_id,Y_k_id},num2cell(mean(means,1))]];
results_1P_1Y=[results_1P_1Y;[{R_k_id,Y_k_id},{R_k_all,Y_k_all}]];
end
end


% save('results_1P_1Y_all_10run_v2.mat','results_1P_1Y')

%% Int. pair 1R, ling. multiY %-->NOT CONSECUTIVE, FIGURE: figure_1
%intpair_id:'dtO','dyO','sigma_hat'
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'

name_template={'w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)'}; %u & y
name_y_F1={2,[2,2],2,3,[3,3],3,1,[1,1],1}; %u & y
name_r={'\Delta t_O [s]','\Delta y_O [m]','$\hat{\sigma}$ [%]'}; %r

%KEINNEN: majd: +wexp!
[ling_x,ling_aggrfx,y_correct,uy_defuzz]=func_fuzzyfunction; %x-fx; gaining aggregated discretized function values from linguistic responses
[intpair_x,intpair_aggrfx,r_correct,r_defuzz]=func_possibfunction_intpair;   %x-fx; gaining aggregated discretized function values from interval pair responses

Ns=1000; %INFO, %IS number of particles
LB_R=[0,0,0]; %INFO?
UB_R=[30,2,100]; %INFO?
LB_UY=0; %INFO?
UB_UY=100; %INFO?

results_1P_MY_all=[];
results_1P_MY_Rmean=[];

for j=[1] %R:[1,2,3]
Y_k_all=cell(0,0);
R_k_all=cell(0,0);
Y_list_all=cell(0,0);
meanR_MY=cell(0,0);
varR_MY=cell(0,0);

for ii=1:1 %number of runs
    disp(ii) %CHECK
Y_k_id=[];
Y_list=[2,3,5,6,8,9];
Y_list=Y_list(randperm(length(Y_list)));

% %IF: Sorting by decreasing residuals
% Y_list=[2,3,5,6,8,9];
% [~,uyid_sort]=sort(abs(uy_defuzz-cell2mat(y_correct)),'descend');
% Y_list=uyid_sort(ismember(uyid_sort,Y_list));

% %IF: Sorting by decreasing possibility values
% for jj=1:size(ling_aggrfx,2)
% possib_values(jj)=interp1(ling_x(:,jj),ling_aggrfx(:,jj),y_correct{jj});
% end
% [~,uyid_sort]=sort(possib_values,'ascend');
% Y_list=uyid_sort(ismember(uyid_sort,Y_list))

%IF: Sorting by decreasing std/uncertainty
for i=1:size(ling_aggrfx,2)
    std_UY(i)=std(ling_x(:,i),ling_aggrfx(:,i)); %variance of aggregated Y, in %
end
[~,uyid_sort]=sort(std_UY,'descend')
Y_list=uyid_sort(ismember(uyid_sort,Y_list));



results_MY=[];
for i=1:length(Y_list) % [2,3,5,6,8,9]
U_k_id=[] %INFO, %from ling_id, {1,4,7}; define one or two!(the third is determined by them)
Y_k_id=[Y_k_id, Y_list(i)] %INFO, %from ling_id, {2,3,5,6,8,9}
R_k_id=[j] %INFO, %from intpair_id, {1,2,3}

%KEINNEN TODAY: most megvannak beírva a Y-list (át lehetne esetleg írni
%úgy, hogy a sima esetekbe könynedén átvihető legyen? FONTOS: ugyanazt az Ykid-t bővítsük mindig, hogy látszódjon a javulás)(kövi: eredmények
%gyűjtése)

%Importance sampling
k_max=20; %INFO
alfa=0.95; %INFO
% [U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY);
% %stopping: k_max
means=[];

[U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa); %stopping: KS-test
% results_MY=[results_MY;{mean(U_k{end},2),mean(R_k{end},2),mean(Y_k{end},2),U_k,R_k,Y_k}]; %results by increasing the number of Ys
Y_k_all{ii,i}=Y_k;
R_k_all{ii,i}=R_k;
Y_list_all{ii,i}=Y_k_id;
meanR_MY{ii,i}=mean(R_k{end},2); %results by increasing the number of Ys
varR_MY{ii,i}=std(R_k{end},0,2);
end
end
save(strcat("results_1P_MY_NOT_consecutiveY_sortYstd_R",sprintf('%1.0f',j),"_10run.mat"),'meanR_MY','varR_MY','Y_list_all','R_k_all','Y_k_all')
end

% save("results_1P_MY_NOT_consecutiveY_R",sprintf('%1.0f',j),"_10run.mat",'meanR_MY','varR_MY','Y_list_all','R_k_all','Y_k_all')
% save('results_1P_MY_meansR_and_all_R2_10run_v1.mat','meanR_MY','varR_MY','Y_list_all','R_k_all','Y_k_all')
%KEINNEN
%% Int. pair 1R, ling. multiY  --> CONSECUTIVE Y %-->FIGURE: figure_1
%intpair_id:'dtO','dyO','sigma_hat'
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'

name_template={'w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)'}; %u & y
name_y_F1={2,[2,2],2,3,[3,3],3,1,[1,1],1}; %u & y
name_r={'\Delta t_O [s]','\Delta y_O [m]','$\hat{\sigma}$ [%]'}; %r

%KEINNEN: majd: +wexp!
[ling_x,ling_aggrfx,y_correct,uy_defuzz]=func_fuzzyfunction; %x-fx; gaining aggregated discretized function values from linguistic responses
[intpair_x,intpair_aggrfx,r_correct,r_defuzz]=func_possibfunction_intpair;   %x-fx; gaining aggregated discretized function values from interval pair responses

Ns=1000; %INFO, %IS number of particles
LB_R=[0,0,0]; %INFO?
UB_R=[30,2,100]; %INFO?
LB_UY=0; %INFO?
UB_UY=100; %INFO?

results_1P_MY_all=[];
results_1P_MY_Rmean=[];

for j=[1] %R:[1,2,3] %egyesével menteni
Y_k_all=cell(0,0);
R_k_all=cell(0,0);
w_all_all=cell(0,0);
Y_list_all=cell(0,0);
meanR_MY=cell(0,0);
varR_MY=cell(0,0);

for ii=1:1 %parallel runs
Y_k_id=[];
Y_list=[2,3,5,6,8,9];
Y_list=Y_list(randperm(length(Y_list))); %IF: random sort

%IF: Sorting by decreasing residuals
Y_list=[2,3,5,6,8,9];
[~,uyid_sort]=sort(abs(uy_defuzz-cell2mat(y_correct)),'descend');
Y_list=uyid_sort(ismember(uyid_sort,Y_list))

results_MY=[];
for i=1:length(Y_list) % [2,3,5,6,8,9]
U_k_id=[] %INFO, %from ling_id, {1,4,7}; define one or two!(the third is determined by them)
Y_k_id=[Y_k_id, Y_list(i)] %INFO, %from ling_id, {2,3,5,6,8,9}
R_k_id=[j] %INFO, %from intpair_id, {1,2,3}

%KEINNEN TODAY: most megvannak beírva a Y-list (át lehetne esetleg írni
%úgy, hogy a sima esetekbe könynedén átvihető legyen? FONTOS: ugyanazt az Ykid-t bővítsük mindig, hogy látszódjon a javulás)(kövi: eredmények
%gyűjtése)

%Importance sampling
k_max=50; %INFO
alfa=0.95; %INFO
% [U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY);
% %stopping: k_max
means=[];

if i==1
[U_k,R_k,Y_k,w_pU,w_pR,w_pY,w_all]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa); %stopping: KS-test
else
[U_k,R_k,Y_k,w_pU,w_pR,w_pY,w_all]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa,'Rk',R_k{end},'noise_on',1); %stopping: KS-test
end
% results_MY=[results_MY;{mean(U_k{end},2),mean(R_k{end},2),mean(Y_k{end},2),U_k,R_k,Y_k}]; %results by increasing the number of Ys
Y_k_all{ii,i}=Y_k;
R_k_all{ii,i}=R_k;
w_all_all{ii,i}=w_all;
Y_list_all{ii,i}=Y_k_id;
meanR_MY{ii,i}=mean(R_k{end},2); %results by increasing the number of Ys
varR_MY{ii,i}=std(R_k{end},0,2);
end
end
end


% save('results_1P_MY_meansR_and_all_R1_10run_v1.mat','meanR_MY','varR_MY','Y_list_all','R_k_all','Y_k_all')
% save('results_1P_MY_consecutiveY_noise_R1_10run_v3.mat','meanR_MY','varR_MY','Y_list_all','R_k_all','Y_k_all','w_all_all')
%KEINNEN

%% OUTER CIRCLE (w_exp): Int. pair 1R, ling. 1Y %-->FIGURE: figure_1
%intpair_id:'dtO','dyO','sigma_hat'
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'

clear all
% close all

name_template={'w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)'}; %u & y
name_y_F1={2,[2,2],2,3,[3,3],3,1,[1,1],1}; %u & y
name_r={'\Delta t_O [s]','\Delta y_O [m]','$\mathbf{\hat{\sigma}}$ \textsf{[\%]}'}; %'$\hat{\sigma}$ [\%]'}; %r

Ns=1000; %INFO, %IS number of particles
LB_R=[0,0,0]; %INFO?
UB_R=[30,2,100]; %INFO?
LB_UY=0; %INFO?
UB_UY=100; %INFO?

results_1P_1Y=[];

for j=[1] %R:[1,2,3]
for i=[2,3,5,6,8,9] %Y: [2,3,5,6,8,9]
U_k_id=[] %INFO, %from ling_id, {1,4,7}; define one or two!(the third is determined by them)
Y_k_id=[i] %INFO, %from ling_id, {2,3,5,6,8,9}
R_k_id=[j] %INFO, %from intpair_id, {1,2,3}

%Importance sampling
k_max=20; %INFO (only have an effect if noise_on==1
alfa=0.95; %INFO
% [U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY);
% %stopping: k_max
means=[];

results_1P_1Y_outer=cell(0,0); %save: parallel runs with wexp for one 1R1Y
for ii=1:1 %runs parallel
disp(sprintf('runs of outer=%2.0f',ii))
R_k_all=cell(0,0);
Y_k_all=cell(0,0);

for jj=1:10 %Nruns in the OUTER circle
disp(sprintf('runs in the outer=%2.0f',jj))

%     [intpair_estfx_k,~] = ksdensity(R_k{end},intpair_x(:,R_k_id))

if jj==1
    [intpair_x,intpair_aggrfx,r_correct,r_defuzz,w_exp_R]=func_possibfunction_intpair;   %x-fx; gaining aggregated discretized function values from interval pair responses
    [ling_x,ling_aggrfx,y_correct,uy_defuzz,w_exp_norm_all,l_w_all]=func_fuzzyfunction; %x-fx; gaining aggregated discretized function values from linguistic responses
else
    [intpair_x,intpair_aggrfx,r_correct,r_defuzz,w_exp_R]=func_possibfunction_intpair('w_exp',1,'Rk',R_k{end},'Rid',R_k_id);   %x-fx; gaining aggregated discretized function values from interval pair responses
    [ling_x,ling_aggrfx,y_correct,uy_defuzz,w_exp_norm_all,l_w_all]=func_fuzzyfunction('w_exp',1,'Yk',Y_k{end},'Yid',Y_k_id);
end

[U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa); %stopping: KS-test
R_k_all=[R_k_all;{R_k,w_exp_R}];
Y_k_all=[Y_k_all;{Y_k,w_exp_norm_all,l_w_all}];

disp(mean(R_k{end})) %CHECK
end
results_1P_1Y_outer=[results_1P_1Y_outer;{R_k_all,Y_k_all}]; %save after every iteration of the outer circle (number of jj)
end
results_1P_1Y=[results_1P_1Y;[{R_k_id,Y_k_id},{results_1P_1Y_outer(:,1),results_1P_1Y_outer(:,2)}]];

end
end


save('results_1Rintpair_1Yling_R1_all_wexpRYnew_10outer_1run_v0.mat','results_1P_1Y')
%KEINNEN
%% OUTER CIRCLE (w_exp): Int. 1R, ling. 1Y  %-->FIGURE: figure_1
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'
name_p={'$$\Delta t_O$$','$$\Delta y_O$$','$$\hat{\sigma}$$'};

[int_x,int_aggrfx]=func_intfunction; %x-fx; gaining aggregated discretized function values

Ns=1000; %INFO, %IS number of particles
LB_R=[0,0,0]; %INFO?
UB_R=[30,2,100]; %INFO?
LB_UY=0; %INFO?
UB_UY=100; %INFO?

results_1P_1Y=[];

for j=[3] %R:[1,2,3]
for i=[2,3,5,6,8,9] %Y: [2,3,5,6,8,9]
U_k_id=[] %INFO, %from ling_id, {1,4,7}; define one or two!(the third is determined by them)
Y_k_id=[i] %INFO, %from ling_id, {2,3,5,6,8,9}
R_k_id=[j] %INFO, %from intpair_id, {1,2,3}

%Importance sampling
k_max=20; %INFO (only have an effect if noise_on==1)
alfa=0.95; %INFO
% [U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY);
% %stopping: k_max
means=[];

results_1P_1Y_outer=cell(0,0); %save: parallel runs with wexp for one 1R1Y
for ii=1:1 %runs parallel
disp(sprintf('runs of outer=%2.0f',ii))
R_k_all=cell(0,0);
Y_k_all=cell(0,0);

for jj=1:5 %INFO: Nruns in the OUTER circle
disp(sprintf('runs in the outer=%2.0f',jj))

%     [intpair_estfx_k,~] = ksdensity(R_k{end},intpair_x(:,R_k_id))

if jj==1
    [int_x,int_aggrfx,r_correct,r_defuzz,w_exp_R]=func_intfunction;   %x-fx; gaining aggregated discretized function values from interval responses
    [ling_x,ling_aggrfx,y_correct,uy_defuzz,w_exp_norm_all,l_w_all]=func_fuzzyfunction; %x-fx; gaining aggregated discretized function values from linguistic responses
else
    [int_x,int_aggrfx,r_correct,r_defuzz,w_exp_R]=func_intfunction('w_exp',1,'Rk',R_k{end},'Rid',R_k_id);   %x-fx; gaining aggregated discretized function values from interval pair responses
    [ling_x,ling_aggrfx,y_correct,uy_defuzz,w_exp_norm_all,l_w_all]=func_fuzzyfunction('w_exp',1,'Yk',Y_k{end},'Yid',Y_k_id);
end

[U_k,R_k,Y_k,w_pU,w_pR,w_pY]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,int_x,int_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa); %stopping: KS-test
R_k_all=[R_k_all;{R_k,w_exp_R}];
Y_k_all=[Y_k_all;{Y_k,w_exp_norm_all,l_w_all}];

disp(mean(R_k{end})) %CHECK
end
results_1P_1Y_outer=[results_1P_1Y_outer;{R_k_all,Y_k_all}]; %save after every iteration of the outer circle (number of jj)
end
results_1P_1Y=[results_1P_1Y;[{R_k_id,Y_k_id},{results_1P_1Y_outer(:,1),results_1P_1Y_outer(:,2)}]];

end
end


% save('results_1Rint_1Yling_R1_all_wexpRY_Sol4_5outer_1run_v0.mat','results_1P_1Y')


%% Int?
% %KEINNEN
% 
% % %practise: plot
% % ling_id=7
% % aggr2=interp1(ling_x(:,ling_id),ling_aggrfx(:,ling_id),[10,15.01,23,70.0005]);
% % figure
% % plot(ling_x(:,ling_id),ling_aggrfx(:,ling_id),'-',[10,15.01,23,70.0005],aggr2,'o')
% 
% 
% Ns=1000; %INFO, %IS number of particles
% U_k_id=[]; %INFO, %from ling_id, {1,4,7}
% R_k_id=[3]; %INFO; %from int_id, {1,2,3}
% Y_k_id=[5]; %INFO, %from ling_id, {2,3,5,6,8,9}
% 
% %Creating inputs (or parameters)
% U_k{1}=min(ling_x(:,U_k_id))'+rand(1,Ns).*max(ling_x(:,U_k_id))';
% 
% for k=1:2
% 
% %Creating inputs's weights
% w_pU{k}=interp1(ling_x(:,U_k_id),ling_aggrfx(:,U_k_id),U_k{k}); %eddig OK
% 
% %Calculating system output(s) (y=Y_k)
% for i=1:length(U_k{k})
% 
% %INFO def.U
% w_feed(1)=U_k{k}(i)/100; %percent to ratio
% w_feed(2:3)=(1-w_feed(1))*w_feed(2:3)/(w_feed(2)+w_feed(3)); %KEINNEN: hogy meglegyen az 1 összegnek, másik 2 komponens arányát fixen tartjuk
% [S0_C,out,Ak]=func_markov_v8(w_feed,sigma_cap,dtO,dyO,Nc);
% 
% pZj=func_out_to_Y(out,S0_C,Nc,w_feed);
% % [pZj,pCi_Zj]=func_out_to_Y(out,S0_C,Nc,w_feed);
% 
% %INFO def. Y
% Y_k{k}(i)=pZj(end,2)*100; %to %
% end
% 
% %Weighting based on expert-based output(s) 
% w_pY{k}=interp1(ling_x(:,Y_k_id),ling_aggrfx(:,Y_k_id),Y_k{k}); %eddig OK
% 
% w_all{k}=min(w_pU{k},w_pY{k}); %weights based on the possibility of U AND Y
% qx{k}=ksdensity(Y_k{k},Y_k{k}); %importance sampling (le kell osztani?)
% w_all_qx{k}=w_all{k}./qx{k}; %importance weights (/qx)
% 
% [U_k{k+1}]=resample(U_k{k},w_all_qx{k},'multinomial_resampling'); %def. the weights type you want to use
% end

%% figure_1
%Histogram
% figure;
% bins=15;
% subplot(2,1,1);histogram(U_k{k},bins);xlabel('U')
% subplot(2,1,2);histogram(Y_k{k},bins);xlabel('Y')


%FIGURE: Empirical pdf with its mean at the k-th iteration
if abr==1
fig=figure;
k_list=1:1:length(Y_k);
for k=k_list %which iteration is wanted to see
Nsub=length(U_k_id)+length(R_k_id)+length(Y_k_id);
for j=1:size(U_k{k},1)
subplot(Nsub,1,j);hold on;ksdensity(U_k{k}(j,:));xlabel(sprintf(strcat('U=',eval('name_template{U_k_id(j)}','[%%]')),name_y_F1{U_k_id(j)})),ylabel('pdf [-]');xlim([0 100])
legend(sprintf('mean=%2.2f',mean(U_k{k}(j,:))))
end
for j=1:length(R_k_id)
    if R_k_id(j)==3
        subplot(Nsub,1,j+size(U_k{k},1));hold on;ksdensity(R_k{k}(j,:));xlabel(strcat('\textsf{R=}','$\mathbf{\hat{\sigma}}$','\textsf{ [\%]}'),'interpreter','latex'),ylabel('pdf [-]');xlim([0 100])
    else
        subplot(Nsub,1,j+size(U_k{k},1));hold on;ksdensity(R_k{k}(j,:));xlabel(strcat('R=',name_r{R_k_id(j)}),'interpreter','tex'),ylabel('pdf [-]');xlim([0 100])
    end
xlim([LB_R(R_k_id(j)) UB_R(R_k_id(j))])
legend(sprintf('mean=%2.2f',mean(R_k{k}(j,:))))
end
for j=1:size(Y_k{k},1)
subplot(Nsub,1,j+size(U_k{k},1)+size(R_k{k},1));hold on;ksdensity(Y_k{k}(j,:));xlabel(sprintf(strcat('Y=',eval('name_template{Y_k_id(j)}'),' [%%]'),name_y_F1{Y_k_id(j)}));ylabel('pdf [-]');xlim([0 100])
legend(sprintf('mean=%2.2f',mean(Y_k{k}(j,:))))
end
end

% Create discrete colorbar
a=1:length(k_list);
map = flipud(copper(length(a)));
colororder(flipud(copper(length(k_list))));

h = axes(fig,'visible','off'); 
h.Title.Visible = 'on';
h.XLabel.Visible = 'on';
h.YLabel.Visible = 'on';
colormap(map)
% hh = colorbar;
% tk = linspace(0,1,2*length(a)+1);
% %set(hh, 'YTick',tk(2:2:end),'YTickLabel', a','Position',[0.93 0.168 0.022 0.7]);
% set(hh, 'YTick',tk(2:2:end),'YTickLabel', a','Position',[0.93 0.168 0.022 0.7]);
% hh.Label.String = 'Iteration number in the outer circle';
% pos=get(hh,'Position');
% pos(1)=pos(1)-0.035;
% set(hh,'Position',pos);
end 

%% FIGURE: Convergence of the means along iterations

figure
hold on;
Nsub=min(length(U_k_id),1)+length(R_k_id)+1;
it_init=1;

if ~isempty(U_k_id)
subplot(Nsub,1,1)
hold on;
xi=it_init:length(U_k)-1; %k: iteration number
yi=[]; %mean of the particles
for k=xi
yi=[yi,mean(U_k{k},2)];
end
for j=1:size(yi,1) %j-th variable
plot(xi-1,yi(j,:),DisplayName=sprintf(strcat(eval('name_template{U_k_id(j)}'),' [%%]'),name_y_F1{U_k_id(j)}))
plot([0 length(Y_k)-1],[y_correct{U_k_id(j)} y_correct{U_k_id(j)}],'k--','HandleVisibility','off')
end
xlabel('Iteration number [-]')
% ylabel(sprintf(strcat('U=',eval('name_template{U_k_id(j)}'),'[%%]'),name_y_F1{U_k_id(j)}))
ylabel('U [%]')
legend()
end

if ~isempty(R_k_id)
for i=length(U_k_id)+1:Nsub-1
subplot(Nsub,1,i)
hold on;
xi=it_init:length(R_k)-1; %k: iteration number
yi=[]; %mean of the particles
for k=xi
yi=[yi,mean(R_k{k},2)];
end
for j=1:length(R_k_id) %j-th variable
plot(xi-1,yi(j,:))
plot([0 length(Y_k)-1],[r_correct{R_k_id(j)} r_correct{R_k_id(j)}],'k--','HandleVisibility','off')
end
xlabel('Iteration number [-]')
% ylabel(sprintf(strcat('U=',eval('name_template{U_k_id(j)}'),'[%%]'),name_y_F1{U_k_id(j)}))
if R_k_id(j)==3
    ip='latex';
else
    ip='tex';
end
ylabel(name_r{R_k_id(j)},'Interpreter',ip)
% legend()
end
end

subplot(Nsub,1,Nsub)
hold on;
xi=it_init:length(Y_k); %k: iteration number
yi=[]; %mean of the particles
for k=xi
yi=[yi,mean(Y_k{k},2)];
end
for j=1:size(yi,1) %j-th variable
plot(xi-1,yi(j,:),DisplayName=sprintf(strcat(eval('name_template{Y_k_id(j)}'),' [%%]'),name_y_F1{Y_k_id(j)})) %U_k{1} is the initial (zero-th) element
plot([0 length(Y_k)-1],[y_correct{Y_k_id(j)} y_correct{Y_k_id(j)}],'k--','HandleVisibility','off')
end
xlabel('Iteration number [-]')
ylabel('Y [%]')
% ylabel(sprintf(strcat('Y=',eval('name_template{Y_k_id(j)}'),'[%%]'),name_y_F1{Y_k_id(j)}));
legend()



%FIGURE: Convergence of the particle distribution along iterations
%KEINNEN

%% Other FIGURES:
%FIGURE: U-wU,Y-wY,U-wY,U-w_all(=min(wY,wU))
if abr==0  
k=10
for j=1:length(U_k_id)
uk_plot=U_k{k}(j,:); %j refers to the variables
yk_plot=Y_k{k}; %there is only one Y yet; i refers to the variables

figure;
Nsub=4;
subplot(Nsub,1,1);plot(uk_plot,w_pU{k},'*');xlim([0 100])
xlabel(sprintf(strcat('U=',eval('name_template{U_k_id(j)}')),name_y_F1{U_k_id(j)}));ylabel('w_U')
subplot(Nsub,1,2);plot(yk_plot,w_pY{k},'*');xlim([0 100])
xlabel(sprintf(strcat('Y=',eval('name_template{Y_k_id}')),name_y_F1{Y_k_id}));ylabel('w_Y')
subplot(Nsub,1,3);plot(uk_plot,w_pY{k},'*');xlim([0 100])
xlabel(sprintf(strcat('U=',eval('name_template{U_k_id(j)}')),name_y_F1{U_k_id(j)}));ylabel('w_Y')
subplot(Nsub,1,4);plot(uk_plot,w_all{k},'*');xlim([0 100])
xlabel(sprintf(strcat('U=',eval('name_template{U_k_id(j)}')),name_y_F1{U_k_id(j)}));ylabel('min(w_U,w_Y)')
end
end



