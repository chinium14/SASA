load 'train_sasa_both.dat';

x = train_sasa_both(:,2);
y = train_sasa_both(:,4);
digits(16)
p = polyfit(x,y,1);
vpa(p)
yfit = polyval(p,x);
yresid = y - yfit;

SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rseq = 1 - SSresid / SStotal
figure;
hold on;
plot(x, yfit, '-', x, y, '+');
title('Fitting of SASA by BGO and All-atom with the training set.');
xlabel('SASA of all-atom structure by CHARMM.' );
ylabel('SASA of Go-like model structure by this work.');
print -dpng training_sasa_corelation.png
exit;
