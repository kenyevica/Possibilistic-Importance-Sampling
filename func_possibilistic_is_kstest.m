function [U_k,R_k,Y_k,w_pU,w_pR,w_pY,w_all]=func_possibilistic_is_kstest(U_k_id,R_k_id,Y_k_id,Ns,k_max,ling_x,ling_aggrfx,intpair_x,intpair_aggrfx,LB_R,UB_R,LB_UY,UB_UY,alfa,varargin)
%intpair_id:'dtO','dyO','sigma_hat'
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'
name_template={'w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)','w_%1.0f','P(C_%1.0f|Z_%1.0f)','P(Z_%1.0f)'}; %u & y
name_y_F1={2,[2,2],2,3,[3,3],3,1,[1,1],1}; %u & y
name_r={'\Delta t_O [s]','\Delta y_O [m]','$\hat{\sigma}$ [%]'}; %r

% "Real" parameters of the Markov model --> only the ones defined in the ID
% variables will be changed during IS, and the others are considered known
w_feed_0=[0.066 0.654 0.28]; %INFO?
dtO_0=3.5; %s %INFO?
dyO_0=0.7; %m %INFO?
sigma_cap_0=0.6653; %Chance of a successfull operator action (w*pOK) %INFO?
Nc=3;

dtO=dtO_0;
dyO=dyO_0;
sigma_cap=sigma_cap_0;

% % % DEFAULT: %KEVAR
%Sampling inputs and/or parameters
U_k{1}=[];
if ~isempty(U_k_id)
    U_k{1}=min(ling_x(:,U_k_id))'+rand(1,Ns).*(max(ling_x(:,U_k_id))'-min(ling_x(:,U_k_id))');
    U_k{1}=LB_UY+rand(1,Ns).*(UB_UY-LB_UY);
    for j=2:length(U_k_id)
    U_k{1}(j,:)=min(ling_x(:,U_k_id(j)))'+rand(1,Ns).*(100-sum(U_k{1}(1:j-1,:),1));
    end
%Note: their sum could not be greater than 1
end

R_k{1}=[];
if ~isempty(R_k_id)
    for j=1:length(R_k_id)
        R_k{1}=LB_R(R_k_id)'+rand(length(R_k_id),Ns).*(UB_R(R_k_id)'-LB_R(R_k_id)');
    end
end
noise_on=0; %noise for the resampling: ON: 1; OFF: 0

% Optionals %KEVAR
for ii = 1:length(varargin)
    if strcmp('Uk', varargin{ii})
        U_k{1} = varargin{ii+1};
    elseif strcmp('Rk', varargin{ii})
        R_k{1} = varargin{ii+1};
    elseif strcmp('noise_on', varargin{ii})
        noise_on=varargin{ii+1};
    end
end



%Importance sampling
HH=1;
k=1;
while HH>0

%Creating inputs's weights (from linguistic)
w_pU{k}=[];
for j=U_k_id
w_pU{k}(U_k_id==j,:)=interp1(ling_x(:,j),ling_aggrfx(:,j),U_k{k}(U_k_id==j,:)); 
end
%Creating parameter's weights (from interval pair)
w_pR{k}=[];
for j=R_k_id
w_pR{k}(R_k_id==j,:)=interp1(intpair_x(:,j),intpair_aggrfx(:,j),R_k{k}(R_k_id==j,:)); 
end
w_pR{k}(isnan(w_pR{k}))=0; %wR is NaN, if its outside the interpolation limits (based on range of expert opinion's)

%Calculating system output(s) (y=Y_k)
for i=1:Ns %length(U_k{k})

% Define U / estimable w input variables (does not matter the length of U_k_id, it automatically replaces the relevant values)
w_feed=w_feed_0; 
if U_k_id>0
id_change=[name_y_F1{U_k_id}];
w_feed(id_change)=U_k{k}(:,i)/100;
id_keep=~ismember(1:length(w_feed),id_change);
w_feed(id_keep)=(1-sum(w_feed(id_change)))*(w_feed(id_keep)/sum(w_feed(id_keep)));
% Note: 
% -IF length(Ukid)=1 --> the ratio of the other two 'w' variables are fixed 
% -IF length(Ukid)=2 --> the third 'w' is calculated as sum(w)=1
end

%Define R
dtO=dtO_0;
dyO=dyO_0;
sigma_cap=sigma_cap_0;
var_r={'dtO','dyO','sigma_cap'};
if R_k_id>0
    for j=R_k_id
        if j==3 %sigma_cap; percent...
        eval(strcat(var_r{j},'=',"R_k{k}(R_k_id==j,i)'./100;"));
        else
        eval(strcat(var_r{j},'=',"R_k{k}(R_k_id==j,i)';"));
        end
    end
end

[S0_C,out,Ak]=func_markov_v8(w_feed,sigma_cap,dtO,dyO,Nc);
[pZj,pCi_Zj]=func_out_to_Y(out,S0_C,Nc,w_feed);

%Definition of Y
%ling_id:'w_2','P(C_2|Z_2)','P(Z_2)','w_3','P(C_3|Z_3)','P(Z_3)','w_1','P(C_1|Z_1)','P(Z_1)'
Y_k_template={'-100','pCi_Zj{2}(end,2)','pZj(end,2)','-100','pCi_Zj{3}(end,3)','pZj(end,3)','-100','pCi_Zj{1}(end,1)','pZj(end,1)'}; %pCi_Zj{i}(:,j)
    %     Y_k{k}(i)=pZj(end,2)*100 %safety
if ~isempty(U_k_id)
    if sum(U_k{k}(:,i))<=100
        for jj=Y_k_id
        Y_k{k}(Y_k_id==jj,i)=eval(Y_k_template{jj})*100; %to %
        end
    else %sum of feed component ratios>100% (impossible practically)
        for jj=Y_k_id
        Y_k{k}(Y_k_id==jj,i)=-100;
        end
    end
else
    for jj=Y_k_id
    Y_k{k}(Y_k_id==jj,i)=eval(Y_k_template{jj})*100; %to %
    end
end
end

%Weighting based on expert-based output(s) 
for j=Y_k_id
w_pY{k}(Y_k_id==j,:)=interp1(ling_x(:,j),ling_aggrfx(:,j),Y_k{k}(Y_k_id==j,:)); 
if ~isempty(U_k_id)   
w_pY{k}(Y_k_id==j,sum(U_k{k})>100)=0; %problem specific condition
end
end
w_pY{k}(isnan(w_pY{k}))=0; %wY is NaN, if its outside the interpolation limits (based on range of expert opinion's)

w_all{k}=min([w_pU{k};w_pR{k};w_pY{k}]); %weights based on the possibility of U AND P AND Y
%Note: no /qx, see in the article

%KS test for stopping criterion

if k>2
    HHH=[];
for j=1:length(U_k_id)
    HHH=[HHH,kstest2(U_k{end}(j,:),U_k{end-1}(j,:),'alpha',alfa)];
end

for j=1:length(R_k_id)
    HHH=[HHH,kstest2(R_k{end}(j,:),R_k{end-1}(j,:),'alpha',alfa)];
end

for j=1:length(Y_k_id)
    HHH=[HHH,kstest2(Y_k{end}(j,:),Y_k{end-1}(j,:),'alpha',alfa)];
end
HH=sum(HHH); %check

%Extra condition to stop by reaching a certain iteration number (IF
%noise=ON, convergence is not good in cas eof multiple Y)
if noise_on==1
    if k>k_max
        HH=0;
    end
end
end




%Resampling

U_k{k+1}=[];
if ~isempty(U_k_id)
for j=1:length(U_k_id)
[U_k{k+1}(j,:)]=resample(U_k{k}(j,:),w_all{k},'multinomial_resampling'); %U
end
end


%ERROR search
if sum(w_all{k})<=0
    disp('ERROR')
end

R_k{k+1}=[];
% noise_R=(rand(size(R_k{k}))-0.5).*2.*std(R_k{k},0,2)/2.*noise_on; %noise based on std of current sample

% !!! KEFIXED égetett érték!
std_noise_R=[1;0.1;4]; %--> so that particles be able to move 
noise_R=(rand(size(R_k{k}))-0.5).*2.*std_noise_R(R_k_id).*noise_on; %noise based on fix value %KEFIXED ÉGETETT ÉRTÉK
if ~isempty(R_k_id)
for j=1:length(R_k_id)
[R_k{k+1}(j,:)]=resample(R_k{k}(j,:)+noise_R(j,:),w_all{k},'multinomial_resampling'); %P
end
end
k=k+1;
end 
end


%% FUNCTIONS
function [pZj,pCi_Zj]=func_out_to_Y(out,S0_C,Nc,w) %calculating the state probabilities
%pCi_Zj{i}: p(C_i|Z_j) (C_i is fixed --> sum is not 1 in one cell!
pZj=zeros(Nc,size([S0_C{1}(1),out{1}(1,:)]'*w(1),1))';
for jj=1:Nc %all class sum p(Zj AND Ci) to get all p(Zj)
    for j=1:Nc %Zj
       pZj(:,j)=pZj(:,j)+[S0_C{jj}(j),out{jj}(j,:)]'*w(jj); %besorolni a megfelelő Zj-hez, aztán jön a kövei jj class
    end
end
for i =1:Nc
pCi_Zj{i}=[S0_C{i},out{i}]'*w(i)./pZj;
end
end

function [xk, wk, idx] = resample(xk, wk, resampling_strategy)
Ns = length(wk);  % Ns = number of particles
wk = wk./sum(wk); % normalize weight vector 
switch resampling_strategy
   case 'multinomial_resampling'
      with_replacement = true;
      idx = randsample(1:Ns, Ns, with_replacement, wk);

%{
      %THIS IS EQUIVALENT TO:
      edges = min([0 cumsum(wk)'],1); % protect against accumulated round-off
      edges(end) = 1;                 % get the upper edge exact
      % this works like the inverse of the empirical distribution and returns
      % the interval where the sample is to be found
      [~, idx] = histc(rand(Ns,1), edges);
%}

   case 'systematic_resampling'
      % this is performing latin hypercube sampling on wk
      edges = min([0 cumsum(wk)'],1); % protect against accumulated round-off
      edges(end) = 1;                 % get the upper edge exact
      u1 = rand/Ns;
      % this works like the inverse of the empirical distribution and returns
      % the interval where the sample is to be found
      [~, idx] = histc(u1:1/Ns:1, edges);
   % case 'regularized_pf'      TO BE IMPLEMENTED

   % case 'stratified_sampling' TO BE IMPLEMENTED
   % case 'residual_sampling'   TO BE IMPLEMENTED
   otherwise
      error('Resampling strategy not implemented')
end;
xk = xk(:,idx);                    % extract new particles
wk = repmat(1/Ns, 1, Ns);          % now all particles have the same weight
return;  % bye, bye!!!
end