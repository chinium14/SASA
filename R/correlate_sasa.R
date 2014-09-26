
ca <-read.table("sasa_both_all_resi.dat")
all<-ca$V2
bgo<-ca$V3
cor(all,bgo)
plot(all,bgo)
plot(all,bgo, axes=T, xlab="SASA measured by all-atom structure.", ylab="SASA measured by C_alpha.",main="Correlation of SASA measured by all-atom and C-alpha structures.", col="red")
abline(0,1)
legend("topleft", legend=paste('Cor =',round(cor(all, bgo),2)))
