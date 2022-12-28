%% Tidy up env :)
clear; clc; close all;

%% function call

Error();


%% function def
function err = simplifiedMonopoly(Ncasas,Njogadas,NMC,Ndiscard, p_teorico)
    z = zeros(1,Ncasas);
    err = 0;

    for n = 1:NMC
        x = 0;

        for m = 1:Njogadas
            avanca = round(rand(1)) + 1;

            switch x
                case {1, 2, 3, 4}
                    x = x + avanca;
                case {0, 7}
                    x = avanca;
                case 5
                    if avanca == 1
                        x = 6;
                    else
                        x = 3;
                    end
                case 6
                    if avanca == 1
                        x = 3;
                    else
                        x = 7;
                    end
            end

            if m > Ndiscard
                z(x) = z(x) + 1;
            end
        end
    end
     zfreq = z./((Njogadas-Ndiscard)*NMC);
     if (Njogadas - Ndiscard == 0)
        zfreq = 0;
     end
     err = sum(abs(zfreq - p_teorico));
end
%% Err function
function Error()
    Ncasas = 7; Njogadas = 100; NMC = 100000; NdiscardRange = 100;
    
    %-transition matrix
    P=[0,0.5,0.5,0,0,0,0;
       0,0,0.5,0.5,0,0,0;
       0,0,0,0.5,0.5,0,0;
       0,0,0,0,0.5,0.5,0;
       0,0,0.5,0,0,0.5,0;
       0,0,0.5,0,0,0,0.5;
       0.5,0.5,0,0,0,0,0];
        
%     Pm = P^100; % limit behaviour: w = wP
%     p_teorico = Pm(1,:); 

    [V, ~] = eig(P');
    sumColumn = sum(V);
    p_teorico = V(:,1)/sumColumn(1);
    
    for Ndiscard = 1:NdiscardRange
        rand('state',0);
        err = simplifiedMonopoly(Ncasas,Njogadas,NMC,Ndiscard, p_teorico');
        Err(Ndiscard) = err;
    end
    
    plot(1:NdiscardRange, Err, 'LineWidth', 2, 'Color', "#77AC30");
    yline(Err(6), '--', '\textbf{Zona Est\''avel}', 'interpreter', 'latex', 'LineWidth', 2,'FontSize', 15,'LabelHorizontalAlignment','center');
    ylabel('\textbf{Erro absoluto}', 'interpreter', 'latex','FontSize', 15); xlabel('\textbf{NDiscard}', 'interpreter', 'latex','FontSize', 15);
    title({'\textbf{Evolu\c{c}\~ao Do Erro}', '\textbf{Mediante o incremento de NDiscard}'},'interpreter', 'latex','FontSize', 15);
    grid, grid minor;
    xlim([1, 1000]);
end