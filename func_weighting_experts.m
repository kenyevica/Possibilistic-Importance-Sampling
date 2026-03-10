function w_exp=func_weighting_experts(xx,mf,exp_id,R_est,varargin)

%Function for weighting an expert judgment.
% Sol-1: MF is converted to PDF, and compared with the distribution of
%particles using Jaccard-index
% Sol-2: MF-values belonging to the particles are evaluated, and too narrow
% MFs are punished

% Output:
%w_exp: weight of the exp_id-th expert judgment

% Inputs:
% xx: the values where the membership functions (or the ksdensity fit) is
%evaluated
% mf: collects the MF values at xx
% exp_id: the ID of expert the opinion of which is wanted to weighted
% (needed to be able to call the correpsonding data from 'mf')
% R_est: particles of the last iteration of the last inner circle (after
%resampling --> the simple std without weights is correct in Sol-2)
% varargin: pdf values fitted to the particles (R_est) evaluated at xx



for ii = 1:length(varargin) %IF the weights are caclulated inside this function
    if strcmp('pdf_values', varargin{ii}) %pdf_values --> needed for Jaccard -index
        f_est=varargin{ii+1};
    end
end
% 
% % Sol-1: Jaccard-index (fitted pdf)
% f_exp=mf(exp_id,:)/trapz(xx,mf(exp_id,:)); %before aggregation; convert to so that integral=1
% w_exp=sum(min(f_est,f_exp))/sum(max(f_est,f_exp)); %Jaccard similarity

% % Sol-2: Created formula (without fitting pdf)
w_exp=sum(interp1(xx,mf(exp_id,:),R_est),2)/size(R_est,2)/max(std(xx,mf(exp_id,:))/std(R_est),1);