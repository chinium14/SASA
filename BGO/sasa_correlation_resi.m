load 'sasa_resi_both.dat';

x = sasa_resi_both(:,2);
y = sasa_resi_both(:,3);
%digits(16)
%p = polyfit(x,y,1);
%vpa(p)
%yfit = polyval(p,x);
yfit = x;
yresid = y - yfit;

SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rseq = 1 - SSresid / SStotal
figure;
hold on;
plot(x, yfit, '-', x, y, '+');
title('Corelation of SASA by BGO and All-atom per residue of 2PBG.');
xlabel('SASA of all-atom structure by CHARMM.' );
ylabel('SASA of Go-like model structure by this work.');
print -dpng 2PBG_sasa_corelation.png
exit;
