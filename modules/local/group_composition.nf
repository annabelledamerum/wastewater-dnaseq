process GROUP_COMPOSITION {

    input:
    path excel
    path compositions

    output:
    path('*_groupinterest_comp.csv'), optional: true, emit: compcsv
    path('Groups_of_interest.xlsx'), optional: true, emit: search_results

    script:
    """
    group_interest_comp.py -i $excel -c level-7.csv
    """
}
