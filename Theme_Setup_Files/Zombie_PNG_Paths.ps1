$root = $PSScriptRoot

Get-ChildItem -Path $root -Recurse -Filter *.json | ForEach-Object {
    (Get-Content $_.FullName) `
    -replace '(")([^"]*/)?([^"/]+\.png)(")', '$1assets/$3$4' |
    Set-Content $_.FullName
}