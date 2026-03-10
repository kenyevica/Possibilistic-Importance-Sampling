function [outputRange,aggregatedOut,r_correct,defuzzi,w_exp_out]=func_possibfunction_intpair(varargin) 
%w_exp: weights of expert opinions, size: Nexp x (number of R)

%% Interval pair responses of dtO, dyO, sigma (from Round II. --> F2 table sheet)
%var_id: 1-3, ID of parameters (system parameters in this example):
%'dtO','dyO','sigma_hat'

Nxx=2001; %number of function points to bring out
xx_low_plus=0.8;
xx_up_plus=1.2; %extending the space of data

%Read: real and aggregated int. pair responses
addpath('D:\Dropbox\KE_AJ_KA\Markov_PF_2024\Kérdőív');
int_r_all=readcell('Válaszok.xlsx',"Sheet",'F2',"Range",'U2:AF11'); %[from to] for three parameters (dtO,dyO,pOK)
r_correct=readcell('Válaszok.xlsx',"Sheet",'F2',"Range",'U12:AF12');
r_correct=r_correct(1:4:end);

name_r={'$$\Delta t_O$$','$$\Delta y_O$$','$$\hat{\sigma}$$'};


%Creating trapezoidal fuzzy numbers for each responses
mf={};
mf1=[];
for j=1:4:size(int_r_all,2)
xx=linspace(xx_low_plus*min(cell2mat(int_r_all(:,j))),xx_up_plus*max(cell2mat(int_r_all(:,j+1))),Nxx);
mf{(j-1)/4+1}=[];
    for i=1:length(int_r_all(:,j)) %exp_id
    mf{(j-1)/4+1} = [mf{(j-1)/4+1}; fismf(@trapmf,[int_r_all{i,j} int_r_all{i,j+2} int_r_all{i,j+3} int_r_all{i,j+1} ])];
    mf1=[mf1;evalmf(mf{(j-1)/4+1}(i),xx)];
    end
end


%Aggregation; 
w_exp=1/ size(int_r_all,1)*ones(size(int_r_all)); %weight sum is 1 !
w_exp_on=0;
for ii = 1:length(varargin) %IF the weights are caclulated inside this function
    if strcmp('w_exp', varargin{ii}) %binary w_exp
        w_exp_on=varargin{ii+1};
    elseif strcmp('Rk', varargin{ii}) %estimated R at k-th iteration in the outer
        R_est=varargin{ii+1};
    elseif strcmp('Rid', varargin{ii}) %estimated R at k-th iteration in the outer
        R_id=varargin{ii+1};
    end
end

if w_exp_on==1 %IF: we would like to weight the experts unevenly
    for Rid=R_id %only for the defined (estimated) ID-s
        xx=linspace(xx_low_plus*min(cell2mat(int_r_all(:,(Rid-1)*4+1))),xx_up_plus*max(cell2mat(int_r_all(:,(Rid-1)*4+2))),Nxx);
        [f_est,~] = ksdensity(R_est,xx) ;
        for exp_id=1:size(int_r_all,1) %mf1 collects the function values, mf the MFs
            w_exp(exp_id,(Rid-1)*4+1:Rid*4)=func_weighting_experts(xx,mf1,exp_id,R_est,'pdf_values',f_est);
%             f_exp=evalmf(mf{Rid}(exp_id),xx)/trapz(xx,evalmf(mf{Rid}(exp_id),xx)); %before aggregation; convert to so that integral=1
%             w_exp(exp_id,(Rid-1)*4+1:Rid*4)=sum(min(f_est,f_exp))/sum(max(f_est,f_exp)); %Jaccard similarity
        end
    end
    w_exp=w_exp./sum(w_exp); %normalization %CHECK
end
%         for jj=1:size(varargin{ii+1},2) 
%         w_exp = [w_exp,repmat(varargin{ii+1}(:,jj),1,4)]; %final size: Nexp x 12 (4 parameters per R)
%         end

% for ii = 1:length(varargin) %IF the weights are given from outside
%     if strcmp('w_exp', varargin{ii})
%         w_exp=[];
%         for jj=1:size(varargin{ii+1},2) 
%         w_exp = [w_exp,repmat(varargin{ii+1}(:,jj),1,4)]; %final size: Nexp x 12 (4 parameters per R)
%         end
%     end
% end

sum_int_p_all=sum(w_exp.*cell2mat(int_r_all)); %weighted sum

outputRange=[];
aggregatedOut=[];
defuzzi=[];
for i=1:4:size(sum_int_p_all,2)
mean_mf=fismf(@trapmf,[sum_int_p_all(i) sum_int_p_all(i+2) sum_int_p_all(i+3) sum_int_p_all(i+1)]);
xx=linspace(xx_low_plus*min(cell2mat(int_r_all(:,i))),xx_up_plus*max(cell2mat(int_r_all(:,i+1))),Nxx);
outputRange=[outputRange,xx'];
aggregatedOut=[aggregatedOut,evalmf(mean_mf,xx')];
defuzzi=[defuzzi,defuzz(xx,evalmf(mean_mf,xx'),'centroid')];
end
w_exp_out=w_exp(:,1:4:size(sum_int_p_all,2));
end