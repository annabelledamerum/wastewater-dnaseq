#!/usr/bin/env bash
read -r -a HTML_LIST <<< ${1}
HTML_NUM=$(find . -name "*.html" | wc -l)
HTML_NUM=$(( $HTML_NUM-1 ))
for i in $(seq 0 $HTML_NUM);
do
    sed -i "s/<div id=\"vis\">/<div id=\"vis_${i}\">/" ${HTML_LIST[${i}]}
    sed -i "s/const el = document.getElementById('vis');/const el = document.getElementById('vis_${i}');/" ${HTML_LIST[${i}]}
    sed -i "s/vegaEmbed(\"\#vis\", spec, embedOpt)/vegaEmbed(\"\#vis_${i}\", spec, embedOpt)/" ${HTML_LIST[${i}]}

    PREFIX=$(echo ${HTML_LIST[${i}]} | sed 's/-ancombc-barplot.html//')
    REFGROUP=$(cat refgroup.txt)
    sed -i '1i <!--' ${HTML_LIST[${i}]}
    sed -i "2i id: ${PREFIX}" ${HTML_LIST[${i}]}
    sed -i '3i parent_id: ANCOM_Results' ${HTML_LIST[${i}]}
    sed -i '4i parent_name: "ANCOM Differential Species Diversity Results"' ${HTML_LIST[${i}]}
    sed -i "5i parent_description: '<a href=\"https://pubmed.ncbi.nlm.nih.gov/26028277/\">ANCOM-BC</a> is a software designed to find differentially expressed species between user specified groups. By default, the first alphabetical group is used as the reference in the below plots. Positive log fold change values (<b>enriched</b> in the legend) indicate that the species is expressed more commonly in the subject group as opposed to the reference group. Negative log fold change values (<b>depleted</b> in the legend) indicate that the species is expressed more commonly in the reference group as opposed to the subject group.'" ${HTML_LIST[${i}]}
    sed -i "6i section_name: ${PREFIX} vs ${REFGROUP} Results" ${HTML_LIST[${i}]}
    sed -i "7i description: ANCOM-BC differential species diversity results for subject group '${PREFIX}' compared to the reference group '${REFGROUP}'." ${HTML_LIST[${i}]}
    sed -i '8i -->' ${HTML_LIST[${i}]}
    
    mv ${HTML_LIST[${i}]} "${PREFIX}_mqc.html"

done
