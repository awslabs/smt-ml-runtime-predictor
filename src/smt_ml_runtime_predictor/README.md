# SMT-ML-Runtime-Predictor

A machine learning-based runtime predictor for SMT solvers.

# How to run the code

The repository contains features and labels of CVC5 and Z3 and you can directly open the notebook predict.ipynb to train a predictor, make predictions and perform analysis.

## Feature reproduction

We collect features from the output of CVC5/Z3 when solving
benchmarks. To get the data, update script `run_solver_feature.sh`to
fit your needs then run it:
```
./run_solver_feature.sh
```
By default, the script assumes specific benchmarks in different directories. It also requires that cvc5 and z3 are in your $path.

To reproduce features, run the following command:
```
./collect_features.sh solver_name rlimit/10k random_seed
```

### Example

To reproduce online features of CVC5 as rlimit=10k and random seed=0, run:
```
./collect_features.sh cvc5 1 0
```

To reproduce online features of Z3 as rlimit=20k and random seed=0, run:
```
./collect_features.sh z3 2 0
```

To reproduce syntactic features, run:
```
./collect_features.sh syntactic
```

To reproduce online features for testing stability against random seeds, run:
```
./collect_features_stability.sh
```

## Label reproduction

We collect labels from the output of CVC5/Z3 when solving benchmarks. You can use
```
python run_solver_label.py
```
Again, this pythin script can be edited to select benchmark directories.
Please make sure cvc5 and z3 have been added to your $path.

To reproduce labels, run the following command:
```
./collect_labels.sh solver_name random_seed
```

### Example

To reproduce labels of CVC5 as random seed=0, run:
```
./collect_labels.sh cvc5 0
```

To reproduce labels of Z3 as random seed=0, run:
```
./collect_labels.sh z3 0
```

To reproduce labels for testing stability against random seeds, run:
```
./collect_labels_stability.sh
```

## Feature extension

To add a new feature, you can add a new item in the feature list of  collect_features.sh for CVC5/Z3.

### Example

To add a new simple feature for CVC5:

* Feature: “sat::starts = 0”
* Updated line 59: features=( sat::conflicts sat::decisions ... sat::starts )

To add a new structural feature for CVC5:

* Feature: CTN_CONST in “theory::strings::rewrites = { CTN_CONST: 1, LEN_EVAL: 1 }“
* Updated line 72: feature_family=( resource::steps::resource resource::steps::resource theory::strings::rewrites )
* Updated line 73: features=( PreprocessStep RewriteStep CTN_CONST )

To add a new feature for Z3:

* Feature: “ :arith-upper 174”
* Updated line 104: features=( conflicts decisions ... arith-upper)

## Benchmark extension

If you want to run experiments on new benchmarks, please add them in the directory benchmarks and change the path to benchmarks in scripts denoted by variable dir_benchmark:

* run_solver_feature.sh: Line 29
* run_solver_label.py: Line 5

After running the previous two scripts to collect outputs from the solver on new benchmarks, you can follow the instructions in feature reproduction and label reproduction to produce features and labels on the new benchmarks. Remember to update the variable dir_benchmark in the following two scripts as well:

* collect_features.sh: Line 16
* collect_labels.sh: Line 16

## Demo

Before running the demo, you have to train a predictor in predict.ipynb and change the path to the saved model in run_predictor_demo.py: Line 7. You can find the path in the cell after “test results” in predict.ipynb.

You can run demo.sh to extract features and make a prediction on the given input for CVC5, for example, the following case is predicted to be an intermediate problem: 
 
```
$ ./demo.sh demo-cases/case-3.smt2 
> collecting syntactic features ...
> collecting online features for CVC5 as rlimit=50k ...
> 
> Feature-collecting time: 214 ms
> Prediction: intermediate problem, 1 s < runtime <= 100 s.
```

You can run the following command and find that CVC5 actually used around 2 s to solve it. So it’s a correct prediction!

```
$ cvc5 demo-cases/case-3.smt2 —stats
> ...
> global::totalTime = 1699ms
> ...
```

