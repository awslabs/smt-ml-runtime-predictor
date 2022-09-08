import os
import glob
import multiprocessing

dir_benchmark = './benchmarks/SMT-LIB'
num_seed = 11
num_cpu = 96
debug = False

# debug
if debug:
    dir_benchmark = './benchmarks/SMT-LIB/QF_S/2019-Jiang/slog'
    num_cpu = 2

def execute(cmd):
    print(cmd)
    os.system(cmd)

cmds = []
for filename in glob.iglob(f'{dir_benchmark}/**/*.smt2', recursive=True):
    for seed in range(num_seed): 
        for solver in [f'cvc5 --tlimit=300000 --stats-all --stats-internal --seed={seed}',
                    f'z3 -t:300000 -st sat.random_seed={seed} nlsat.seed={seed} fp.spacer.random_seed={seed} smt.random_seed={seed} sls.random_seed={seed}']:     
            # skip previous random seed 0
            # if seed == 0:
            #     continue

            solver_name = solver.split()[0]

            # print(filename)
            cmd = [solver]
            cmd += [filename]

            # save outputs
            save_path = filename.replace('benchmarks', f'solver-output/label/{solver_name}/seed-{seed}', 1)
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            cmd += [f'> {save_path}.out 2>&1']

            cmd = ' '.join(cmd)
            cmds.append(cmd)

# debug
if debug:
    cmds = cmds[:10]

# run in parallel
with multiprocessing.Pool(processes = num_cpu) as pool:
    pool.map(execute, cmds)

