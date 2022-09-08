########################################
##
## collect labels from outputs of solvers running on each benchmark for a long time
##
## $1: solver name in {cvc5, z3}
## $2: random seed
## $3: test stability if it's true, otherwise false
########################################

solver=$1
seed=$2
stability=$3

echo "collecting labels as seed=${seed} ... "

dir_benchmark="./SMT-LIB"

# labels: filename runtime/ms sat unsat unknown 

# collect runtime
if [ $solver = "cvc5" ]
then
	if [ "$stability" = true ]
	then
		mkdir -p labels-stability/seed-${seed}
		cd solver-output/label/${solver}/seed-${seed}
		dir_labels="../../../../labels-stability/seed-${seed}"
	else
		mkdir -p labels
		cd solver-output/label/${solver}/seed-${seed}
		dir_labels="../../../../labels"
	fi

	# grep files with match
	find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -H -m 1 "global::totalTime =" | sed 's/:/ /1' | awk '{ printf "%s,%d\n", $1, $4 }' > $dir_labels/${solver}-runtime-ms.csv
	# grep files without match
	find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -L "global::totalTime =" | awk '{ print $1"," }' >> $dir_labels/${solver}-runtime-ms.csv
	sort -o $dir_labels/${solver}-runtime-ms.csv $dir_labels/${solver}-runtime-ms.csv

elif [ $solver = "z3" ]
then
	mkdir -p labels
	cd solver-output/label/${solver}/seed-${seed}
	dir_labels="../../../../labels"

	# grep files with match
	find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -H -m 1 ":total-time" | sed 's/:/ /1' | awk '{ printf "%s,%f\n", $1, $3 }' > $dir_labels/${solver}-runtime-s.csv
	# grep files without match
	find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -L ":total-time" | awk '{ print $1"," }' >> $dir_labels/${solver}-runtime-s.csv
	sort -o $dir_labels/${solver}-runtime-s.csv $dir_labels/${solver}-runtime-s.csv

else
	echo "Please select a correct solver name from {cvc5, z3}."
	exit 0
fi

# collect outcome
labels=( sat unsat unknown timeout )
for label in "${labels[@]}"
do
	find $dir_benchmark -name "*.smt2.out" -type f | xargs grep -xc -m 1 ${label} | sed 's/:/ /1' | awk '{ print $1","$2 }' > $dir_labels/${solver}-${label}.csv
	sort -o $dir_labels/${solver}-${label}.csv $dir_labels/${solver}-${label}.csv
done

