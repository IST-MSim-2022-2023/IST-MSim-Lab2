%% Tidy up env :)
clear; clc; close all;

%% vars
TotalNjogadas = 200; NMC = 100; Ndiscard = 20; % Njogadas > Ndiscard
Njogadas = TotalNjogadas - Ndiscard;
Ncasas = 7; % número de estados

Aluguer = [10, 10, 0, 15, 20, 25, 35];

%% Function calls
tic;
% monopólio simplificado
z = simplifiedMonopoly(Ncasas, TotalNjogadas, Njogadas, NMC, Ndiscard);
% plot after runs
zfreq = z./(NMC*(Njogadas));
plotP1b(zfreq); % NOTA: comentar yticks para número baixo de jogadas
plotP1c(zfreq,Aluguer); % NOTA: comentar yticks para número baixo de jogadas
% theoric steady-state/equilibrium probability vector
printSteadyStateVector(zfreq);
toc;

%% Simplified monopoly
function z = simplifiedMonopoly(Ncasas,TotalNjogadas, Njogadas,NMC,Ndiscard) %{{{
    hh = waitbar(0);
    % init
    rand('state',0);
    z = zeros(1,Ncasas);                        % número de acessos a cada estado (todas as runs, cumulative)
    % sim
    for n = 1:NMC                               %------------------outer loop------------------
        y = zeros(1,Njogadas);                  % estado acedido em cada step (por cada run)
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
                y(m-Ndiscard) = x;
                z(x) = z(x) + 1;
            end
        end                                     %------------------inner loop------------------
        
        %plotP1a(avancos, y); %NOTA: só é legível para Njogadas baixos, comentar otherwise
        hh = waitbar(n*m/(NMC*TotalNjogadas));
    end                                         %------------------outer loop------------------
    close(hh);
end %}}} END FUNCTION

%% P1a - 
function plotP1a(avancos, y) %{{{
    figure(); 

    subplot(1,2,1); 
    bar(avancos,'FaceColor','#FFB703'); grid, grid minor;
    xlabel('\textbf{\#Jogada}','Interpreter','latex',FontSize=16);
    ylabel('\textbf{Lan\c{c}amento da moeda}','Interpreter','latex',FontSize=16);
    yticks([1,2]); ylim([0,2.05]);

    subplot(1,2,2); 
    bar(y,'FaceColor','#219EBC'); grid, grid minor;
    xlabel('\textbf{\#Jogada}','Interpreter','latex',FontSize=16,Color='k');
    ylabel('\textbf{Estado}','Interpreter','latex',FontSize=16,Color='k');
    yticks([1,2,3,4,5,6,7]); ylim([0, 7.175]);
end %}}} END FUNCTION

%% P1b -
function plotP1b(zfreq) %{{{
    figure();

    bar([1,2,3,4,5,6,7],zfreq,'FaceColor','#023047'); grid, grid minor;

    xlabel('\textbf{Estado}','Interpreter','latex',FontSize=16,Color='k');
    ylabel('\textbf{Frequ\^encia relativa}','Interpreter','latex',FontSize=16,Color='k');
    t = sort(zfreq,'ascend');
    yticks(t); ylim([0, 0.26]);
end %}}} END FUNCTION

%% P1c -
function plotP1c(zfreq,Aluguer) %{{{
    figure();
    rendaMedia = zfreq .* Aluguer;

    bar([1,2,3,4,5,6,7],rendaMedia,'FaceColor','#7DCFB6'); grid, grid minor;

    xlabel('\textbf{Estado}','Interpreter','latex',FontSize=16,Color='k');
    ylabel('\textbf{Renda m\''edia [EUR/Jogada]}','Interpreter','latex',FontSize=16,Color='k');
    t = sort(rendaMedia,'ascend');
    yticks(t); ylim([0, 4.73]);

end %}}} END FUNCTION

%% Calculate and print the theoric steady-state/equilibrium probability vector, comparing it to the simulated one
function printSteadyStateVector(zfreq) %{{{
%     %-transition matrix
%     P=[0,0.5,0.5,0,0,0,0;
%        0,0,0.5,0.5,0,0,0;
%        0,0,0,0.5,0.5,0,0;
%        0,0,0,0,0.5,0.5,0;
%        0,0,0.5,0,0,0.5,0;
%        0,0,0.5,0,0,0,0.5;
%        0.5,0.5,0,0,0,0,0];
%     Pm = P^100; % limit behaviour: w = wP
%     p_teorico = Pm(1,:); 

    P=[0,0.5,0.5,0,0,0,0;
       0,0,0.5,0.5,0,0,0;
       0,0,0,0.5,0.5,0,0;
       0,0,0,0,0.5,0.5,0;
       0,0,0.5,0,0,0.5,0;
       0,0,0.5,0,0,0,0.5;
       0.5,0.5,0,0,0,0,0];

    [V, ~] = eig(P');
    sumColumn = sum(V);
    p_teorico = V(:,1)/sumColumn(1);
    
    %-display both vectors
    fprintf('\t\t p_teorico: ['); fprintf('%g, ', p_teorico(1:end-1)); fprintf('%g]',p_teorico(end));
    fprintf('\n\t\t\t p_exp: ['); fprintf('%g, ', zfreq(1:end-1)); fprintf('%g]\n', zfreq(end));
end %}}} END FUNCTION