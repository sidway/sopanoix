function [CI, conf] = stat_conf(input,type,alpha,mu,sigma,axistype,desv,dbref)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fun��o para calcular a regi�o de confian�a.
% 
% Desenvolvido pelo professor da Engenharia Ac�stica 
%                                William D'Andrea Fonseca, Dr. Eng.
%
% �ltima atualiza��o: 04/12/2017
% 
% Compat�vel com Matlab R2016b
%
% input: vetor com as informa��es a serem estimadas.
% type: 'N' para distribui��o normal e 'T' para T-Student.
% alpha: valor da confina�a, e.g., 95 (para 95%).
% mu e sigma: valores de refer�ncia para compara��o com a distribui��o
%             normal (geralmente mu = 0 e sigma = 1).
% axistypoe: 'nodB' para c�lculo em linear
%            'dB20' para c�lculo usando 20*log10(mean -+ CI*sigma/sqrt(L))
%            'dB10' para c�lculo usando 10*log10(mean -+ CI*sigma/sqrt(L))
% desv: 'med' para desvio padr�o da m�dia
%       'conj' para desvio padr�o do conjunto
% dbref: n�mero de refer�ncia para usar no c�lculo de dB 
%
% Exemplo:
% [Amostra.AlphaCI,conf] = stat_conf(Amostra.AlphaData,'N',80,0,1,'nodB','conj');
% [Amostra.AlphaCI,~] = stat_conf(Amostra.AlphaData,'N',90,0,1,'nodB','med');
%  Amostra.AlphaCI = stat_conf(Amostra.AlphaData,'N',90);
%  Amostra.AlphaCI = stat_conf(Amostra.AlphaData,'T',90);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Teste
% clear all; close all
% input = normrnd(0.1583975280,0.026541385465557,10,3); nargin = 1;
%% Processing

if nargin < 1
    error('I need at least the input vector.');
end
if nargin < 8 
    dbref = 1;
end
if nargin < 7 
    desv='med'; dbref = 1;
end
if nargin < 6 
    axistype = 'nodB'; desv='med';
end
if nargin < 4
    mu=0; sigma=1; axistype = 'nodB'; desv='med';
end
if nargin < 3
    alpha = 95; mu=0; sigma=1; axistype = 'nodB'; desv='med';  
end
if nargin < 2
    alpha = 95;	%  Confidence = 95%
    type = 'N'; mu=0; sigma=1; axistype = 'nodB'; desv='med';
    disp('Calcularei o desvio padr�o da m�dia, distr. Normal e CI de 95\%.')
end

%%%%% Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = size(input,1);
a = 1 - alpha/100;

if strcmp(type,'t') || strcmp(type,'T')
   CI.z = tinv([a/2,  1-a/2],L-1);	       % T-Score
   CI.calc.type = 'T-Score'; CI.calc.alpha = alpha; CI.calc.nuDF = L-1;
elseif strcmp(type,'N') || strcmp(type,'n')
   CI.z = norminv([a/2,  1-a/2],mu,sigma); % Normal
   CI.calc.type = 'Normal'; CI.calc.alpha = alpha; 
   CI.calc.muN = mu; CI.calc.sigmaN = sigma;
end

CI.confidence = alpha;
% Mean and standard deviation
CI.meanInput  = mean(input);
CI.sigmaInput = std(input);

% Confidence Intervals
if     strcmp(desv,'med')  % Desvio padr�o da m�dia
  CI.interval(:,1) = CI.z(1)*CI.sigmaInput/sqrt(L);	% Confidence Intervals 
  CI.interval(:,2) = CI.z(2)*CI.sigmaInput/sqrt(L);	% <-'
  CI.confType = 'mean';
elseif strcmp(desv,'conj') % Desvio padr�o do conjunto
  CI.interval(:,1) = CI.z(1)*CI.sigmaInput;	% Confidence Intervals 
  CI.interval(:,2) = CI.z(2)*CI.sigmaInput;	% <-'
  CI.confType = 'sample';  
end

% Mean +/- Standard Error
if strcmp(axistype,'lin') || strcmp(axistype,'nodb') || strcmp(axistype,'nodB')
for i=1:length(CI.meanInput)
  CI.muCI(i,1) = CI.meanInput(1,i) - abs(CI.interval(i,1));
  CI.muCI(i,2) = CI.meanInput(1,i) + abs(CI.interval(i,2));
end
%%%% decibel stuff
elseif strcmp(axistype,'dB20') || strcmp(axistype,'db20') || strcmp(axistype,'DB20') 
    CI.meanInputdB = 20.*log10(mean(input)./dbref);
    % Use 20*log10(mean -+ CI*sigma/sqrt(L))
    for i=1:length(CI.meanInput)
      CI.muCI(i,2) = 20.*log10((CI.meanInput(1,i) + abs(CI.interval(i,2)))./dbref);
      CI.muCI(i,1) = CI.meanInputdB(i) - (CI.muCI(i,2) - CI.meanInputdB(i)'); 
    end
    CI.intervaldB(:,2) = CI.muCI(:,2) - CI.meanInputdB';
    CI.intervaldB(:,1) = -CI.intervaldB(:,2);    
elseif strcmp(axistype,'dB10') || strcmp(axistype,'db10') || strcmp(axistype,'DB10') 
    CI.meanInputdB = 10.*log10(mean(input)./dbref);
    % Use 10*log10(mean -+ CI*sigma/sqrt(L))    
    for i=1:length(CI.meanInput)
      CI.muCI(i,2) = 10.*log10((CI.meanInput(1,i) + abs(CI.interval(i,2)))./dbref);
      CI.muCI(i,1) = CI.meanInputdB(i) - (CI.muCI(i,2) - CI.meanInputdB(i)'); 
    end
    CI.intervaldB(:,2) = CI.muCI(:,2) - CI.meanInputdB';
    CI.intervaldB(:,1) = -CI.intervaldB(:,2);    
end  
    
conf = abs(CI.z(2));

end