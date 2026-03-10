function [outputRange,aggregatedOut,r_correct,defuzzi,w_exp_out]=func_intfunction(varargin) 
%Sol-4: aggregation by curve average (trapezoidal fuzzy number with
% bw bandwidth)

%Sol-5: aggregation by alfa-cuts

%% Interval responses of 'p'; F1 [FIGURE]
addpath('D:\Dropbox\KE_AJ_KA\Markov_PF_2024\Kérdőív');
int_r_all=readcell('Válaszok.xlsx',"Sheet",'F1',"Range",'L2:Q11'); %[from to] for three parameters (dtO,dyO,pOK)
r_correct=readcell('Válaszok.xlsx',"Sheet",'F1',"Range",'L12:Q12');

name_p={'$$\Delta t_O$$','$$\Delta y_O$$','$$\hat{\sigma}$$'};
abr=0;

% Arguments??
LB_R=[0,0,0]; %INFO?
UB_R=[30,2,100]; %INFO?
Nxx=2001; %number of function points to bring out; Sol-5: tol=0.001-hez ez kell 20001, amúgy Sol3 pl: 2001

% bandwidth: 50% of the average interval length
bw=[]; 
for i=1:2:5
bw=[bw,0.5*mean(cell2mat(int_r_all(:,i+1))-cell2mat(int_r_all(:,i)))];
end


% % FIGURE
% figure('position',[200 200 1200 400])
% hold on
% for j=1:2:size(int_r_all,2)
% subplot(1,3,(j-1)/2+1)
% for i=1:length(int_r_all(:,j))
%     hold on
%     plot(int_r_all{i,j},i,'.b','Markersize',29)
%     plot(int_r_all{i,j+1},i,'.b','Markersize',29)
%     plot([int_r_all{i,j},int_r_all{i,j+1}],[i,i],'b')
% end
% ylabel('Expert ID [–]')
% xlabel(name_p{(j-1)/2+1},'Interpreter','latex')
% h1=plot([p_correct{j} p_correct{j}],ylim,'DisplayName','Real value')
% end
% legend(h1)



% Creating MFs from intervals ('p',F1) --> aggregated will be here [FIGURE]

if abr==1
figure('position',[200 200 1200 400])
hold on
end

outputRange=[];
aggregatedOut=[];
defuzzi=[];
w_exp_out=[];
for j=1:2:size(int_r_all,2)

 if abr==1
subplot(1,3,(j-1)/2+1)
 end

%Sol-1: What percent of expert intervals contain xx? (Acceptance rate)
%If there is a known possible interval, give it!
xx=linspace(0*min(cell2mat(int_r_all(:,j)))-0.3,1.2*max(cell2mat(int_r_all(:,j+1))),Nxx);
% xx=linspace(0.99*min(cell2mat(int_r_all(:,j))),1.01*max(cell2mat(int_r_all(:,j+1))),Nxx);

% %IF voting ratio WITHOUT bw
% fxx_1=sum(cell2mat(int_r_all(:,j))<=xx & cell2mat(int_r_all(:,j+1))>=xx)/size(int_r_all,1);

%IF WITH bw
mf=[];
for exp_id=1:size(int_r_all,1)
    mf=[mf;evalmf(fismf(@trapmf,[cell2mat(int_r_all(exp_id,j))-bw((j+1)/2),cell2mat(int_r_all(exp_id,j)),cell2mat(int_r_all(exp_id,j+1)),cell2mat(int_r_all(exp_id,j+1))+bw((j+1)/2)]),xx)];
end

%Initialization
w_exp=1/ size(int_r_all,1)*ones(size(int_r_all,1),1); %weight sum is 1 !
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

% % (for Sol-3, and Sol-5)
% %Calculation of expert weights (for Sol-3, and Sol-5)
% if w_exp_on==1 %IF: we would like to weight the experts unevenly
%     if ismember((j+1)/2,R_id) %only for the defined (estimated) ID-s
%         [f_est,~] = ksdensity(R_est,xx) ;
%         for exp_id=1:size(int_r_all,1)
%             f_exp=mf(exp_id,:)/trapz(xx,mf(exp_id,:)); %before aggregation; convert to so that integral=1
%             w_exp(exp_id,1)=sum(min(f_est,f_exp))/sum(max(f_est,f_exp)); %Jaccard similarity
%         end
%     end
%     w_exp=w_exp./sum(w_exp); %normalization %CHECK
%     w_exp_out=[w_exp_out,w_exp];
% end

% fxx_1=sum(w_exp.*mf);
% % end (for Sol-3, and Sol-5)

if abr==1
h3=plot(xx,mean(mf,1),'DisplayName','Acceptance rate');
hold on
end



% %Sol-2: Evaluating only at the boundary points and connect them.
% LB=0.8*min(cell2mat(int_r_all(:,j))); %INFO! the interval we are sure to contain the variable
% UB=1.2*max(cell2mat(int_r_all(:,j+1))); %INFO!
% xx=unique(sort(cell2mat([LB;UB;int_r_all(:,j);int_r_all(:,j+1)])))';
% fxx=sum(cell2mat(int_r_all(:,j))<=xx & cell2mat(int_r_all(:,j+1))>=xx)/size(int_r_all,1);
% plot(xx,fxx)
% hold on

% %Sol-3: Convex functions (considering min and max conditions independently)
% %(Aggregated distribution)
% %e.g., here: alfa-cut is the widest range where possibility=alfa can occur
% 
% %For Sol-3:
% alfa_min=[];
% alfa_max=[];
% for i=unique(fxx_1)
%     alfa_min=[alfa_min,min(xx(fxx_1==i))];
%     alfa_max=[max(xx(fxx_1==i)),alfa_max];
% end
% 
% alfa_all=[alfa_min,alfa_max];
% fxx_1_min=unique(fxx_1) 
% fxx_1_max=flip(unique(fxx_1));
% 
% ii=2;
% while ii<=length(alfa_max)
%     if alfa_max(ii)<alfa_max(ii-1)
%         alfa_max(ii)=[];
%         fxx_1_max(ii)=[];
%     else
%         ii=ii+1;
%     end
% end
% 
% ii=1;
% while ii<=length(alfa_min)-1
%     if alfa_min(ii)>alfa_min(ii+1)
%         alfa_min(ii)=[];
%         fxx_1_min(ii)=[];
%     else
%         ii=ii+1;
%     end
% end
% 
% %If there is not a known possible interval (support of the poss. dist.):
% alfa_min(1)=alfa_min(2);
% alfa_max(end)=alfa_max(end-1);
% 
% h2=plot([alfa_min alfa_max],[fxx_1_min fxx_1_max],'DisplayName','Aggregated distribution')
% hold on
% %end Sol-3

% % %Sol-5: Convex functions, alfa-cuts (considering min and max conditions independently, WITH bandwidth)
% % %(Aggregated distribution)
% % %e.g., here: alfa-cut is the widest range where possibility=alfa can occur
% SET: Nxx=20001 (line18)
% tol=0.0005; %INFO
% alfa_cuts=0:0.001:1;
% xx_1_min=[];
% xx_1_max=[];
% alfa_min=[];
% alfa_max=[];
% for alf=alfa_cuts
%     xx_1_min=[xx_1_min,xx(min(find(abs(fxx_1 - alf) <= tol)))];
%     xx_1_max=[xx_1_max,xx(max(find(abs(fxx_1 - alf) <= tol)))];
%     if ~isempty(find(abs(fxx_1 - alf) <= tol))
%     alfa_min=[alfa_min,alf];
%     alfa_max=[alfa_max,alf];
%     end
%        if alf>max(fxx_1)
%             alfa_min(end)=max(fxx_1);
%     alfa_max(end)=max(fxx_1);
%        end
% 
% end
% if abr==1
% h2=plot([xx_1_min flip(xx_1_max)], [alfa_min  flip(alfa_max)],'DisplayName','Aggregated distribution');
% hold on
% end
% 
% %Interpolation: to have the same elements of each parameter
% xx_int=linspace(0*min(cell2mat(int_r_all(:,j)))-0.3,1.2*max(cell2mat(int_r_all(:,j+1))),2001);
% if numel([xx_1_min flip(xx_1_max)]) ~= numel(unique([xx_1_min flip(xx_1_max)]))
%     xxx=[xx_1_min flip(xx_1_max)];
%     alff=[alfa_min  flip(alfa_max)];
%     [x_uni, ~, idx_uni] = unique(xxx);        % u = unique elements
%     dupVals = (accumarray(idx_uni, 1)>1);    % counts per element
% 
% 
% %     dupVals = xxx(histcounts(xxx, [unique(xxx), inf]) > 1);
%     for dupp=x_uni(dupVals)
%     alff(xxx==dupp)=[];
%     xxx(xxx==dupp)=[]; %így most mindkettőt törli
%     end
%     %alff(xxx==dupVals)=[];
%     mean_mf=interp1(xxx',alff',xx_int);
% else
% mean_mf=interp1([xx_1_min flip(xx_1_max)]',[alfa_min  flip(alfa_max)]',xx_int);
% end
% outputRange=[outputRange,xx_int'];
% aggregatedOut=[aggregatedOut,mean_mf'];
% defuzzi=[defuzzi,defuzz(xx_int',mean_mf','centroid')];
% % end Sol-5



% Sol-4: Giving bandwidth to the responses and sum them up (average of curves)
% SET: Nxx=2001 (line18)

Nxx=2001; %number of function points to bring out
xx_low_plus=0.8;
xx_up_plus=1.2; %extending the space of data

xx=linspace(xx_low_plus*min(cell2mat(int_r_all(:,j))),xx_up_plus*max(cell2mat(int_r_all(:,j+1))),Nxx);
    for i=1:size(int_r_all,1)
    mf(i,:)=trapmf(xx,[int_r_all{i,j}-bw((j+1)/2),int_r_all{i,j},int_r_all{i,j+1},int_r_all{i,j+1}+bw((j+1)/2)]);
    end


%Aggregation; 
w_exp=1/ size(int_r_all,1)*ones(size(int_r_all,1),1); %weight sum is 1 !

if w_exp_on==1 %IF: we would like to weight the experts unevenly
    if ismember((j+1)/2,R_id) %only for the defined (estimated) ID-s
        [f_est,~] = ksdensity(R_est,xx) ;
        for exp_id=1:size(int_r_all,1)
            w_exp(exp_id,1)=func_weighting_experts(xx,mf,exp_id,R_est,'pdf_values',f_est);
%         f_exp=mf(exp_id,:)/trapz(xx,mf(exp_id,:)); %before aggregation; convert to so that integral=1
%         w_exp(exp_id,1)=sum(min(f_est,f_exp))/sum(max(f_est,f_exp)); %Jaccard similarity
        end
    end
    w_exp=w_exp./sum(w_exp); %normalization %CHECK
    w_exp_out=[w_exp_out,w_exp];
end

mean_mf=sum(w_exp.*mf);
outputRange=[outputRange,xx'];
aggregatedOut=[aggregatedOut,mean_mf'];
defuzzi=[defuzzi,defuzz(xx,mean_mf','centroid')];
h2=plot(xx,mean_mf);
%end Sol-4


if abr==1
ylim([0 1])
ylabel('Possibility [–]')
xlabel(name_p{(j-1)/2+1},'Interpreter','latex')
h1=plot([r_correct{j} r_correct{j}],ylim,'DisplayName','Real value','LineWidth',2);
% h4=plot([defuzzi(end) defuzzi(end)],ylim,'r','DisplayName','Defuzzified value','LineWidth',2);
if exist('f_est')
h5=plot(xx,f_est);
end
end

end

% legend([h3,h2,h1])