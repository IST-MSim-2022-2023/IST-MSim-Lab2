%% Tidy up env :)
clear; clc;

%% function call
Error();
MonteCarloRuns();


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
        end                                     %------------------inner loop-----------------

        zfreq = z./((Njogadas-Ndiscard)*n);
        err = err + sum((zfreq - p_teorico).^2);
    end                                         %------------------outer loop------------------

    err = sqrt(err/NMC); 
end
%% Err function
function Error()
    Ncasas = 7; Njogadas = 10000; NMC = 100; NdiscardRange = 10000; 
    %-transition matrix
    P=[0,0.5,0.5,0,0,0,0;
       0,0,0.5,0.5,0,0,0;
       0,0,0,0.5,0.5,0,0;
       0,0,0,0,0.5,0.5,0;
       0,0,0.5,0,0,0.5,0;
       0,0,0.5,0,0,0,0.5;
       0.5,0.5,0,0,0,0,0];
        
    Pm = P^100; % limit behaviour: w = wP
    p_teorico = Pm(1,:); 
    
    for Ndiscard = 1:NdiscardRange 
        rand('state',0);
        err = simplifiedMonopoly(Ncasas,Njogadas,NMC,Ndiscard, p_teorico);
        Err(Ndiscard) = err;
    end

    figure()
    plot(1:NdiscardRange, Err, 'LineWidth', 2, 'Color', "#77AC30");
    yline(Err(6), '--','\textbf{Zona Est\''avel}', 'interpreter', 'latex','FontSize', 14, 'LineWidth', 2,'LabelHorizontalAlignment','center');
    ylabel('\textbf{\textit{RMSE}}', 'interpreter', 'latex','FontSize', 15); xlabel('\textbf{Ndiscard}', 'interpreter', 'latex','FontSize', 15);
    title({'\textbf{Evolu\c{c}\~ao Do Erro}', '\textbf{Mediante o incremento de NDiscard}'},'interpreter', 'latex','FontSize', 15);
    grid, grid minor;
end
%% variation with number of runs
function MonteCarloRuns()

    Ncasas = 7; Njogadas = 200; NMCMax = 1000; Ndiscard = 20; 
    Err = zeros(1,NMCMax);
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
    
    for x = 1:3
        hh = waitbar(0);
        rand('state',x);
        Err = zeros(1,NMCMax);
        for NMC = 1:NMCMax 
            for n = 1:10
                err = simplifiedMonopoly(Ncasas,Njogadas,NMC,Ndiscard, p_teorico');
                Err(NMC) = Err(NMC) + err;
            end
            hh = waitbar(NMC/NMCMax);
            Err(NMC) = Err(NMC)/10;
        end

        %Fit curve
        %create the new fittype (n=1)
        ft=fittype({'1/(x)^(1/2)'});

        NMC = 1:length(Err);

        % fit the three datapoints with the given fittype
        fitobject=fit(NMC',Err',ft);
    
        fig=plot(fitobject,'-');
        set(fig,'lineWidth',2);
        %.................. ^
        hold on;
        plot(NMC,Err,'.','MarkerSize',2);
        hold on
    end
    close(hh);

    hold off
    legend('Fitted curve $\propto 1/\sqrt{N}$', 'Erro por N','interpreter', 'latex','Fontsize', 10);
    ylabel('\textbf{\textit{RMSE}}', 'interpreter', 'latex','FontSize', 15); xlabel('\textbf{NMC}', 'interpreter', 'latex','FontSize', 15);
    title({'\textbf{Evolu\c{c}\~ao do erro}', '\textbf{com o incremento de NMC}'},'interpreter', 'latex','FontSize', 15);

%     %% log plot
% 
%      figure();
%      ErrSmooth = smooth(Err);
%      loglog(NMC, ErrSmooth, 'LineWidth',2);
%      hold on; loglog(NMC, 0.12*(NMC).^(-1/2), LineWidth=2);
%      ylabel('$\sqrt{\|e\|^2}$', 'interpreter', 'latex','FontSize', 15); xlabel('\textbf{NMC}', 'interpreter', 'latex','FontSize', 15);
%      title({'\textbf{Evolu\c{c}\~ao Do Erro}', '\textbf{Mediante o incremento de NMC}'},'interpreter', 'latex','FontSize', 15);
end
