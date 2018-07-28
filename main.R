
# Setup

library(caret)
library(rpart)
library(kernlab)
library(randomForest)

library(mice)
library(DMwR)

library(rstudioapi)
library(parallel)

rstudioapi::getActiveDocumentContext
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

train <- read.csv('train2.csv', stringsAsFactors = T) # 5000 entries for now
test <- read.csv('test2.csv', stringsAsFactors = T) # 1000 entries for now

# Data Checking & Cleaning

names(train)
str(train)

## Rename

train <- within(train, rm('X'))
names(train) <- c('id', 'target', 'contType', 'gender', 'carYN',
                  'houseYN', 'chilNum', 'incomeAmou', 'loanAmou', 'loanAnnu',
                  'goodPric', 'whoAcco', 'incomeType', 'education', 'marriStat',
                  'livingStat', 'regionPopu', 'age', 'employDay', 'registDay',
                  'changeIdDay', 'ageCar', 'mobileYN', 'empPhoneYN', 'workPhoneYN',
                  'mobileContYN', 'homePhoneYN', 'emailYN', 'occupation', 'famNum',
                  'regionRating', 'regionCityRating', 'applyWeekday', 'applyHours', 'regionNPermCont',
                  'regionNPermWork', 'regionNContWork', 'cityNPermCont', 'cityNPermWork', 'cityNContWork',
                  'workOrg', 'extScore1', 'extScore2', 'extScore3', 'apartmAvg',
                  'basementAreaAvg', 'yearExpAvg', 'yearBuildAvg', 'commonAreaAvg', 'elevatorsAvg',
                  'entranceAvg', 'floorMaxAvg', 'floorMinAvg', 'landAreaAvg', 'livingApartmAvg',
                  'livingAreaAvg', 'nlivingApartmAvg', 'nlivingAreaAvg', 'apartmMode', 'basementAreaMode',
                  'yearExpMode', 'yearBuildMode', 'commonAreaMode', 'elevatorMode', 'entranceModde',
                  'floorMaxMode', 'floorMinMode', 'landAreMode', 'livingApartmMode', 'livingAreaMode',
                  'nlivingApartmMode', 'nlivingAreaMode', 'apartmMedi', 'basementAreaMedi', 'yearExpMedi',
                  'yearBuildMedi', 'commonAreaMedi', 'elevatorMedi', 'entranceMedi', 'floormaxMedi',
                  'floorMinMedi', 'landAreaMedi', 'livingApartmMedi', 'livingAreaMedi', 'nlivingApartmMedi',
                  'nlivingAreaMedi', 'fondKarMode', 'houseTypeMode', 'totalAreaMode', 'wallMaterialMode',
                  'emergencyMode', 'obsSocSur30', 'defSocSur30', 'obsSocSur60', 'defSocSur60',
                  'changePhoneDay', 'doc2', 'doc3', 'doc4', 'doc5',
                  'doc6', 'doc7', 'doc8', 'doc9', 'doc10',
                  'doc11', 'doc12', 'doc13', 'doc14', 'doc15',
                  'doc16', 'doc17', 'doc18', 'doc19', 'doc20',
                  'doc21', 'reqCB1hr', 'reqCB1day', 'reqCB1week', 'reqCB1mon',
                  'reqCB3mon', 'reqCB1year')

## Modification: class coersions

train$target <- as.factor(train$target)

train$mobileYN <- as.factor(train$mobileYN)
train$empPhoneYN <- as.factor(train$empPhoneYN)
train$workPhoneYN <- as.factor(train$workPhoneYN)
train$mobileContYN <- as.factor(train$mobileContYN)
train$homePhoneYN <- as.factor(train$homePhoneYN)
train$emailYN <- as.factor(train$emailYN)

train$regionNPermCont <- as.factor(train$regionNPermCont)
train$regionNPermWork <- as.factor(train$regionNPermWork)
train$regionNContWork <- as.factor(train$regionNContWork)
train$cityNPermCont <- as.factor(train$cityNPermCont)
train$cityNPermWork <- as.factor(train$cityNPermWork)
train$cityNContWork <- as.factor(train$cityNContWork)

for(i in 97:116) train[, i] <- as.factor(train[, i]) # doc2 to doc21

## Remove features with 1 level

train[which(sapply(train, nlevels) == 1)]
train <- within(train, rm('doc2', 'doc4', 'doc7',
                          'doc10', 'doc12', 'mobileYN'))

## Missing Data Imputation

sapply(train, function(x) sum(is.na(x)))
over5p <- sapply(train, function(x) sum(is.na(x))/5000 * 100) > 5
train <- train[, -which(over5p)]

train$goodPric[which(is.na(train$goodPric))] <-
  median(train$goodPric, na.rm = T)

missTrue <- sapply(train, function(x) any(is.na(x)))
train <- knnImputation(train)

# Modelling

## Features Selection

filtered.model <- target ~ .

null <- glm(target ~ 1, family = binomial, data = train)
filtered <- glm(filtered.model, family = binomial, data = train)

step(null, scope= list(lower = null, upper = filtered),
     direction = 'forward')

model <- target ~ extScore2 + changeIdDay + education + 
  defSocSur30 + gender + contType + age + goodPric + houseYN + 
  changePhoneDay + regionCityRating + loanAnnu + incomeType + 
  employDay


rf.grid <- expand.grid(.mtry = 2:9)
fit.rf <- train(model, data = train,
                method = 'rf', ntree = 400,
                tuneGrid = rf.grid,
                trControl = trainControl(method = 'CV',
                                         number = 5))

fit.rf$results
max(fit.rf$results[, 'Accuracy'])



################# extScore2

## features:
## loanAmou + loanAnnu + goodPic + ageCar + elevatorAvg

fit <- boosting(extScore2 ~ ., data = extScore2.traindf, boos = T, mfinal = 5)


extScore2.traindf <- raw4[complete.cases(raw4[, c(8, 9, 10, 21, 42, 44:85)]), 
                          c(8, 9, 10, 21, 42, 44:85)]

extScore2.fit <- glm(extScore2 ~ ., data = extScore2.traindf, family = gaussian)
varImpPlot(extScore2.fit)

extScore2.grid <- expand.grid(.cp = seq(0.001, 0.02, by = 0.001))
extScore2.fit <- train(extScore2 ~ ., data = extScore2.traindf,
                       method = 'rpart',
                       tuneGrid = extScore2.grid,
                       trControl = trainControl(method = 'CV',
                                                number = 5))

extScore2.grid <- expand.grid(.mtry = 3:7)
extScore2.fit <- train(extScore2 ~ ., data = extScore2.traindf,
                       method = 'rf', ntree = 400, mtry = 2,
                       trControl = trainControl(method = 'CV',
                                                number = 5))


extScore2.fit <- glm(extScore2 ~ ., data = extScore2.traindf,
                     family = Gamma(link = "probit"))

extScore2.fit <- rpart(extScore2 ~ .,  data = extScore2.traindf)

pred <- predict(extScore2.fit, newdata = raw4[which(is.na(raw4$extScore2)), ])

pred <- predict(extScore2.fit, newdata = raw4[10001:10100, ])


extScore2.model <- extScore2 ~ contType + gender + carYN +
  houseYN + childNum + incomeAmou + loanAmou + loanAnnu +
  goodPric + incomeType + education + marriStat + livingStat +
  regionPopu + age + emplyDay + registDay + changeIdDay

houseYN + chilNum + loanAmou + incomeAmou +
  incomeType + livingStat + age + regionRating +
  famNum + occupation + contType + carYN + 
  education + livingStat + regionPopu + 
  regionCityRating # full model

extScore2.grid <- expand.grid(.cp = seq(0.001, 0.02, by = 0.001))
extScore2.fit <- train(extScore2.model, data = raw2[-which(is.na(raw2$extScore2)), ],
                       method = 'rpart',
                       tuneGrid = extScore2.grid,
                       trControl = trainControl(method = 'CV',
                                                number = 5))
goodPric.fit$results

raw2$goodPric[which(is.na(raw2$goodPric))] <-
  predict(goodPric.fit, goodPric.missing)
