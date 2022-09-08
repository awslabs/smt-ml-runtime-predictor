########################################
##
## collect performance features from outputs of solvers running on each benchmark
##
## $1: solver name in {cvc5, z3, syntactic}
## $2: rlimit
## $3: random seed
## $4: test stability if it's true, otherwise false
########################################

solver=$1
rlimit=$2
seed=$3
stability=$4

dir_benchmark="./SMT-LIB"

if [ $solver = "syntactic" ]
then
	echo "collecting syntactic features ... "

	mkdir -p "features/syntactic"
	cd solver-output/syntactic-feature/cvc5
	dir_features="../../../features/syntactic"

	# features(cvc5::TERM): SUB STRING_CONTAINS STRING_TO_REGEXP STRING_SUBSTR STRING_SUFFIX GT REGEXP_OPT STRING_REPLACE ITE REGEXP_RANGE REGEXP_CONCAT INTS_DIVISION REGEXP_PLUS IMPLIES LEQ STRING_CHARAT LT REGEXP_UNION STRING_PREFIX MULT REGEXP_STAR STRING_INDEXOF STRING_FROM_INT STRING_CONCAT EQUAL NOT STRING_TO_INT REGEXP_COMPLEMENT NEG REGEXP_INTER GEQ OR STRING_IN_REGEXP STRING_LENGTH AND ADD
	features=( SUB STRING_CONTAINS STRING_TO_REGEXP STRING_SUBSTR STRING_SUFFIX GT REGEXP_OPT STRING_REPLACE ITE REGEXP_RANGE REGEXP_CONCAT INTS_DIVISION REGEXP_PLUS IMPLIES LEQ STRING_CHARAT LT REGEXP_UNION STRING_PREFIX MULT REGEXP_STAR STRING_INDEXOF STRING_FROM_INT STRING_CONCAT EQUAL NOT STRING_TO_INT REGEXP_COMPLEMENT NEG REGEXP_INTER GEQ OR STRING_IN_REGEXP STRING_LENGTH AND ADD )	

	for idx in "${!features[@]}"
	do
		# initialize feature file
		> $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv
		# grep files with match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -H -m 1 "cvc5::TERM =" | sed 's/:/ /1' | while IFS=', ' read -ra arr ; do echo -n "${arr}," >> $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv; findterm=0; for i in "${!arr[@]}"; do if [ ${arr[i]} = "${features[$idx]}:" ]; then echo ${arr[i+1]} >> $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv ; findterm=1; fi done; if [ $findterm = 0 ]; then echo "0" >> $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv; fi done
		# grep files without match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -L "cvc5::TERM =" | awk '{ print $1"," }' >> $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv 	
		sort -o $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv $dir_features/${solver}-cvc5::TERM-${features[$idx]}.csv
	done

elif [ $solver = "cvc5" ]
then
	echo "collecting online features for ${solver} as rlimit=${rlimit}0k and seed=${seed} ... "

	if [ "$stability" = true ]
	then
		mkdir -p "features/stability/seed-${seed}"
		cd solver-output/online-feature/rlimit-${rlimit}/${solver}/seed-${seed}
		dir_features="../../../../../features/stability/seed-${seed}"
	else
		mkdir -p "features/online/rlimit-${rlimit}"
		cd solver-output/online-feature/rlimit-${rlimit}/${solver}/seed-${seed}
		dir_features="../../../../../features/online/rlimit-${rlimit}"
	fi

	# features: #conflict #decision instantiations_total termsCount resource_preprocess resource_rewrite resource_units 
	# string features: checkRuns conflicts ee::mergesCount ee::termsCount lemmas propagations requirePhase restartDemands strategyRuns
	# statistics: global::totalTime

	features=( sat::conflicts sat::decisions Instantiate::Instantiations_Total shared::ee::termsCount resource::resourceUnitsUsed theory::strings::checkRuns theory::strings::conflicts theory::strings::ee::mergesCount theory::strings::ee::termsCount theory::strings::lemmas theory::strings::propagations theory::strings::requirePhase theory::strings::restartDemands theory::strings::strategyRuns global::totalTime )

	for feat in "${features[@]}"
	do
		# grep files with match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -H -m 1 "${feat} =" | sed 's/:/ /1' | awk '{ printf "%s,%d\n", $1, $4 }' > $dir_features/${solver}-${feat}.csv
		# grep files without match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -L "${feat} =" | awk '{ print $1"," }' >> $dir_features/${solver}-${feat}.csv
		sort -o $dir_features/${solver}-${feat}.csv $dir_features/${solver}-${feat}.csv
	done

	# collect structural features
	
	feature_family=( resource::steps::resource resource::steps::resource )
	features=( PreprocessStep RewriteStep )

	for idx in "${!features[@]}"
	do
		# initialize feature file
		> $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv
		# grep files with match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -H -m 1 "${feature_family[$idx]} =" | sed 's/:/ /1' | while IFS=', ' read -ra arr ; do echo -n "${arr}," >> $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv; for i in "${!arr[@]}"; do if [ ${arr[i]} = "${features[$idx]}:" ]; then echo -n ${arr[i+1]} >> $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv ; fi done; echo "" >> $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv; done
		# grep files without match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -L "${feature_family[$idx]} =" | awk '{ print $1"," }' >> $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv 	
		sort -o $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv $dir_features/${solver}-${feature_family[$idx]}-${features[$idx]}.csv
	done

	# collect outcome

	labels=( sat unsat )

	for label in "${labels[@]}"
	do
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -xc -m 1 ${label} | sed 's/:/ /1' | awk '{ print $1","$2 }' > $dir_features/${solver}-${label}.csv
		sort -o $dir_features/${solver}-${label}.csv $dir_features/${solver}-${label}.csv
	done

elif [ $solver = "z3" ]
then
	echo "collecting online features for ${solver} as rlimit=${rlimit}0k and seed=${seed} ... "

	mkdir -p "features/online/rlimit-${rlimit}"
	cd solver-output/online-feature/rlimit-${rlimit}/${solver}/seed-${seed}
	dir_features="../../../../../features/online/rlimit-${rlimit}"

	features=( conflicts decisions seq-add-axiom seq-char2bit seq-num-reductions del-clause memory mk-bool-var mk-clause num-allocs num-checks propagations time )

	for feat in "${features[@]}"
	do
		# grep files with match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -H -m 1 ":${feat} " | sed 's/:/ /1' | awk '{ print $1","$3 }' > $dir_features/${solver}-${feat}.csv
		# grep files without match
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -L ":${feat} " | awk '{ print $1","0 }' >> $dir_features/${solver}-${feat}.csv
		sort -o $dir_features/${solver}-${feat}.csv $dir_features/${solver}-${feat}.csv
	done

	# collect outcome

	labels=( sat unsat )

	for label in "${labels[@]}"
	do
		find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -xc -m 1 ${label} | sed 's/:/ /1' | awk '{ print $1","$2 }' > $dir_features/${solver}-${label}.csv
		sort -o $dir_features/${solver}-${label}.csv $dir_features/${solver}-${label}.csv
	done

else
	echo "Please select a correct solver name from {cvc5, z3, syntactic}."
fi

