%% Aqui jaz um exemplo sopanoix

% rir é uma matriz com 3 repostas impulsivas na frequencia
% algumas rotinas são necessarias (stat_conf, meanEdB, sep_convert e
% shadederrorbar)

% smooth that signal
% rir1 = ita_smooth(janela_um_segundo.centro{1,1}, 'LogFreqOctave1',1/3,'Abs');
% rir2 = ita_smooth(janela_um_segundo.centro{1,2}, 'LogFreqOctave1',1/3,'Abs');
% rir3 = ita_smooth(janela_um_segundo.centro{1,3}, 'LogFreqOctave1',1/3,'Abs');
%% 
ita_plot_freq(rir1);
%% Plotando a mesma coisa que o plot freq do ita
figure('position', [100 100 1200 600])
semilogx(rir1.freqVector, 20*log10(abs(rir1.freq))); grid on
xlim([20 22050]); ylim([-70 30]);
%%
rir = [rir1.freq, rir2.freq, rir3.freq];
% Valor dentro da função tem que ser absoluto
plot = sopanoix(abs(rir));
