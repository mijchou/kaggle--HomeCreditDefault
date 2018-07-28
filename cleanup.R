# Setup

library(caret)
library(rpart)
library(kernlab)
library(randomForest)

library(mice)
library(DMwR)
library(RANN)
library(future)

library(rstudioapi)

rstudioapi::getActiveDocumentContext
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

train <- read.csv('train.csv', stringsAsFactors = T)
test <- read.csv('test.csv', stringsAsFactors = T)

# Data Cleaning

raw <- rbind(train[, -2], test) # remove TARGET to be used later
source('datacleaning.R') # rename, coerce

## Check: missing values

sapply(raw, function(x) round(sum(is.na(x))))
sapply(raw, function(x) length(which(x == '')))
sapply(raw, function(x) length(which(x == 'XNA')))

### Imputation 1: loanAnnu 36 NA (Mean/Median) 

raw1 <- raw

raw1$loanAnnu[which(is.na(raw1$loanAnnu))] <-
  median(raw1$loanAnnu, na.rm = T)

### Imputation 2: goodPric 278 NA (Modelling) 

raw2 <- raw1

goodPric.missing <- raw2[is.na(raw$goodPric), ]
goodPric.model <- goodPric ~ houseYN + chilNum + loanAmou + incomeAmou +
                             incomeType + livingStat + age + regionRating +
                             famNum + occupation + contType + carYN + 
                             education + livingStat + regionPopu + 
                             regionCityRating

goodPric.grid <- expand.grid(.cp = seq(0.001, 0.02, by = 0.001))
goodPric.fit <- train(goodPric.model, data = raw2[-which(is.na(raw2$goodPric)), ],
                      method = 'rpart',
                      tuneGrid = goodPric.grid,
                      trControl = trainControl(method = 'CV',
                                               number = 5))
goodPric.fit$results

goodPric.pred <- predict(goodPric.fit, newdata = goodPric.missing)

## %% ========== %% ## Error checking: different lenghts of I/O?

# nrow(goodPric.missing) # Checked: 278
# length(goodPric.pred) # Checked: 276

## Problem diagnostics

a <- row.names(goodPric.missing) ; b <- names(goodPric.pred)
a %in% b # search differences
fix1.indicies <- which(!(a %in% b)) # indicies of missing predictions

## Fix - 276 rpart Predictions + 2 medians

raw2$goodPric[is.na(raw2$goodPric)][-fix1.indicies] <- # get the NA & take out the 2
                                                       goodPric.pred
raw2$goodPric[is.na(raw2$goodPric)] <- median(raw2$goodPric, na.rm = T)

## %% ========== %% ##

### Imputation 3: famNum 2 NA

raw3 <- raw2

raw3$famNum[which(is.na(raw3$famNum))] <-
  median(raw3$famNum, na.rm = T)

### Imputation: obsSocSur30 1050 NA (NOT USED)

## Found to be strongly related to each other: obs30/def30/obs60/def60
## which are all missing in same rows.

### Imputation: defSocSur30 1050 NA (NOT USED)
### Imputation: obsSocSur60 1050 NA (NOT USED)
### Imputation: defSocSur60 1050 NA (NOT USED)

### Imputation 4: extScore2 668 NA

raw4 <- raw3


### Imputation 9: extScore3 69633 NA

### Imputation 10: extScore1 193910 NA

### Imputation 11: reqCB1hr 47568 NA

### Imputation 12: reqCB1day 47568 NA

### Imputation 13: reqCB1week 47568 NA

### Imputation 14: reqCB1mon 47568 NA

### Imputation 15: reqCB3mon 47568 NA

### Imputation 16: reqCB1year 47568 NA

### Imputation 17: whoAcco 2203 ''

### Imputation 18: occupation 111996 ''

### Imputation 19: gender 4 'XNA'

### Imputation 20: workOrg 64648 'XNA'


## Check: factor levels










