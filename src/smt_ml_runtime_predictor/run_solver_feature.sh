# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

echo "Number of benchmarks:"
echo "dafny: $(find ./benchmarks/dafny/ -type f -name "*.smt2" | wc -l)"
echo "SMT-LIB $(find ./benchmarks/SMT-LIB/ -type f -name "*.smt2" | wc -l)"


echo -e "\nDetailed distribution of files"

echo "dafny:"
echo -e "  total:\t$(find ./benchmarks/dafny/ -type f | wc -l)"
echo -e "  .smt2:\t$(find ./benchmarks/dafny/ -type f -name "*.smt2" | wc -l)"
echo -e "  .sh:\t\t$(find ./benchmarks/dafny/ -type f -name "*.sh" | wc -l)"
echo -e "  .TXT:\t\t$(find ./benchmarks/dafny/ -type f -name "*.TXT" | wc -l)"

echo "SMT-LIB:"
echo -e "  total:\t$(find ./benchmarks/SMT-LIB/ -type f | wc -l)"
echo -e "  .smt2:\t$(find ./benchmarks/SMT-LIB/ -type f -name "*.smt2" | wc -l)"
echo -e "  .smt2.bak:\t$(find ./benchmarks/SMT-LIB/ -type f -name "*.smt2.bak" | wc -l)"
echo -e "  .smt2~:\t$(find ./benchmarks/SMT-LIB/ -type f -name "*.smt2~" | wc -l)"
echo -e "  .md:\t\t$(find ./benchmarks/SMT-LIB/ -type f -name "*.md" | wc -l)"

## print basenames and check duplication
# find benchmarks/dafny/ -type f -name "*.smt2" | xargs -n 1 basename > basenames.txt
# find benchmarks/SMT-LIB/ -type f -name "*.smt2" | xargs -n 1 basename >> basenames.txt

## there are duplicated basenames so we have to include directories in the filename.

# run CVC5 over SMT-LIB and dafny benchmarks
echo -e "\n solving benchmarks ... "
dir_benchmark="SMT-LIB"
cd benchmarks

# collect online features
for rlimit in {1..10}
do 
	for seed in {0..0}
	do
		for solver in "cvc5" "z3"
		do
			if [ $solver = "cvc5" ]
			then
				echo "run ${solver} as rlimit=${rlimit}0k and seed=${seed} for online features ... "

				# cvc5
				find ${dir_benchmark} -type f -name "*.smt2" -print -exec sh -c "mkdir -p ../solver-output/online-feature/rlimit-${rlimit}/cvc5/seed-${seed}/\$(dirname {}) && cvc5 {} --stats-all --stats-internal --rlimit=${rlimit}0000 --tlimit=1000 --seed=${seed} > ../solver-output/online-feature/rlimit-${rlimit}/cvc5/seed-${seed}/{}.out 2>&1" \;

				# check the number of outputs
				num_in=$(find ${dir_benchmark} -type f -name "*.smt2" | wc -l)
				num_out=$(find ../solver-output/online-feature/rlimit-${rlimit}/cvc5/seed-${seed}/${dir_benchmark} -type f -name "*.smt2.out" | wc -l)
				echo -e "\n #benchmarks: $num_in #outputs $num_out"
			else
				echo "run ${solver} as rlimit=${rlimit}0k and seed=${seed} for online features ... "

				# z3
				find ${dir_benchmark} -type f -name "*.smt2" -print -exec sh -c "mkdir -p ../solver-output/online-feature/rlimit-${rlimit}/z3/seed-${seed}/\$(dirname {}) && z3 {} -st rlimit=${rlimit}0000 -t:1000 sat.random_seed=${seed} nlsat.seed=${seed} fp.spacer.random_seed=${seed} smt.random_seed=${seed} sls.random_seed=${seed} > ../solver-output/online-feature/rlimit-${rlimit}/z3/seed-${seed}/{}.out 2>&1" \;

				# check the number of outputs
				num_in=$(find ${dir_benchmark} -type f -name "*.smt2" | wc -l)
				num_out=$(find ../solver-output/online-feature/rlimit-${rlimit}/z3/seed-${seed}/${dir_benchmark} -type f -name "*.smt2.out" | wc -l)
				echo -e "\n #benchmarks: $num_in #outputs $num_out"
			fi
		done
	done
done


echo "run cvc5 for syntactic features ... "
# collect syntactic features
find ${dir_benchmark} -type f -name "*.smt2" -print -exec sh -c "mkdir -p ../solver-output/syntactic-feature/cvc5/\$(dirname {}) && cvc5 {} --stats-all --stats-internal --parse-only --seed=0 > ../solver-output/syntactic-feature/cvc5/{}.out 2>&1" \;

# check the number of outputs
num_in=$(find ${dir_benchmark} -type f -name "*.smt2" | wc -l)
num_out=$(find ../solver-output/syntactic-feature/cvc5/${dir_benchmark} -type f -name "*.smt2.out" | wc -l)
echo -e "\n #benchmarks: $num_in #outputs $num_out"

cd ..
