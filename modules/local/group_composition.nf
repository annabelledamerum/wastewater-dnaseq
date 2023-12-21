process GROUP_COMPOSITION {

    input:
    path excel
    path genus
    path species 

    output:
    path('*_groupinterest_comp.csv'), emit: groupinterest_compcsv

    script:
    """
    group_interest_comp.py -e $excel -g $genus -s $species
    """
}
