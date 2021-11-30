INFILE=$1
OUTFILE=`echo $1 | cut -d. -f1`.csv
unoconv -f csv -o $OUTFILE $INFILE
