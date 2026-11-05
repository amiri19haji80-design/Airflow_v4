SELECT * FROM Superset;





-- A) per source
SELECT src, sumIf(n, side='core') AS core, sumIf(n, side='nucleus') AS nucleus, core - nucleus AS diff
FROM (
  SELECT 'core' AS side, interaction_source AS src, count() AS n FROM gamma.crm_interactions_gold GROUP BY src
  UNION ALL
  SELECT 'nucleus', interaction_source, count()
  FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
  WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%'
  GROUP BY interaction_source
)
GROUP BY src ORDER BY abs(diff) DESC;

-- B) per source + month, only months that differ
SELECT src, ym, sumIf(n, side='core') AS core, sumIf(n, side='nucleus') AS nucleus, core - nucleus AS diff
FROM (
  SELECT 'core' AS side, interaction_source AS src, toYYYYMM(interaction_date) AS ym, count() AS n FROM gamma.crm_interactions_gold GROUP BY src, ym
  UNION ALL
  SELECT 'nucleus', interaction_source, toYYYYMM(toDate(interaction_date)), count()
  FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
  WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%'
  GROUP BY 2, 3
)
GROUP BY src, ym HAVING diff != 0
ORDER BY abs(diff) DESC LIMIT 50;
