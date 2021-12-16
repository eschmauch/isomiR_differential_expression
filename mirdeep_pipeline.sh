ls *.fa > list_files
mkdir counts
process_mir(){
    sed 's, ,_,g' -i $1
    mapper.pl $1 -c -j -m -s collapsed_${1}
    var1=$(echo $1 | cut -f1 -d.)
    quantifier.pl -p ../human_hairpin.fa -m ../hsa_mirna.fa -r collapsed_${1} -t hsa -d -j -y $var1
    rm collapsed_${1}
    cp expression_analyses/expression_analyses_${var1}/miRNA_expressed.csv counts/${var1}_counts.csv
}
while read line
do 
	process_mir "$line" &
done < list_files