
names(raw) <- c('id', 'contType', 'gender', 'carYN',
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


raw$mobileYN <- as.factor(raw$mobileYN)
raw$empPhoneYN <- as.factor(raw$empPhoneYN)
raw$workPhoneYN <- as.factor(raw$workPhoneYN)
raw$mobileContYN <- as.factor(raw$mobileContYN)
raw$homePhoneYN <- as.factor(raw$homePhoneYN)
raw$emailYN <- as.factor(raw$emailYN)

raw$regionNPermCont <- as.factor(raw$regionNPermCont)
raw$regionNPermWork <- as.factor(raw$regionNPermWork)
raw$regionNContWork <- as.factor(raw$regionNContWork)
raw$cityNPermCont <- as.factor(raw$cityNPermCont)
raw$cityNPermWork <- as.factor(raw$cityNPermWork)
raw$cityNContWork <- as.factor(raw$cityNContWork)

