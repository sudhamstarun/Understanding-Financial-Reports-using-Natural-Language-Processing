perl -ane 'BEGIN{open $fh,"dir.list";%a=map{chomp;$_=>1} <$fh>}{print if not defined $a{$F[0]}}' data.txt.all > data.txt
