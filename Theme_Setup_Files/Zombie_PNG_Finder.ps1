$ascii = @"
__________            ___.   .__
\____    /____   _____\_ |__ |__| ____
  /     //  _ \ /     \| __ \|  |/ __ \
 /     /(  <_> )  Y Y  \ \_\ \  \  ___/
/_______ \____/|__|_|  /___  /__|\___  >
        \/           \/ PNG\/FINDER  \/
"@

Write-Host $ascii -ForegroundColor DarkGreen

# Get the directory where this script is located
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ask the user which PNG to search for
$pngName = Read-Host "Enter the .png filename to search (example: check.png)"

if ([string]::IsNullOrWhiteSpace($pngName)) {
    Write-Host "No PNG file name entered. Exiting." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "`nSearching for '$pngName' in JSON files under:" -ForegroundColor DarkGray
Write-Host $scriptDirectory -ForegroundColor DarkGray
Write-Host ""

# Get all JSON files in this folder and subfolders
$jsonFiles = Get-ChildItem -Path $scriptDirectory -Recurse -Filter *.json -File

$foundAny = $false

foreach ($file in $jsonFiles) {
    try {
        # Read file as UTF-8 text
        $lines = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -ErrorAction Stop

        $matches = @()

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]

            # Find all occurrences on this line
            $matchesInLine = [regex]::Matches($line, [regex]::Escape($pngName))

            if ($matchesInLine.Count -gt 0) {
                # Add a single entry per line
                $matches += @{
                    LineNumber = $i + 1
                    LineText   = $line
                }
            }
        }

        if ($matches.Count -gt 0) {
            $foundAny = $true

            # Relative path
            $relativePath = $file.FullName.Substring($scriptDirectory.Length).TrimStart('\')

            # Highlight the path in yellow
            Write-Host "File: $relativePath" -ForegroundColor DarkYellow

            # Sort matches by numeric line number
            foreach ($match in $matches | Sort-Object @{Expression = {[int]$_['LineNumber']}}) {
                $lineText = $match.LineText

                # Split the line into parts around the PNG
                $splitParts = $lineText -split "($([regex]::Escape($pngName)))"

                Write-Host -NoNewline "  Line $($match.LineNumber): " -ForegroundColor Cyan

                for ($j = 0; $j -lt $splitParts.Count; $j++) {
                    if ($splitParts[$j] -eq $pngName) {
                        Write-Host $splitParts[$j] -NoNewline -ForegroundColor Blue
                    } else {
                        Write-Host $splitParts[$j] -NoNewline
                    }
                }

                Write-Host ""
            }

            Write-Host ""
        }
    }
    catch {
        Write-Host "Could not read file: $($file.FullName)" -ForegroundColor DarkYellow
    }
}

if (-not $foundAny) {
    Write-Host "No JSON files reference '$pngName'." -ForegroundColor Red
}

Write-Host "`nPress Enter to exit..." -ForegroundColor DarkGreen
Read-Host