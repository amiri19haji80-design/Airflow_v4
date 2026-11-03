$rx = '(sources|projects)\.[A-Za-z0-9_\.\*]+'
function Get-Refs($file) {
  Select-String -Path $file -Pattern $rx -AllMatches |
    ForEach-Object { $_.Matches } | ForEach-Object { $_.Value.TrimEnd('.') } | Sort-Object -Unique
}
function Expand-Ref($ref) {
  if (-not $ref.Contains('*')) { return $ref }
  $base = $ref.Substring(0, $ref.IndexOf('*')).TrimEnd('.')
  $dir = $base -replace '\.', '\'
  if (Test-Path $dir) { Get-ChildItem $dir -Directory | ForEach-Object { "$base.$($_.Name)" } }
}
function Get-SourceInfo($ref) {
  if ($ref -notlike 'sources.*') { return '' }
  $app = ($ref -replace '\.', '\') + '\app.yaml'
  if (-not (Test-Path $app)) { return 'app.yaml not found' }
  (Select-String -Path $app -Pattern '^\s*(name|table|allow_multiple_run)\s*:' | ForEach-Object { $_.Line.Trim() }) -join ' | '
}
$crmRefs = Get-Refs 'dags\crm_interactions.yaml' | Where-Object { -not $_.Contains('*') }
$crmText = (Get-ChildItem projects\interactions, sources\crm, sources\crm_client_coverage -Recurse -Include *.sql,*.py,*.yaml -ErrorAction SilentlyContinue | ForEach-Object { Get-Content $_.FullName -Raw }) -join "`n"
$shared = @(); $readOnly = @()
foreach ($f in Get-ChildItem dags\*.yaml | Where-Object Name -ne 'crm_interactions.yaml') {
  foreach ($o in Get-Refs $f.FullName) {
    foreach ($e in Expand-Ref $o) {
      if ($crmRefs -contains $e) {
        $shared += [pscustomobject]@{ OtherDag = $f.BaseName; Task = $e; Info = (Get-SourceInfo $e) }
      } elseif ($e -like 'sources.*') {
        $name = $e.Split('.')[-1]
        if ($crmText -match "\b$([regex]::Escape($name))\b") {
          $readOnly += [pscustomobject]@{ OtherDag = $f.BaseName; Task = $e; Info = (Get-SourceInfo $e) }
        }
      }
    }
  }
}
"`n=== 1) Same task in CRM and another DAG ==="
$shared | Sort-Object Task, OtherDag -Unique | Format-Table -AutoSize -Wrap | Out-String -Width 400
"`n=== 2) Only in other DAGs, name appears in CRM code ==="
$readOnly | Sort-Object Task, OtherDag -Unique | Format-Table -AutoSize -Wrap | Out-String -Width 400
