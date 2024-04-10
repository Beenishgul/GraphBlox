report_qor_assessment  -exclude_methodology_checks -name qor_assessments -max_paths 200 -full_assessment_details -file rqs.rpt
report_qor_suggestions -report_all_suggestions -max_paths 200 -file rqs.rpt
write_qor_suggestions filename.rqs
read_qor_suggestions filename.rqs