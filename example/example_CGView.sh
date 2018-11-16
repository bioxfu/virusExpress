NAMES=( C3_mut EV_2dpi pGWB2_C3 )
for NAME in ${NAMES[@]}; do
	perl cgview/cgview_xml_builder/cgview_xml_builder.pl -sequence index/sequence.gbk -output track/$NAME.xml -tick_density 0.7 -feature_labels T -gc_content F -gc_skew F -analysis track/${NAME}_1.expr_track track/${NAME}_2.expr_track track/${NAME}_3.expr_track track/${NAME}_4.expr_track
done

NAMES=( EV_6dpi )
for NAME in ${NAMES[@]}; do
	perl cgview/cgview_xml_builder/cgview_xml_builder.pl -sequence index/sequence.gbk -output track/$NAME.xml -tick_density 0.7 -feature_labels T -gc_content F -gc_skew F -analysis track/${NAME}_1.expr_track track/${NAME}_2.expr_track track/${NAME}_4.expr_track
done

NAMES=( TYLCV )

for NAME in ${NAMES[@]}; do
	perl cgview/cgview_xml_builder/cgview_xml_builder.pl -sequence index/sequence.gbk -output track/$NAME.xml -tick_density 0.7 -feature_labels T -gc_content F -gc_skew F -analysis track/${NAME}_1.expr_track track/${NAME}_3.expr_track track/${NAME}_4.expr_track
done

NAMES=( C3_mut EV_2dpi pGWB2_C3 EV_6dpi TYLCV)
for NAME in ${NAMES[@]}; do
	java -jar -Xmx1500m cgview/cgview.jar -i track/$NAME.xml -o figure/$NAME.png -f png
done
