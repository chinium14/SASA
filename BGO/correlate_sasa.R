
ca <-read.table("sasa_resi_both.dat")
all<-ca$V2
bgo<-ca$V3
cor(all,bgo)
plot(all,bgo)
abline(0,1)
