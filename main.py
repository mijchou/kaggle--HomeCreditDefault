def print_full(dataframe):
    """Print full columns and rows."""
    with pd.option_context('display.max_columns', None,
                           'display.max_rows', None):
        print(dataframe)

def vif(dataframe):
    """Return VIF value of each feature. Check var !=0 before use."""
    df = dataframe.dropna()
    df = df._get_numeric_data()
    
    l = list()
    for column in multicor_df.columns:
        l.append(multicor_df[column].tolist())
        
    ck = np.column_stack(l)
    cc = sp.corrcoef(ck, rowvar=False)
    VIF = np.linalg.inv(cc)
    return VIF.diagonal()



# Setups

import os

os.chdir(r'D:\Users\NT80199\Desktop\Projects\project3\datasets')

import numpy as np
import pandas as pd
import scipy as sp

train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')
bureau = pd.read_csv('bureau_sub.csv')

# check variance
##### print_full(train.var() == 0)

del train['SK_ID_CURR']
del train['FLAG_MOBIL']
del train['FLAG_DOCUMENT_2']
del train['FLAG_DOCUMENT_7']
del train['FLAG_DOCUMENT_10']
del train['FLAG_DOCUMENT_12']

y = train.pop('TARGET')

# Split into different areas: personal and house related

X_house = train.iloc[:, 38:92]
X_personal = train.drop(columns = X_house)

################## Personal

# process: address not match

notmatch = X_personal.filter(regex='NOT')
X_personal = X_personal.drop(columns=notmatch)

notmatch['target'] = y
notmatch_city = notmatch.filter(regex='CITY').sum(axis=1).tolist()
notmatch_region = notmatch.filter(regex='REGION').sum(axis=1).tolist()
notmatch.LIVE_REGION_NOT_WORK_REGION = abs(notmatch.LIVE_REGION_NOT_WORK_REGION - 1) #important
notmatch_all = notmatch.sum(axis=1).tolist()
notmatch['notmatch_city'] = notmatch_city
notmatch['notmatch_regions'] = notmatch_region
notmatch['notmatch_all'] = notmatch_all ### GOOD!

########notmatch.corr().target

X_personal['notmatch'] = notmatch.pop('notmatch_all')

# process documents

X_documents = X_personal.filter(regex='FLAG_DOCUMENT')
X_personal = X_personal.drop(columns = X_documents)

#X_documents['target'] = y
#X_documents.var() == 0
#X_documents.corr().target
# del X_documents['target']

X_documents.FLAG_DOCUMENT_3 = abs(X_documents.FLAG_DOCUMENT_3 - 1)
X_documents.FLAG_DOCUMENT_13 = abs(X_documents.FLAG_DOCUMENT_13 - 1)
X_documents.FLAG_DOCUMENT_16 = abs(X_documents.FLAG_DOCUMENT_16 - 1)
X_documents.FLAG_DOCUMENT_18 = abs(X_documents.FLAG_DOCUMENT_18 - 1)
X_documents.FLAG_DOCUMENT_19 = abs(X_documents.FLAG_DOCUMENT_19 - 1)

doc_number = X_documents.sum(axis=1).tolist()
X_documents['doc_number'] = doc_number
###### X_documents.corr().target # GOOD!
X_personal['doc_number'] = X_documents.pop('doc_number')

# VIF: checking multicollinearity (personal informations)

multicor_df = X_personal.dropna()
multicor_df = multicor_df._get_numeric_data()
# len(multicor_df) # vif still useful for detection
print_full(multicor_df.var() == 0)

l = list()
for column in multicor_df.columns:
    l.append(multicor_df[column].tolist())

ck = np.column_stack(l)
cc = sp.corrcoef(ck, rowvar=False)
VIF = np.linalg.inv(cc)
VIF.diagonal()

del X_personal['AMT_GOODS_PRICE']
del X_personal['REGION_RATING_CLIENT_W_CITY']

##################

# How much more money did the client borrow than the actual needs for house?

excess_amt = train.AMT_CREDIT - train.AMT_GOODS_PRICE
excess = excess_amt > 0

X_personal['excess_amt'] = excess_amt
X_personal['excess'] = excess

##################

####### req_beureau = X_personal.iloc[:, 31:37]
####### do this later: aggregate records requested amount

################## house

# Select stats of averages

mod_df = X_house.filter(regex = 'MODE')
med_df = X_house.filter(regex = 'MEDI')
X_house = X_house.drop(columns = mod_df)
X_house = X_house.drop(columns = med_df)


multicor_df = X_house.filter(regex = 'AVG')
multicor_df = multicor_df.dropna()
multicor_df = multicor_df._get_numeric_data()
print_full(multicor_df.var() == 0)

l = list()
for column in multicor_df.columns:
    l.append(multicor_df[column].tolist())

ck = np.column_stack(l)
cc = sp.corrcoef(ck, rowvar=False)
VIF = np.linalg.inv(cc)
VIF.diagonal()

del X_house['LIVINGAPARTMENTS_AVG']
del X_house['LIVINGAREA_AVG']

#######

multicor_df = X_house.dropna()
multicor_df = multicor_df._get_numeric_data()
print_full(multicor_df.var() == 0)

l = list()
for column in multicor_df.columns:
    l.append(multicor_df[column].tolist())

ck = np.column_stack(l)
cc = sp.corrcoef(ck, rowvar=False)
VIF = np.linalg.inv(cc)
VIF.diagonal()

del X_house['YEARS_BEGINEXPLUATATION_AVG']
del X_house['OBS_60_CNT_SOCIAL_CIRCLE']
del X_house['DEF_60_CNT_SOCIAL_CIRCLE']

###################

train = pd.concat([X_personal, X_house], axis=1)
print_full(train.isnull().sum())

###################

##### modelling for house characteristics 

house_avg = train.filter(regex='AVG')
##### train.LANDAREA_AVG.isnull().sum()

train['missing_apartments'] = train.APARTMENTS_AVG.isnull()
train['missing_basementarea'] = train.BASEMENTAREA_AVG.isnull()
train['missing_yearsbuild'] = train.YEARS_BUILD_AVG.isnull()
train['missing_commonarea'] = train.COMMONAREA_AVG.isnull()
train['missing_elevators'] = train.ELEVATORS_AVG.isnull()
train['missing_entrances'] = train.ENTRANCES_AVG.isnull()
train['missing_floorsmax'] = train.FLOORSMAX_AVG.isnull()
train['missing_floorsmin'] = train.FLOORSMIN_AVG.isnull()
train['missing_landarea'] = train.LANDAREA_AVG.isnull()
train['missing_nonlivingapartments'] = train.NONLIVINGAPARTMENTS_AVG.isnull()
train['missing_nonlivingarea'] = train.NONLIVINGAREA_AVG.isnull()

train = train.drop(columns=house_avg)

########### train EXT_SOURCE


abs(train.corr().EXT_SOURCE_1) > 0.1

EXT_1_train = train[train.EXT_SOURCE_1.isnull() == False]
EXT_1_missing = train[train.EXT_SOURCE_1.isnull()]

##

y_EXT_1 = EXT_1_train.filter(['EXT_SOURCE_1'])
X_EXT_1 = EXT_1_train.filter(['CNT_CHILDREN', 'AMT_CREDIT', 'AMT_ANNUITY',
                              'DAYS_BIRTH', 'DAYS_EMPLOYED', 'DAYS_REGISTRATION',
                              'DAYS_ID_PUBLISH', 'FLAG_EMP_PHONE',
                              'REGION_RATING_CLIENT', 'DAYS_LAST_PHONE_CHANGE',
                              'notmatch',
                              'missing_apartments', 'missing_elevators',
                              'missing_entrances', 'missing_floorsmax',
                              'missing_nonlivingarea'])
X_EXT_1_impute = EXT_1_missing.filter(['CNT_CHILDREN', 'AMT_CREDIT', 'AMT_ANNUITY',
                                'DAYS_BIRTH', 'DAYS_EMPLOYED', 'DAYS_REGISTRATION',
                                'DAYS_ID_PUBLISH', 'FLAG_EMP_PHONE',
                                'REGION_RATING_CLIENT', 'DAYS_LAST_PHONE_CHANGE',
                                'notmatch',
                                'missing_apartments', 'missing_elevators',
                                'missing_entrances', 'missing_floorsmax',
                                'missing_nonlivingarea'])

print_full(X_EXT_1.isnull().sum())
print_full(y_EXT_1.isnull().sum())

from sklearn.tree import DecisionTreeRegressor

EXT1_reg = DecisionTreeRegressor(random_state=0)
EXT1_reg.fit(X_EXT_1, y_EXT_1)

EXT1_reg.predict(X_EXT_1_impute)
train.EXT_SOURCE_1[train.EXT_SOURCE_1.isnull()] = EXT1_reg.predict(X_EXT_1_impute)

## 

from sklearn.impute import SimpleImputer

EXT = train.filter(regex='EXT')
imp = SimpleImputer(strategy='most_frequent')
ext_imp = pd.DataFrame(imp.fit_transform(EXT), columns = ['e1', 'e2', 'e3'])
train = pd.concat([train, ext_imp], axis=1)










print_full(X_personal.head(5))
X_personal.NAME_CONTRACT_TYPE.value_counts()
X_personal.CODE_GENDER.value_counts()
X_personal.FLAG_OWN_CAR.value_counts()
X_personal.FLAG_OWN_REALTY.value_counts()
X_personal.NAME_CONTRACT_TYPE.value_counts()
X_personal.NAME_CONTRACT_TYPE.value_counts()

X_personal.isn().counts()

###################






######## 

X_enqnumber = X_personal.iloc[:, 39:45]
X_personal = X_personal.drop(columns = X_enqnumber)
X_enqnumber['target'] = y
X_enqnumber.apply(set)
X_enqnumber.isnull().sum()
X_enqnumber.corr()

test = X_enqnumber.isnull()
test['target'] = y
test.corr()

X_enqnumber.corr()


multicor_df = train.dropna()
multicor_df = multicor_df._get_numeric_data()
print_full(multicor_df.var() == 0)

del multicor_df['FLAG_CONT_MOBILE']
del multicor_df['FLAG_DOCUMENT_4']
del multicor_df['FLAG_DOCUMENT_9']
del multicor_df['FLAG_DOCUMENT_15']
del multicor_df['FLAG_DOCUMENT_16']
del multicor_df['FLAG_DOCUMENT_17']
del multicor_df['FLAG_DOCUMENT_19']
del multicor_df['FLAG_DOCUMENT_20']
del multicor_df['FLAG_DOCUMENT_21']

l = list()
for column in multicor_df.columns:
    l.append(multicor_df[column].tolist())

ck = np.column_stack(l)
cc = sp.corrcoef(ck, rowvar=False)
VIF = np.linalg.inv(cc)
VIF.diagonal()

# check missing values
print_full(train.isnull().sum())

########





from sklearn.tree import DecisionTreeClassifier

estimator = DecisionTreeClassifier(random_state=0)
estimator.fit(X_documents, y)
n_nodes = estimator.tree_.node_count
importance = estimator.tree_.compute_feature_importances(normalize=False)
importance
