from autogluon.tabular import TabularPredictor
import pandas as pd

model = 'LightGBM'

# load saved model
predictor = TabularPredictor.load('AutogluonModels/ag-20220726_053051/')

# load normalization parameters
features_mean = pd.read_pickle('features-mean.pkl')
features_std = pd.read_pickle('features-std.pkl')

# load features
df = pd.read_csv("demo.csv", names=['feature-id', 'value'], index_col=0)
df = df.T.reset_index(drop=True)

# check if the problem has been solved during collecting features
if df['cvc5-sat'].any():
    print(f'Solved during collecting online features:\nSAT\nsolving time: {df.loc[0, "cvc5-global::totalTime"]} ms')
elif df['cvc5-unsat'].any():
    print(f'Solved during collecting online features:\nUNSAT\nsolving time: {df.loc[0, "cvc5-global::totalTime"]} ms')
else:
    print(f'Feature-collecting time: {df.loc[0, "cvc5-global::totalTime"]} ms')

    # drop non-feature inputs
    feature = df.drop(['cvc5-sat', 'cvc5-unsat', 'cvc5-global::totalTime'], axis=1, errors='ignore')
    # normalization
    feature = (feature-features_mean)/features_std    
    # predict
    pred = predictor.predict(feature, model=model)

    # print prediction
    if pred[0] == 0:
        print('Prediction: easy problem, runtime <= 1 s.')
    elif pred[0] == 1:
        print('Prediction: intermediate problem, 1 s < runtime <= 100 s.')
    elif pred[0] == 2:
        print('Prediction: hard problem, runtime > 100 s.')
    else:
        print('Prediction Error.')

