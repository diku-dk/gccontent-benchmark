# Copyright 2017 Samuel Lampa
# samuel dot lampa at farmbio dot uu dot se
TIMECMD=/usr/bin/time -f %e

Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

%: %.gz
	gunzip $<

get_data: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa

c.000.time:
	bash -c 'cd c.000/ && gcc -oFast -ogc gc.c && cd ..;'
	${TIMECMD} ./c.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./c.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./c.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

dlang.000.time:
	bash -c 'cd dlang.000/ && ldc2 -O5 -boundscheck=off -release gc.d && cd ..;'
	${TIMECMD} ./dlang.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./dlang.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./dlang.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

python.000.time:
	${TIMECMD} python python.000/gc.py 2> .$@.tmp
	sleep 0.1
	${TIMECMD} python python.000/gc.py 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} python python.000/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp


pypy.000.time:
	${TIMECMD} pypy python.000/gc.py 2> .$@.tmp
	sleep 0.1
	${TIMECMD} pypy python.000/gc.py 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} pypy python.000/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

cython.000.time:
	bash -c 'cd cython.000/ && cython --embed gc.pyx && gcc -I/usr/include/python2.7 -O3 -o gc gc.c -lpython2.7 && cd ..;'
	${TIMECMD} ./cython.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cython.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cython.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

golang.000.time:
	bash -c 'cd golang.000/ && go build gc.go && cd ..;'
	${TIMECMD} ./golang.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./golang.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./golang.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

fpc.000.time:
	bash -c 'cd fpc.000/ && fpc -Ur -O3 -Xs- -OWall -FWgc.tmp -XX -CX -ogc gc.pas && cd ..;'
	${TIMECMD} ./fpc.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./fpc.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./fpc.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

report.csv: python.000.time pypy.000.time cython.000.time golang.000.time fpc.000.time dlang.000.time
	bash -c 'for f in *time; do echo $$f","`cat $$f`; done | sort -t, -k 2,2 > $@'

all: report.csv

clean:
	rm *.time
	rm report.csv
