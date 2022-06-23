set.seed(1109)
library(tidyverse)
library(magrittr)
library(janitor)
library(readr)
library(caret)
library(GGally)
library(UPG)
library(corrplot)
library(bayesplot)
theme_set(bayesplot::theme_default(base_family = "sans"))
library(rstanarm)
options(mc.cores = 1)
library(loo)
library(projpred)

df <- read_csv("breastexam.csv",
               col_types =
                 cols(age_c =
                        col_integer(),
                      assess_c =
                        col_factor(levels =
                                   c("0", "1", "2", "3",
                                     "4", "5")),
                      cancer_c =
                        col_factor(levels =
                                     c("0", "1")),
                      density_c =
                        col_factor(levels =
                                   c("1", "2", "3", "4")),
                      famhx_c =
                        col_factor(levels =
                                     c("0", "1", "9"))))


table(df$cancer_c)
table(df$famhx_c)

# IMC de una normal:
# m <- mean(as.vector(df[df['bmi_c'] != -99,6])$bmi_c)
# d <- sd(as.vector(df[df['bmi_c'] != -99,6])$bmi_c)
# 
# sim <- rnorm(23209,m,d)

head(df)

sim <- sample(seq(18.5,30,0.1),23209, replace = T)

# IMC de una unforme:
#sim <- runif(23209,18.5,30)

df[df['bmi_c'] == -99,6] <- sim

#write.csv(df, file='dataset_BreastExam.csv')

df.cut <- df[sample(1:40000,20000,replace = F),]

table(df.cut$cancer_c)

e <- sample(18:59,20000,replace = T)

summary(df$bmi_c)

bmi <- runif(20000,18.5,32)

as <- round(runif(20000,0,5),0)

fa <- sample(c(0,1,9),20000,replace = T)

de <- ifelse(as %in% c(4,5),round(runif(1,2,4),0), round(runif(1,1,3),0))

names(df)

### Condicionales:

attach(df.cut)

# Hacer vectores y al final 

c1 <- ifelse(assess_c %in% c(0,1,2,3),
             ifelse(density_c==4 | density_c==3,ifelse(famhx_c==1,1,0),0),0)

c2 <- ifelse(assess_c == 4,ifelse(density_c==4 | density_c==3 | density_c==2,
                                  ifelse(famhx_c==1,1,0),0),0)

c3 <- ifelse(assess_c == 5,ifelse(density_c %in% 1:5,1,0),0)

c <- ifelse(c1== 1 | c2==1 | c3==1,1,0)

df.sim <- data.frame('age_c'=e,'assess_c'=as,'cancer_c'=c,'density_c'=de,
                     'famhx_c'=fa,'bmi_c'=bmi)


df.f <- rbind(df.cut,df.sim)

table(df.f$cancer_c)
table(df.f$famhx_c)

write.csv(df.f, file='dataset.csv', row.names = F)


