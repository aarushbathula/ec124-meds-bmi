#Clean data from missing values, coded as -1, -8 and -9 for relevant variables

HSE<-hse_2019_eul_20211006
HSE<-subset(HSE,BMIvg53 !=-1)
HSE<-subset(HSE,MENHTAKg2 !=-1)
HSE<-subset(HSE,AntiDepTakg2 !=-1)
HSE<-subset(HSE,ANTIPSYTAKg2 !=-1)
HSE<-subset(HSE,BMIvg53 !=-8)
HSE<-subset(HSE,MENHTAKg2 !=-8)
HSE<-subset(HSE,AntiDepTakg2 !=-8)
HSE<-subset(HSE,ANTIPSYTAKg2 !=-8)
HSE<-subset(HSE,BMIvg53 !=-9)
HSE<-subset(HSE,MENHTAKg2 !=-9)
HSE<-subset(HSE,AntiDepTakg2 !=-9)
HSE<-subset(HSE,ANTIPSYTAKg2 !=-9)
HSE<-subset(HSE,Sex !=-1)
HSE<-subset(HSE,Sex !=-8)
HSE<-subset(HSE,Sex !=-9)
HSE<-subset(HSE,HYPNOTAKg2 !=-1)
HSE<-subset(HSE,HYPNOTAKg2 !=-8)
HSE<-subset(HSE,HYPNOTAKg2 !=-9)

#Histograms of BMI category distribution given you take/ do not take mental health medication

Med<-subset(HSE,MENHTAKg2 !=0)
NoMed<-subset(HSE,MENHTAKg2 !=1)
hist(Med$BMIvg53, main = "BMI distribution of Med Takers", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,200),col = "cyan", border = "blue", breaks = 15)
abline(v= mean(Med$BMIvg53), col="green", lwd=3)
hist(NoMed$BMIvg53, main = "BMI distribution of Non-Med Takers", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,1500),col = "orange", border = "red", breaks = 15)
abline(v= mean(NoMed$BMIvg53), col="green", lwd=3)

#We assume that these samples have the same population standard deviation (sample sd: 1.09, and 0.97)

#We will conduct a difference of means test. Both variables approximately follow a normal distribution. P value is found with t-test.
#Alternative hypothesis is one sided, Med takers mean is higher than Non Med takers.

#Sample variance s0:

s0<-((nrow(NoMed)-1)*var(NoMed$BMIvg53)+(nrow(Med)-1)*var(Med$BMIvg53))/(nrow(Med)+nrow(NoMed)-2)

#p-value

one<-pt(q=((mean(Med$BMIvg53)-mean(NoMed$BMIvg53))/(s0*sqrt(1/(nrow(Med))+1/(nrow(NoMed))))), df=(nrow(Med)+nrow(NoMed)), lower.tail = FALSE)

#We reject the Null Hypothesis.

#Histograms of BMI category distribution given you take/ do not take mental health medication for males

MMed<-subset(HSE,Sex!=2)
MMed<-subset(MMed,MENHTAKg2 !=0)

MNoMed<-subset(HSE,Sex!=2)
MNoMed<-subset(MNoMed,MENHTAKg2 !=1)

hist(MMed$BMIvg53, main = "BMI distribution of Male Med Takers", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,80),col = "cyan", border = "blue", breaks = 15)
abline(v= mean(MMed$BMIvg53), col="green", lwd=3)
hist(MNoMed$BMIvg53, main = "BMI distribution of Male Non-Med Takers", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,800),col = "orange", border = "red", breaks = 15)
abline(v= mean(MNoMed$BMIvg53), col="green", lwd=3)

#Histograms of BMI category distribution given you take/ do not take mental health medication for females

FMed<-subset(HSE,Sex!=1)
FMed<-subset(FMed,MENHTAKg2 !=0)

FNoMed<-subset(HSE,Sex!=1)
FNoMed<-subset(FNoMed,MENHTAKg2 !=1)

hist(FMed$BMIvg53, main = "BMI distribution of Female Med Takers", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,150),col = "cyan", border = "blue", breaks = 15)
abline(v= mean(FMed$BMIvg53), col="green", lwd=3)
hist(FNoMed$BMIvg53, main = "BMI distribution of Female Non-Med Takers", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,900),col = "orange", border = "red", breaks = 15)
abline(v= mean(FNoMed$BMIvg53), col="green", lwd=3)

#We assume that Male and Female Med takers have same population standard deviation (sample sd: 0.98, and 1.13)

#We will conduct a difference of means test. Both variables approximately follow a normal distribution. P value is found with t-test.
#Alternative hypothesis is two sided, mean Male med taker BMI is not equal to mean female med taker BMI.

#Sample variance s0:

s0a<-((nrow(MMed)-1)*var(MMed$BMIvg53)+(nrow(FMed)-1)*var(FMed$BMIvg53))/(nrow(MMed)+nrow(FMed)-2)

#p-value

two<-pt(q=((mean(FMed$BMIvg53)-mean(MMed$BMIvg53))/(s0a*sqrt(1/(nrow(FMed))+1/(nrow(MMed))))), df=(nrow(FMed)+nrow(MMed)), lower.tail = FALSE)

#We fail to reject the null hypothesis. Mean BMI of male and female med-takers difference is statistically insignificant.

#Histograms of BMI category distribution given you take hypnotics, antidepressants, and anti-psychotics.

Hyp<-subset(HSE,HYPNOTAKg2 !=0 )
Hyp<-subset(Hyp,AntiDepTakg2 !=1 )
Hyp<-subset(Hyp,ANTIPSYTAKg2 !=1 )
Dep<-subset(HSE,AntiDepTakg2 !=0 )
Dep<-subset(Dep,HYPNOTAKg2 !=1 )
Dep<-subset(Dep,ANTIPSYTAKg2 !=1 )
Psy<-subset(HSE,ANTIPSYTAKg2 !=0 )
Psy<-subset(Psy,AntiDepTakg2 !=1 )
Psy<-subset(Psy,HYPNOTAKg2 !=1 )

hist(Dep$BMIvg53, main = "BMI distribution of Antidepressants users", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,150),col = "purple", border = "black", breaks = 15)
abline(v= mean(Dep$BMIvg53), col="green", lwd=3)
hist(Psy$BMIvg53, main = "BMI distribution of Anti-psychotics users", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,10),col = "red", border = "black", breaks = 15)
abline(v= mean(Psy$BMIvg53), col="green", lwd=3)
hist(Hyp$BMIvg53, main = "BMI distribution of Hypnotics users", xlab = "BMI category", ylab = "Observations", xlim = c(1,5), ylim = c(0,15),col = "blue", border = "black", breaks = 10)
abline(v= mean(Hyp$BMIvg53), col="green", lwd=3)

#We will test whether the independent samples are normally distributed.

shapiro.test(Hyp$BMIvg53)
shapiro.test(Dep$BMIvg53)
shapiro.test(Psy$BMIvg53)

#We will conduct three Mann Whitney test to check significance difference in medians between these 3 independent group of med takers (Antidepressants; Antipsychotics; Hypnotics) 


wilcox.test(Dep$BMIvg53, Psy$BMIvg53, alternative = "less", mu = 0, paired = FALSE, exact = FALSE, correct = TRUE, conf.int = FALSE, conf.level = 0.95)

wilcox.test(Dep$BMIvg53, Hyp$BMIvg53, alternative = "two.sided", mu = 0, paired = FALSE, exact = FALSE, correct = TRUE, conf.int = FALSE, conf.level = 0.95)

wilcox.test(Hyp$BMIvg53, Psy$BMIvg53, alternative = "less", mu = 0, paired = FALSE, exact = FALSE, correct = TRUE, conf.int = FALSE, conf.level = 0.95)
