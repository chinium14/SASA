
ca <-read.table("sasa_resi_both.txt")
all<-ca$V3
bgo<-ca$V2
cor(all,bgo)
plot(all,bgo)
