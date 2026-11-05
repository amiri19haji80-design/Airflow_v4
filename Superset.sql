-- 1) labels in adage
SELECT GBL_FILIERE, count() AS n
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/telemetry_db/adage/data/**', format='Parquet')
GROUP BY GBL_FILIERE ORDER BY n DESC;

-- 2) client_coverage GUIDs that match adage BNPP_UID (any label)
SELECT count() AS n
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet') cc
INNER JOIN s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/telemetry_db/adage/data/**', format='Parquet') a
ON cc.`Coverage GUID` = a.BNPP_UID;

-- 3) client_coverage GUIDs that match file_perm_user GlobalUID
SELECT count() AS n
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet') cc
INNER JOIN s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/cia/file_perm_user/data/**', format='Parquet') fpu
ON cc.`Coverage GUID` = fpu.GlobalUID;

-- 4) sample keys side by side, to spot format differences (case, braces, spaces)
SELECT 'cc' AS src, `Coverage GUID` AS k FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet') WHERE `Coverage GUID` != '' LIMIT 3
UNION ALL
SELECT 'adage', BNPP_UID FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/telemetry_db/adage/data/**', format='Parquet') LIMIT 3
UNION ALL
SELECT 'fpu', GlobalUID FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/cia/file_perm_user/data/**', format='Parquet') LIMIT 3;
