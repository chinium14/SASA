
ca <- read.table("dist_ca_2PBG.dat")
d <- density(ca$V1)
plot(d, axes=T, xlab="Residue-residue distance (Angstom)", ylab="Density",main="Density distribution of residue-residue distances.", col="red")

center <- read.table("dist_center_2PBG.dat")
dd <- density(center$V1)
lines(dd)
legend("topleft",inset=.05, title="Distance measured by",legend=c("Center of mass","C-alpha"),pch=15,col=c("black","red"))
