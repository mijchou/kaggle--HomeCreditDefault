
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

# noCores <- detectCores()
# clust <- makeCluster(noCores)

train <- read.csv('train.csv', stringsAsFactors = T)
test <- read.csv('test.csv', stringsAsFactors = T)

# Modification

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

names(test) <- c('id', 'contType', 'gender', 'carYN',
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

# Cleaning


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


test$target <- as.factor(test$target)

test$mobileYN <- as.factor(test$mobileYN)
test$empPhoneYN <- as.factor(test$empPhoneYN)
test$workPhoneYN <- as.factor(test$workPhoneYN)
test$mobileContYN <- as.factor(test$mobileContYN)
test$homePhoneYN <- as.factor(test$homePhoneYN)
test$emailYN <- as.factor(test$emailYN)

test$regionNPermCont <- as.factor(test$regionNPermCont)
test$regionNPermWork <- as.factor(test$regionNPermWork)
test$regionNContWork <- as.factor(test$regionNContWork)
test$cityNPermCont <- as.factor(test$cityNPermCont)
test$cityNPermWork <- as.factor(test$cityNPermWork)
test$cityNContWork <- as.factor(test$cityNContWork)

sapply(train, function(x) round(sum(is.na(x))/307511 * 100))
sapply(train, function(x) length(which(x == ''))/307511 * 100)

over50 <- sapply(train, function(x) round(sum(is.na(x))/307511 * 100)) > 50
sapply(train, function(x) round(sum(is.na(x))/307511 * 100))

train2 <- train[, -which(over50)]
train2 <- data.frame(train2, extScore1 = train$extScore1)

train2$loanAnnu[which(is.na(train2$loanAnnu))] <-
  median(train2$loanAnnu, na.rm = T)
train2$famNum[which(is.na(train2$famNum))] <-
  median(train2$famNum, na.rm = T)
train2$changePhoneDay[which(is.na(train2$changePhoneDay))] <-
  median(train2$changePhoneDay, na.rm = T)

train2 <- within(train2, rm('doc2', 'doc4', 'doc7',
                            'doc10', 'doc12', 'mobileYN'))
train2 <- within(train2, rm('doc3', 'doc5', 'doc6', 'doc8', 'doc9',
                            'doc11', 'doc13', 'doc14', 'doc15', 'doc16',
                            'doc17', 'doc18', 'doc19', 'doc20', 'doc21'))
train2 <- within(train2, rm('yearExpAvg', 'entranceAvg', 'floorMaxAvg',
                            'livingAreaAvg', 'yearExpMode', 'entranceModde',
                            'floorMaxMode', 'livingAreaMode', 'yearExpMedi',
                            'entranceMedi', 'floormaxMedi', 'livingAreaMedi',
                            'totalAreaMode'))
train2 <- within(train2, rm('fondKarMode', 'houseTypeMode',
                            'wallMaterialMode', 'emergencyMode'))

##

goodPrice.fit <- glm(goodPric ~ houseYN + chilNum + loanAmou +
                     incomeType + livingStat + age +
                     famNum + occupation + contType + carYN + incomeAmou +
                     education + livingStat + regionPopu + regionRating +
                     regionCityRating, data = train2,
                     family = gaussian)

goodPric.miss <- train2[which(is.na(train2$goodPric)), ]
goodPric.pred <- predict(goodPrice.fit, newdata = goodPric.miss)
train2$goodPric[which(is.na(train2$goodPric))] <- goodPric.pred

##

extScore2.fit <- glm(extScore2 ~ contType + gender + carYN +
                       houseYN + chilNum + incomeAmou + loanAmou +
                       loanAnnu + goodPric + whoAcco + incomeType +
                       education + marriStat + livingStat + regionPopu +
                       age + employDay + registDay + changeIdDay +
                       empPhoneYN + workPhoneYN + mobileContYN + homePhoneYN +
                       emailYN + occupation + famNum + regionRating + regionCityRating +
                       applyWeekday + applyHours + regionNPermCont + regionNPermWork +
                       regionNContWork + cityNPermCont + cityNPermWork + cityNContWork +
                       workOrg, data = train2, family = gaussian)


extScore2.miss <- train2[which(is.na(train2$extScore2)), ]
extScore2.pred <- predict(extScore2.fit, newdata = extScore2.miss)
train2$extScore2[which(is.na(train2$extScore2))] <- extScore2.pred

###

extScore3.fit <- glm(extScore3 ~ contType + gender + carYN +
                       houseYN + chilNum + incomeAmou + loanAmou +
                       loanAnnu + goodPric + whoAcco +
                       education + marriStat + livingStat + regionPopu +
                       age + employDay + registDay + changeIdDay +
                       empPhoneYN + workPhoneYN + mobileContYN + homePhoneYN +
                       emailYN + occupation + famNum + regionRating + regionCityRating +
                       applyWeekday + applyHours + regionNPermCont + regionNPermWork +
                       regionNContWork + cityNPermCont + cityNPermWork + cityNContWork +
                       workOrg + extScore2, data = train2, family = gaussian)

extScore3.miss <- train2[which(is.na(train2$extScore3)), ]
extScore3.pred <- predict(extScore3.fit, newdata = extScore3.miss)
train2$extScore3[which(is.na(train2$extScore3))] <- extScore3.pred

###

extScore1.fit <- glm(extScore1 ~ contType + gender + carYN +
                       houseYN + chilNum + incomeAmou + loanAmou +
                       loanAnnu + goodPric + whoAcco +
                       education + marriStat + livingStat + regionPopu +
                       age + employDay + registDay + changeIdDay +
                       empPhoneYN + workPhoneYN + mobileContYN + homePhoneYN +
                       emailYN + occupation + famNum + regionRating + regionCityRating +
                       applyWeekday + applyHours + regionNPermCont + regionNPermWork +
                       regionNContWork + cityNPermCont + cityNPermWork + cityNContWork +
                       workOrg + extScore2 + extScore3, data = train2, family = gaussian)

extScore1.miss <- train2[which(is.na(train2$extScore1)), ]
extScore1.pred <- predict(extScore1.fit, newdata = extScore1.miss)
train2$extScore1[which(is.na(train2$extScore1))] <- extScore1.pred

###

train3 <- train2[-(which(is.na(train2$obsSocSur30))), ]
train3 <- train3[-(which(is.na(train3$reqCB1day))), ]
train3 <- train3[-(which(train3$whoAcco == '')), ]

train3$occupation <- as.character(train3$occupation)
train3$occupation[which(train3$occupation == '')] <- 'unknown'
train3$occupation <- as.factor(train3$occupation)

train3$gender <- as.character(train3$gender)
train3 <- train3[-which(train3$gender == 'XNA'), ]
train3$gender <- as.factor(train3$gender)

## test data prep

test2 <- test[, -(which(over50)-1)]
test2 <- data.frame(test2, extScore1 = test$extScore1)

sapply(test2, function(x) sum(is.na(x)))

test2$loanAnnu[which(is.na(test2$loanAnnu))] <-
  median(train2$loanAnnu, na.rm = T)

extScore2.miss.2 <- test2[which(is.na(test2$extScore2)), ]
extScore2.pred.2 <- predict(extScore2.fit, newdata = extScore2.miss.2)
test2$extScore2[which(is.na(test2$extScore2))] <- extScore2.pred.2

extScore3.miss.2 <- test2[which(is.na(test2$extScore3)), ]
extScore3.pred.2 <- predict(extScore3.fit, newdata = extScore3.miss.2)
test2$extScore3[which(is.na(test2$extScore3))] <- extScore3.pred.2

extScore1.miss.2 <- test2[which(is.na(test2$extScore1)), ]
extScore1.pred.2 <- predict(extScore1.fit, newdata = extScore1.miss.2)
test2$extScore1[which(is.na(test2$extScore1))] <- extScore1.pred.2

test2 <- within(test2, rm('doc2', 'doc4', 'doc7',
                            'doc10', 'doc12', 'mobileYN'))
test2 <- within(test2, rm('doc3', 'doc5', 'doc6', 'doc8', 'doc9',
                            'doc11', 'doc13', 'doc14', 'doc15', 'doc16',
                            'doc17', 'doc18', 'doc19', 'doc20', 'doc21'))
test2 <- within(test2, rm('yearExpAvg', 'entranceAvg', 'floorMaxAvg',
                            'livingAreaAvg', 'yearExpMode', 'entranceModde',
                            'floorMaxMode', 'livingAreaMode', 'yearExpMedi',
                            'entranceMedi', 'floormaxMedi', 'livingAreaMedi',
                            'totalAreaMode'))
test2 <- within(test2, rm('fondKarMode', 'houseTypeMode',
                            'wallMaterialMode', 'emergencyMode'))

test3 <- test2[-(which(is.na(test2$obsSocSur30))), ]
test3 <- test3[-(which(is.na(test3$reqCB1day))), ]

test3 <- test3[-(which(test3$whoAcco == '')), ]

test2$occupation <- as.character((test2$occupation))
test2$occupation[which(test2$occupation == '')] <- 'unknown'
test2$occupation <- as.factor(test2$occupation)

# Modelling

## Feature selections

filtered.model <- target ~ contType + gender + carYN + houseYN +
  chilNum + incomeAmou + loanAmou + loanAnnu + goodPric + whoAcco +
  incomeType + education + marriStat + livingStat + regionPopu +
  age + famNum + regionRating + regionCityRating + extScore2 + 
  extScore3
  
full <- glm(target ~ ., family = binomial(link='logit'), data = train3[1:5000, ])
filtered <- glm(filtered.model, family = binomial(link='logit'), data = train3[1:5000, ])
  
step(filtered, scope= list(lower = filtered, upper = full),
     direction = 'forward')

model <- target ~ contType + gender + carYN + houseYN + 
  chilNum + incomeAmou + loanAmou + loanAnnu + goodPric + # whoAcco + 
  incomeType + education + marriStat + livingStat + regionPopu + 
  age + famNum + regionRating + regionCityRating + extScore2 + 
  extScore3 + employDay + defSocSur30 + changeIdDay + extScore1 + 
  regionNContWork + occupation




fit.glm <- glm(model, family = binomial(link = 'logit'), data = train3)
# table(ifelse(a <= 0.0578555, 1, 0))


rf.grid <- expand.grid(.mtry = 2:9)
fit.rf <- train(model, data = train3,
                method = 'rf', ntree = 400,
                tuneGrid = rf.grid,
                trControl = trainControl(method = 'CV',
                                         number = 5))

fit.rf$results
max(fit.rf$results[, 'Accuracy'])


model <- target ~ contType + gender + carYN + houseYN + childNum +
  loanAmou + loanAnnu + goodPric + education + marriStat + age +
  regionRating + regionCityRating + extScore2 + extScore3 +
  employDay + defSocSur30 + changeIdDay + extScore1 + regionNContWork +
  occupation

rpart.grid <- expand.grid(.cp = seq(0.001, 0.02, by = 0.001))
fit.rpart <- train(model, data = train3,
                   method = 'rpart',
                   tuneGrid = rpart.grid,
                   trControl = trainControl(method = 'CV',
                                            number = 5))

fit.rpart$results
max(fit.rpart$results[, 'Accuracy'])


# Prediction

a.glm <- predict(fit.glm, newdata = test2, type = 'response')
class <- ifelse(a.glm <= 0.0578555, 1, 0)

class[which(is.na(class))] <- c(1, 0, 0, 0, 0,
                                1, 0, 0, 0, 0,
                                1, 0, 0, 0, 0,
                                0, 0, 0, 0, 1,
                                0, 1, 0, 1, 1,
                                1, 1, 1, 1)

submit <- data.frame('SK_ID_CURR' = test2$id, 'TARGET' = class)
write.csv(submit, 'glm1.csv', row.names = F)
# 0.335...


