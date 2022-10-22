# %%
import pandas as pd
import numpy as np
import pickle

from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold

from sklearn.feature_extraction import DictVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score


## parameters
C=1.0
n_splits = 5
op_file = f'model_C={C}.bin'


## reading data set
df = pd.read_csv('WA_Fn-UseC_-Telco-Customer-Churn.csv')
print('Read input dataset')

## data prep - EDA & feature engineering
print('Data prep - in progress')
df.columns = df.columns.str.lower().str.replace(' ','_')

categorical_columns = list(df.dtypes[df.dtypes == 'object'].index)

for c in categorical_columns:
    df[c] = df[c].str.lower().str.replace(' ','_')


df.totalcharges = pd.to_numeric(df.totalcharges, errors='coerce')
df.totalcharges = df.totalcharges.fillna(0)


df.churn = (df.churn == 'yes').astype(int)


df_full_train, df_test = train_test_split(df, test_size=0.2, random_state=1)


numeric  = ['tenure', 'monthlycharges', 'totalcharges']
categorical = ['gender', 'seniorcitizen', 'partner', 'dependents',
       'phoneservice', 'multiplelines', 'internetservice',
       'onlinesecurity', 'onlinebackup', 'deviceprotection', 'techsupport',
       'streamingtv', 'streamingmovies', 'contract', 'paperlessbilling',
       'paymentmethod']

print('Data prep - complete')

## training the model
def train(df_train, y_train, C=1.0):
    dicts = df_train[categorical + numeric].to_dict(orient='records')

    dv = DictVectorizer(sparse=False)
    X_train = dv.fit_transform(dicts)

    model = LogisticRegression(C=C, max_iter=1000)
    model.fit(X_train, y_train)

    return dv, model

def predict(df, dv, model):
    dicts = df[categorical + numeric].to_dict(orient='records')

    X = dv.transform(dicts)
    y_pred = model.predict_proba(X)[:,1]

    return y_pred




kfold = KFold(n_splits=n_splits, shuffle=True, random_state=1)

scores = []
folds = 0

for train_idx, val_idx in kfold.split(df_full_train):
    df_train = df_full_train.iloc[train_idx]
    df_val = df_full_train.iloc[val_idx]

    y_train = df_train.churn.values
    y_val = df_val.churn.values


    dv, model = train(df_train, y_train, C=C)

    y_pred = predict(df_val,dv, model)

    auc = roc_auc_score(y_val,y_pred)

    scores.append(auc)

    print(f'For fold {folds}, the score : {auc}')
    
    folds += 1

print(f'C = {C} {np.mean(scores):.3f} +- {np.std(scores):.3f}')

print('Model training is complete.')

## Testing the model

y_test = df_test.churn.values
dv, model = train(df_full_train, df_full_train.churn.values, C)
y_pred = predict(df_test, dv, model)
auc = roc_auc_score(y_test, y_pred)

print(f'Score of the model against testing data : {auc}')



## saving the model
with open(op_file, 'wb') as f_out:
    pickle.dump((dv, model), f_out)


print(f'Saved the model at : {op_file}')
