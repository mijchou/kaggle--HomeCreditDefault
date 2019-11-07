import os
os.chdir(r'D:\Users\NT80199\Desktop\Projects\project3\datasets')

# Setups

import numpy as np
import pandas as pd
import scipy as sp

train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')
bureau = pd.read_csv('bureau_sub.csv')

# Pop y

y = train.pop('TARGET')

# Drop features not needed

del train['SK_ID_CURR']
del train['FLAG_MOBIL']
del train['FLAG_DOCUMENT_2']
del train['FLAG_DOCUMENT_7']
del train['FLAG_DOCUMENT_10']
del train['FLAG_DOCUMENT_12']
del train['REGION_RATING_CLIENT_W_CITY']
del train['LIVINGAPARTMENTS_AVG']
del train['LIVINGAREA_AVG']
del train['YEARS_BEGINEXPLUATATION_AVG']
del train['OBS_60_CNT_SOCIAL_CIRCLE']
del train['DEF_60_CNT_SOCIAL_CIRCLE']

mod_df = train.filter(regex = 'MODE')
med_df = train.filter(regex = 'MEDI')
train = train.drop(columns = mod_df)
train = train.drop(columns = med_df)

# Process address not match

notmatch = train.filter(regex='NOT')
train = train.drop(columns=notmatch)

notmatch_city = notmatch.filter(regex='CITY').sum(axis=1).tolist()
notmatch_region = notmatch.filter(regex='REGION').sum(axis=1).tolist()
notmatch.LIVE_REGION_NOT_WORK_REGION = abs(notmatch.LIVE_REGION_NOT_WORK_REGION - 1) #important
notmatch_all = notmatch.sum(axis=1).tolist()
train['notmatch_city'] = notmatch_city
train['notmatch_regions'] = notmatch_region
train['notmatch_all'] = notmatch_all ### GOOD!

# Process documents recieved

documents = train.filter(regex='FLAG_DOCUMENT')
train = train.drop(columns = documents)

documents.FLAG_DOCUMENT_3 = abs(documents.FLAG_DOCUMENT_3 - 1)
documents.FLAG_DOCUMENT_13 = abs(documents.FLAG_DOCUMENT_13 - 1)
documents.FLAG_DOCUMENT_16 = abs(documents.FLAG_DOCUMENT_16 - 1)
documents.FLAG_DOCUMENT_18 = abs(documents.FLAG_DOCUMENT_18 - 1)
documents.FLAG_DOCUMENT_19 = abs(documents.FLAG_DOCUMENT_19 - 1)

doc_number = documents.sum(axis=1).tolist()
train['doc_number'] = doc_number

# How much more money did the client borrow than the actual needs for house?

excess_amt = train.AMT_CREDIT - train.AMT_GOODS_PRICE
excess = excess_amt > 0
train['excess_amt'] = excess_amt
train['excess'] = excess

del train['AMT_GOODS_PRICE']
del train['AMT_CREDIT']

# Missing house informations

house_avg = train.filter(regex='AVG')

train['missing_apartments'] = train.APARTMENTS_AVG.isnull().astype(int)
train['missing_basementarea'] = train.BASEMENTAREA_AVG.isnull().astype(int)
train['missing_yearsbuild'] = train.YEARS_BUILD_AVG.isnull().astype(int)
train['missing_commonarea'] = train.COMMONAREA_AVG.isnull().astype(int)
train['missing_elevators'] = train.ELEVATORS_AVG.isnull().astype(int)
train['missing_entrances'] = train.ENTRANCES_AVG.isnull().astype(int)
train['missing_floorsmax'] = train.FLOORSMAX_AVG.isnull().astype(int)
train['missing_floorsmin'] = train.FLOORSMIN_AVG.isnull().astype(int)
train['missing_landarea'] = train.LANDAREA_AVG.isnull().astype(int)
train['missing_nonlivingapartments'] = train.NONLIVINGAPARTMENTS_AVG.isnull().astype(int)
train['missing_nonlivingarea'] = train.NONLIVINGAREA_AVG.isnull().astype(int)

train = train.drop(columns=house_avg)

# Missing External resources

from sklearn.impute import SimpleImputer

ext = train.filter(regex='EXT')
imp = SimpleImputer(strategy='median')
ext_imp = pd.DataFrame(imp.fit_transform(ext), columns = ['e1', 'e2', 'e3'])
train = train.drop(columns=ext)
train = pd.concat([train, ext_imp], axis=1)

# Missing observed social circle

obs = train[['OBS_30_CNT_SOCIAL_CIRCLE', 'DEF_30_CNT_SOCIAL_CIRCLE']]
imp = SimpleImputer(strategy='median')
obs_imp = pd.DataFrame(imp.fit_transform(obs), columns = ['obs30', 'def30'])
train = train.drop(columns=obs)
train = pd.concat([train, obs_imp], axis=1)


#  Missing categorical variables

accomp = train[['NAME_TYPE_SUITE', 'OCCUPATION_TYPE']]
imp = SimpleImputer(strategy='most_frequent')
accomp_imp = pd.DataFrame(imp.fit_transform(accomp), columns = ['accomp', 'occup'])
train = train.drop(columns=accomp)
train = pd.concat([train, accomp_imp], axis=1)

# Missing requested number

req = train[['AMT_REQ_CREDIT_BUREAU_HOUR', 'AMT_REQ_CREDIT_BUREAU_DAY',
             'AMT_REQ_CREDIT_BUREAU_WEEK', 'AMT_REQ_CREDIT_BUREAU_MON',
             'AMT_REQ_CREDIT_BUREAU_QRT', 'AMT_REQ_CREDIT_BUREAU_YEAR']]
imp = SimpleImputer(strategy='median')
req_imp = pd.DataFrame(imp.fit_transform(req), columns = ['hour', 'day',
                                                          'week', 'mon',
                                                          'qrt', 'year'])
train = train.drop(columns=req)
train = pd.concat([train, req_imp], axis=1)

# Missing excessive amount and car age

num = train[['OWN_CAR_AGE', 'excess_amt']]
imp = SimpleImputer(strategy='median')
num_imp = pd.DataFrame(imp.fit_transform(num), columns = ['car_age', 'excess_amt'])
train = train.drop(columns=num)
train = pd.concat([train, num_imp], axis=1)

# Label Encoding (for trees)

from sklearn.preprocessing import LabelEncoder
encoder = LabelEncoder()
cat = train[['NAME_CONTRACT_TYPE', 'CODE_GENDER',
                             'FLAG_OWN_CAR', 'FLAG_OWN_REALTY',
                             'NAME_INCOME_TYPE', 'NAME_EDUCATION_TYPE',
                             'NAME_FAMILY_STATUS', 'NAME_HOUSING_TYPE',
                             'WEEKDAY_APPR_PROCESS_START', 'ORGANIZATION_TYPE',
                             'accomp', 'occup']]
train = train.drop(columns=cat)
cat_encoded = cat.apply(LabelEncoder().fit_transform)
train = pd.concat([train, cat_encoded], axis=1)

# Modeling: bagging

from sklearn.ensemble import BaggingClassifier

classifier = BaggingClassifier(base_estimator=None)
classifier.fit(train, y)
classifier.predict(train)





















