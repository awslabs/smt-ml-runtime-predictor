########################################
##
## predict the runtime for CVC5 to solve the given SMT problem
##
## $1: an SMT problem
########################################

filename="$1"
log=$( cvc5 $filename --stats-all --stats-internal --rlimit=50000 --tlimit=1000 --seed=0 2>&1 )
# echo "$log"

# collect features

out="demo.csv"

echo "collecting syntactic features ... "

# features(cvc5::TERM): SUB STRING_CONTAINS STRING_TO_REGEXP STRING_SUBSTR STRING_SUFFIX GT REGEXP_OPT STRING_REPLACE ITE REGEXP_RANGE REGEXP_CONCAT INTS_DIVISION REGEXP_PLUS IMPLIES LEQ STRING_CHARAT LT REGEXP_UNION STRING_PREFIX MULT REGEXP_STAR STRING_INDEXOF STRING_FROM_INT STRING_CONCAT EQUAL NOT STRING_TO_INT REGEXP_COMPLEMENT NEG REGEXP_INTER GEQ OR STRING_IN_REGEXP STRING_LENGTH AND ADD
features=( SUB STRING_CONTAINS STRING_TO_REGEXP STRING_SUBSTR STRING_SUFFIX GT REGEXP_OPT STRING_REPLACE ITE REGEXP_RANGE REGEXP_CONCAT INTS_DIVISION REGEXP_PLUS IMPLIES LEQ STRING_CHARAT LT REGEXP_UNION STRING_PREFIX MULT REGEXP_STAR STRING_INDEXOF STRING_FROM_INT STRING_CONCAT EQUAL NOT STRING_TO_INT REGEXP_COMPLEMENT NEG REGEXP_INTER GEQ OR STRING_IN_REGEXP STRING_LENGTH AND ADD )	

# initialize feature file
> $out
for idx in "${!features[@]}"
do
	echo -n syntactic-cvc5::TERM-${features[$idx]}, >> $out
	# grep files with match
	echo "$log" | grep -H -m 1 "cvc5::TERM =" | sed 's/:/ /1' | while IFS=', ' read -ra arr ; do findterm=0; for i in "${!arr[@]}"; do if [ ${arr[i]} = "${features[$idx]}:" ]; then echo -n ${arr[i+1]} >> $out ; findterm=1; fi done; if [ $findterm = 0 ]; then echo -n "0" >> $out; fi done
	echo "" >> $out
done

echo "collecting online features for CVC5 as rlimit=50k ... "

# features: #conflict #decision instantiations_total termsCount resource_preprocess resource_rewrite resource_units 
# string features: checkRuns conflicts ee::mergesCount ee::termsCount lemmas propagations requirePhase restartDemands strategyRuns
# statistics: global::totalTime

features=( sat::conflicts sat::decisions Instantiate::Instantiations_Total shared::ee::termsCount resource::resourceUnitsUsed theory::strings::checkRuns theory::strings::conflicts theory::strings::ee::mergesCount theory::strings::ee::termsCount theory::strings::lemmas theory::strings::propagations theory::strings::requirePhase theory::strings::restartDemands theory::strings::strategyRuns global::totalTime )

for feat in "${features[@]}"
do
	echo -n cvc5-${feat}, >> $out
	# grep files with match
	echo "$log" | grep -H -m 1 "${feat} =" | sed 's/:/ /1' | awk '{ printf "%d", $5 }' >> $out
	# grep files without match
	echo "" >> $out
done

# collect structural features

feature_family=( resource::steps::resource resource::steps::resource )
features=( PreprocessStep RewriteStep )

for idx in "${!features[@]}"
do
	echo -n cvc5-${feature_family[$idx]}-${features[$idx]}, >> $out
	# grep files with match
	echo "$log" | grep -H -m 1 "${feature_family[$idx]} =" | sed 's/:/ /1' | while IFS=', ' read -ra arr ; do findterm=0; for i in "${!arr[@]}"; do if [ ${arr[i]} = "${features[$idx]}:" ]; then echo -n ${arr[i+1]} >> $out; findterm=1; fi done; if [ $findterm = 0 ]; then echo -n "0" >> $out; fi done
	echo "" >> $out
done

# collect outcome

labels=( sat unsat )

for label in "${labels[@]}"
do
	echo -n cvc5-${label}, >> $out
	echo "$log" | grep -xcH -m 1 ${label} | sed 's/:/ /1' | awk '{ print $3 }' >> $out
done

echo ""

# predict
python run_predictor_demo.py

# clean
rm $out 
