%% Tidy up env :)
clear; clc; close all;

%% vars
TotalNjogadas = 50; NMC = 1000000; Ndiscard = 0; % Njogadas > Ndiscard
Njogadas = TotalNjogadas - Ndiscard;
Ncasas = 7; % número de estados

%% Function calls
rand('state',0);

yAll = simplifiedMonopoly(Ncasas, TotalNjogadas, Njogadas, NMC, Ndiscard);
State4(yAll, Njogadas, NMC);

%% Simplified monopoly
function yAll = simplifiedMonopoly(Ncasas,TotalNjogadas,Njogadas,NMC,Ndiscard) %{{{
    % init
    z = zeros(1,Ncasas);                        % número de acessos a cada estado (todas as runs, cumulative)
    yAll = zeros(NMC,Njogadas);                 % estado acedido em cada step (por cada run)
    % sim
    for n = 1:NMC                               %------------------outer loop------------------
        avancos = zeros(1,Njogadas);            % resultados do lançamento da moeda (a cada step)
        x = 0;                                  % var estado atual \in {1,2,3,4,5,6,7}, inicializada a 0 (fora do tabuleiro) a cada run
        
        for m = 1:TotalNjogadas                 %------------------inner loop------------------
            avanca = round(rand(1))+1;          % fair coin flip -> outcome: 1 ou 2
            
            % irreducible Markov chain-> state transitions
            switch x %{{
                case 0 %{
                    if avanca == 1
                        x = 1;
                    else
                        x = 2;
                    end
                %}
                case {1,2,3,4} %{
                    if avanca == 1
                        x = x+1;
                    else 
                        x = x+2;
                    end
                %}
                case 5 %{
                    if avanca == 1
                        x = 6;
                    else
                        x = 3;
                    end
                %}
                case 6 %{
                    if avanca == 1
                        x = 3;
                    else
                        x = 7;
                    end
                %}
                case 7 %{
                    if avanca == 1
                        x = 1;
                    else
                        x = 2;
                    end
                %}
            end %}} END SWITCH

            % burn-in/warm-up
            if (m > Ndiscard)
                avancos(m-Ndiscard) = avanca;
                yAll(n,m-Ndiscard) = x;
                z(x) = z(x) + 1;
            end
        end                                     %------------------inner loop------------------
    end                                         %------------------outer loop------------------
end %}}} END FUNCTION

%% P3 - state 4 frequency plot
function State4(yAll,Njogadas, NMC)

StateFreq = zeros(7,Njogadas);

for m=1:Njogadas
    for n=1:NMC
        aux=yAll(n,m);
        StateFreq(aux,m)=StateFreq(aux,m)+1;
    end
end

probabilityEvolution = StateFreq(4,:)/NMC;

stem(probabilityEvolution, ':.k', 'filled','MarkerSize',15);
yline(0.1591,'Color','r','LineWidth',1.5); xlim([0, 51]);
yticks([0.1591, 0.4]); grid, grid minor;
ylabel('\textbf{Frequ\^encia Relativa de $\mathbf{\textbf{\textit{x}}_4}$}', 'interpreter', 'latex','FontSize', 15); xlabel('\textbf{NJogadas}', 'interpreter', 'latex','FontSize', 15);

end