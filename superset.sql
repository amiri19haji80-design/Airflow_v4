WITH
cc  AS (SELECT DISTINCT toString(Coverage_x20GUID) AS id FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/crm_nas/crm_client_coverage_bronze/data/**', format='Parquet')),
fic AS (SELECT DISTINCT toString(BNPP_UID) AS id FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/telemetry_db/adage/data/**', format='Parquet') WHERE GBL_FILIERE = 'CIB Financial Institutions Coverage (FIC)'),
fpu AS (SELECT DISTINCT toString(GlobalUID) AS id FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/alpha/cia/file_perm_user/data/**', format='Parquet'))
SELECT
  (SELECT count() FROM cc)                                                AS cc_ids,
  (SELECT count() FROM fic)                                               AS fic_ids,
  (SELECT count() FROM fpu)                                               AS fpu_ids,
  (SELECT count() FROM cc WHERE id IN (SELECT id FROM fic))               AS cc_and_fic,
  (SELECT count() FROM cc WHERE id IN (SELECT id FROM fpu))               AS cc_and_fpu,
  (SELECT count() FROM cc WHERE id IN (SELECT id FROM fic) AND id IN (SELECT id FROM fpu)) AS all_three
