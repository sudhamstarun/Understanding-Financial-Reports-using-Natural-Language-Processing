#!/usr/bin/perl

print "#!/bin/bash\n";
print "#SBATCH\n";
print "#SBATCH --job-name=$ARGV[0]\n";
print "#SBATCH --time=24:0:0\n";
print "#SBATCH --nodes=1\n";
print "#SBATCH --ntasks-per-node=1\n";
print "#SBATCH --cpus-per-task=24\n";
print "#SBATCH --export=Variables\n";
print "#SBATCH --requeue\n";
print "#SBATCH --partition=bw-parallel,parallel\n";
print "#SBATCH --exclude=bigmem0014\n";

print "cd /scratch/users/rluo5\@jhu.edu/99.edgar/sec-edgar/SECEdgar/\n";
print "python /scratch/users/rluo5\@jhu.edu/99.edgar/sec-edgar/SECEdgar/test.py /scratch/users/rluo5\@jhu.edu/99.edgar/sec-edgar/SECEdgar/data/$ARGV[0]\n"
