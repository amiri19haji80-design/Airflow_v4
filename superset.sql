SELECT * FROM Superset;



SELECT
  if(src = '', 'TOTAL', src)                    AS source,
  sumIf(n, side = 'core')                       AS core_rows,
  sumIf(n, side = 'nucleus')                    AS nucleus_rows,
  core_rows - nucleus_rows                      AS diff,
  round(100 * core_rows / nucleus_rows, 3)      AS parity_pct
FROM (
  SELECT 'core' AS side, interaction_source AS src, count() AS n
  FROM gamma.crm_interactions_gold GROUP BY src
  UNION ALL
  SELECT 'nucleus', interaction_source, count()
  FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
  WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%'
  GROUP BY interaction_source
)
GROUP BY src WITH ROLLUP
ORDER BY source = 'TOTAL', source;
