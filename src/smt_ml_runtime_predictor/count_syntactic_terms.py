# example
# 1d477adde7e9fbcbe4912d801ea82ba5815fa.smt2.out:cvc5::TERM = { ADD: 194, AND: 518, EQUAL: 146, GEQ: 418, ITE: 101, NOT: 197, STRING_CHARAT: 31, STRING_CONCAT: 25, STRING_CONTAINS: 56, STRING_INDEXOF: 622, STRING_LENGTH: 92, STRING_REPLACE: 25, STRING_SUBSTR: 338, SUB: 560 }
import os

# collect all syntactic features and save them in tmp.csv
os.system('find solver-output-feature-syntactic/cvc5/SMT-LIB -name "*.smt2.out" -type f | xargs grep -H -m 1 "cvc5::TERM ="  > tmp.csv')

# count the number of syntactic features
terms = set()
with open("tmp.csv", 'r') as f:
    lines = f.readlines()

    for line in lines:
        line = line.split()
        assert(line[1] == '=' and line[2] == '{')

        idx = 3
        while line[idx] != '}':
            terms.add(line[idx])
            idx += 2

print(len(terms))
print(terms)      

# remove tmp.csv
os.system('rm tmp.csv')
