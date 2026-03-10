function [outputRange,aggregatedOut,uy_correct,uy_defuzz,w_exp_norm_all,l_w_all]=func_fuzzyfunction(varargin) 
% w_exp: weights of response options (A,B,C, etc.) in the columns, each
% column represents an U or Y variable (size: 5x9)

%% Linguistic responses of wj,P(Zj|Cj),P(Zj) (from Round I. --> F1 table sheet)
%var_id: 1-9, ID of linguistic variables (system outputs and inputs in this
%example):
%'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'

Nxx=201; %number of function points to bring out

%Reading: Real y vs. aggregated linguistic variables in fuzzy form (before IS)
%INFO: Read data from Excel
addpath('D:\Dropbox\KE_AJ_KA\Markov_PF_2024\Kérdőív');
filename = 'Válaszok.xlsx';
sheet = 'F1';
xlRange = 'C2:K11'; %INFO
name_template={'w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)'}; %INFO --> var_id
name_y_F1={2,[2,2],2,3,[3,3],3,1,[1,1],1}; %INFO

var_LB=0; %INFO
var_UB=100; %INFO %var in [0,1]
l_name=["A","B","C","D","E"]; %INFO


ling_y_all=readcell(filename,"Sheet",sheet,"Range",xlRange);
uy_correct=readcell(filename,"Sheet",'F1',"Range",'C12:K12');

%Count the given answers (A,B,C,D,E,..) per questions about y (9 questions, 10 experts)
%--> count_all
count_all=[];
for i=1:length(l_name)
%     eval(sprintf('count_%s=sum(count(ling_y_all,l_name(i)))',l_name(i)));
    count_all=[count_all;sum(count(ling_y_all,l_name(i)))]; %KEINNEN: hiány w_exp nincs még --> argumentumba
end

%Loading optional arguments
w_exp_on=0;
for ii = 1:length(varargin) %IF the weights are caclulated inside this function
    if strcmp('w_exp', varargin{ii}) %binary w_exp
        w_exp_on=varargin{ii+1};
    elseif strcmp('Yk', varargin{ii}) %estimated R at k-th iteration in th outer
        Y_est=varargin{ii+1};
    elseif strcmp('Yid', varargin{ii}) %estimated R at k-th iteration in th outer
        Y_id=varargin{ii+1};
    end
end

%Define MFs of linguistic responses (NOTE: here the same for all Y-s)
Nl=length(l_name);
stepl=(var_UB-var_LB)/(Nl-1);
mf=[];
for i=1:Nl 
ii=var_LB+(i-1)*stepl;
mf = [mf, fismf("trimf",[max(ii-stepl,var_LB) ii min(ii+stepl,var_UB)],"Name",l_name(i))];
end

%Aggregate them by vote ratios
%'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'
w_exp_norm_all=[];
l_w_all=[];
for i=1:size(count_all,2) %INFO
    var_name=sprintf(eval('name_template{i}'),name_y_F1{i});


    w_exp=1/5*ones(5,1);
    if w_exp_on==1 %IF: we would like to weight the experts unevenly
    if ismember(i,Y_id)
        xx=linspace(var_LB,var_UB,Nxx); %HERE: the same for all Y
        [f_est,~] = ksdensity(Y_est(Y_id==i,:),xx) ;
        for exp_id=1:length(l_name) %ID of linguistic responses
            f_exp=evalmf(mf(exp_id),xx)/trapz(xx,evalmf(mf(exp_id),xx)); %before aggregation; convert to so that integral=1
            w_exp(exp_id)=sum(min(f_est,f_exp))/sum(max(f_est,f_exp)); %Jaccard similarity
        end
%         disp(w_exp); %CHECK
    end
    end






    l_w=count_all(:,i).*w_exp./sum(count_all(:,i).*w_exp);
%     l_w=count_all(:,i)/sum(count_all(:,i));

    [fis2]=fuzzy_aggregation(l_name,l_w,var_LB,var_UB,var_name);

    options = evalfisOptions('NumSamplePoints',Nxx); %INFO! %default: 101=Ns; Ns for Aggregatedoutput size
    [uy_defuzz(i),~,~,aggregatedOut(:,i),~] = evalfis(fis2,(var_LB+var_UB)/2,options);
    %output: defuzzified
    outputRange(:,i) = linspace(fis2.output.range(1),fis2.output.range(2),length(aggregatedOut))'; %size=aggregatedOut

w_exp_norm_all=[w_exp_norm_all,w_exp./sum(w_exp)];
l_w_all=[l_w_all,l_w];
end
end
