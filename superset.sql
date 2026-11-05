-- 2) client_coverage GUIDs that match adage BNPP_UID
SELECT count() AS n
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet') cc
INNER JOIN s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/telemetry_db/adage/data/**', format='Parquet') a
ON cc.Coverage_x20GUID = a.BNPP_UID;

-- 3) client_coverage GUIDs that match file_perm_user GlobalUID
SELECT count() AS n
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet') cc
INNER JOIN s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/cia/file_perm_user/data/**', format='Parquet') fpu
ON cc.Coverage_x20GUID = fpu.GlobalUID;

-- 4) sample keys side by side
SELECT * FROM (
  SELECT 'cc' AS src, toString(Coverage_x20GUID) AS k FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet') WHERE Coverage_x20GUID != '' LIMIT 3
) UNION ALL SELECT * FROM (
  SELECT 'adage', toString(BNPP_UID) FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/telemetry_db/adage/data/**', format='Parquet') LIMIT 3
) UNION ALL SELECT * FROM (
  SELECT 'fpu', toString(GlobalUID) FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/cia/file_perm_user/data/**', format='Parquet') LIMIT 3
);
