# written by Liangying, 20/3/2020
library(tidyverse)
library(knitr)
library(lavaan)
library(psych)
library(MBESS)


data <- read.csv("D:/brainbnu/haiyang/hddm/result/all_StimCoding/avtz2/FPN_v_anxiety.csv")
head(data)
data2 <- split(data,data$group)

# v:independent
# trait anxiety: dependent
# MFG/IPS_2T/TPS_1T: mediation


mod1 <- " IPS_2T ~ a * STAI
          v ~ b* IPS_2T
          v ~ cp * STAI
# indirect and total effects
ab := a * b
total := cp + ab"

set.seed(1234)
fsem1 <- sem(mod1, data = data2$`0`,se = "bootstrap",  bootstrap = 10000)    #se = "bootstrap",
#fsem1 <- cfa(mod1, data = data2$`0`)
summary(fsem1, standardized = TRUE,fit.measures = TRUE)
parameterestimates(fsem1, boot.ci.type = "bca.simple", standardized = TRUE) %>% 
  kable()

model_performance.lavaan(fsem1, metrics = "Chisq")
fitmeasures(fsem1)

#------------------------------------------------------------------------------------------------

mod2 <- " MFG ~ a * SSAI
          v ~ b* MFG
          v ~ cp * SSAI
# indirect and total effects
ab := a * b
total := cp + ab"

set.seed(1234)
fsem2 <- sem(mod2, data = data2$`0`,se = "bootstrap",  bootstrap = 10000)    #se = "bootstrap",
#fsem1 <- cfa(mod1, data = data2$`0`)
summary(fsem2, standardized = TRUE,fit.measures = TRUE)
parameterestimates(fsem2, boot.ci.type = "bca.simple", standardized = TRUE) %>% 
  kable()

model_performance.lavaan(fsem2, metrics = "Chisq")
fitmeasures(fsem2)

data = data2$`0`
cor.test(data$MFG, data$SSAI)
#-----------------------------------------------------------------------------------------------
mod3 <- " IPS_1T ~ a * STAI
          v ~ b* IPS_1T
          v ~ cp * STAI
# indirect and total effects
ab := a * b
total := cp + ab"

set.seed(1234)
fsem3 <- sem(mod3, data = data2$`0`,se = "bootstrap",  bootstrap = 10000)    #se = "bootstrap",
#fsem1 <- cfa(mod1, data = data2$`0`)
summary(fsem3, standardized = TRUE,fit.measures = TRUE)
parameterestimates(fsem3, boot.ci.type = "bca.simple", standardized = TRUE) %>% 
  kable()

model_performance.lavaan(fsem3, metrics = "Chisq")
fitmeasures(fsem3)



# ---------------------Group Comparison----------------------------------------------------

# 1¡¢Local estimation   piecewiseSEM test
options(repos='http://mirrors.tuna.tsinghua.edu.cn/CRAN/')  # ¸Ä³Éhttp£¬ ¶ø²»ÊÇhttps
install.packages("piecewiseSEM")

library(piecewiseSEM)
pmodel <- psem(
  lm(IPS_2T ~ STAI, data),
  lm(v ~ IPS_2T, data)
)

(pmultigroup <- multigroup(pmodel, group = "group"))


# 2¡¢Global estimation  
multigroup.model <- '
IPS_2T ~ STAI
v ~ IPS_2T
'

library(lavaan)

# "fee" model, coefficents of paths vary across different groups
multigroup1 <- sem(multigroup.model, data, group = "group") 
summary(multigroup1)

# "constrained" model, coefficents of paths are the same across different groups
multigroup1.constrained <- sem(multigroup.model, data, group = "group", group.equal = c("intercepts", "regressions")) 
summary(multigroup1.constrained)

anova(multigroup1, multigroup1.constrained)


#releasing constraints to try and identify which path varies between groups
multigroup.model2 <- '
IPS_2T ~ c("b1", "b1") * STAI
v ~ IPS_2T
'

multigroup2 <- sem(multigroup.model2, data, group = "group")
anova(multigroup1, multigroup2)   #if significant, then should not be constrained, and should be left to vary among groups.


multigroup.model3 <- '
IPS_2T ~ STAI
v ~ c("b2", "b2") * IPS_2T
'

multigroup3 <- sem(multigroup.model3, data, group = "group")
summary(multigroup3)
anova(multigroup1, multigroup3)





#------MFG---------------------------------
# 2¡¢Global estimation  
multigroup.model <- '
MFG ~ STAI
v ~ MFG
'

library(lavaan)

# "fee" model, coefficents of paths vary across different groups
multigroup1 <- sem(multigroup.model, data, group = "group") 
summary(multigroup1)

# "constrained" model, coefficents of paths are the same across different groups
multigroup1.constrained <- sem(multigroup.model, data, group = "group", group.equal = c("intercepts", "regressions")) 
summary(multigroup1.constrained)

anova(multigroup1, multigroup1.constrained)


#releasing constraints to try and identify which path varies between groups
multigroup.model2 <- '
MFG ~ c("b1", "b1") * STAI
v ~ MFG
'

multigroup2 <- sem(multigroup.model2, data, group = "group")
anova(multigroup1, multigroup2)   #if significant, then should not be constrained, and should be left to vary among groups.


multigroup.model3 <- '
MFG ~ STAI
v ~ c("b2", "b2") * MFG
'

multigroup3 <- sem(multigroup.model3, data, group = "group")
summary(multigroup3)
anova(multigroup1, multigroup3)









#--------------------------------------------------------------------------------------------------
mod2 <- " FPN_DMN ~ a * STAI + w1*SSAI
          v ~ b* FPN_DMN 
          v ~ cp * STAI + w2 *SSAI
# indirect and total effects
ab := a * b
total := cp + ab"

set.seed(1234)
fsem3 <- sem(mod2, data = data2$`0`,  bootstrap = 10000)
summary(fsem3, standardized = TRUE,fit.measures = TRUE)
parameterestimates(fsem3, boot.ci.type = "bca.simple", standardized = TRUE) %>% 
  kable()








mod3<-"v ~ a * SSAI
         IPS_2T ~ b * SSAI
         v ~ c * IPS_2T "

sem_model <- sem(mod3,data2$`0`,bootstrap = 10000)
parameterestimates(sem_model, boot.ci.type = "bca.simple", standardized = TRUE) %>% 
  kable()
summary(sem_model,fit.measures = TRUE)
# Show SEM Path: 
library(semPlot)
semPaths(mod3, what = "std", nCharNodes = 6, sizeMan = 8,
         edge.label.cex = 1.1, curvePivot = TRUE, fade = FALSE)

fitMeasures(mod3, fit.measures = c("cfi", "rmsea"))
cfa(mod3, data = data2$`0`) %>% summary() 










model_performance.lavaan <- function(model, metrics = "all", ...) {
  if (!requireNamespace("lavaan", quietly = TRUE)) {
    stop("Package `lavaan` needed for this function to work. Please install it.", call. = FALSE)
  }
  
  measures <- as.data.frame(t(as.data.frame(lavaan::fitmeasures(model, ...))))
  row.names(measures) <- NULL
  
  out <- data.frame(
    "Chisq" = measures$chisq,
    "Chisq_df" = measures$df,
    "Chisq_p" = measures$pvalue,
    
    "Baseline" = measures$baseline.chisq,
    "Baseline_df" = measures$baseline.df,
    "Baseline_p" = measures$baseline.pvalue,
    
    "GFI" = measures$gfi,
    "AGFI" = measures$agfi,
    
    "NFI" = measures$nfi,
    "NNFI" = measures$tli,
    
    "CFI" = measures$cfi,
    
    "RMSEA" = measures$rmsea,
    "RMSEA_CI_low" = measures$rmsea.ci.lower,
    "RMSEA_CI_high" = measures$rmsea.ci.upper,
    "RMSEA_p" = measures$rmsea.pvalue,
    
    "RMR" = measures$rmr,
    "SRMR" = measures$srmr,
    
    "RFI" = measures$rfi,
    "PNFI" = measures$pnfi,
    "IFI" = measures$ifi,
    "RNI" = measures$rni,
    "Loglikelihood" = measures$logl,
    "AIC" = measures$aic,
    "BIC" = measures$bic,
    "BIC_adjusted" = measures$bic2
  )
  
  if (all(metrics == "all")) {
    metrics <- names(out)
  }
  
  out[, metrics]
}
