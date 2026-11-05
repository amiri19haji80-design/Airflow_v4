-- 1) every gold table has data
SELECT 'crm_interactions_gold' AS t, count() FROM gamma.crm_interactions_gold
UNION ALL SELECT 'crm_interactions_partitioned_gold', count() FROM gamma.crm_interactions_partitioned_gold
UNION ALL SELECT 'crm_interactions_last_meeting_gold', count() FROM gamma.crm_interactions_last_meeting_gold
UNION ALL SELECT 'data_quality_crm_interactions_gold', count() FROM gamma.data_quality_crm_interactions_gold
UNION ALL SELECT 'contact_coverage_with_refog_gold', count() FROM gamma.contact_coverage_with_refog_gold;

-- 2) Core gold: total vs distinct call_id (duplicates check)
SELECT count() AS core_rows, uniqExact(call_id) AS core_distinct_call_id
FROM gamma.crm_interactions_gold;

-- 3) Nucleus PRD gold, same numbers
SELECT count() AS nucleus_rows, uniqExact(call_id) AS nucleus_distinct_call_id
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%';
