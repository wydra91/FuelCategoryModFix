param (
    [Parameter(Mandatory=$true)]
    [string]$ModDirectory
)

# Load both required .NET assemblies for manual ZIP entry manipulation
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDirectory = "${ModDirectory}_Backup_${timestamp}"
Copy-Item -Path $ModDirectory -Destination $backupDirectory -Recurse
Write-Host "Backup created at: $backupDirectory"

$zipFiles = Get-ChildItem -Path $ModDirectory -Filter "*.zip" -File

foreach ($zip in $zipFiles) {
    Write-Host "Processing: $($zip.Name)"
    $tempPath = Join-Path -Path $zip.DirectoryName -ChildPath ($zip.BaseName + "_temp")
    
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Recurse -Force
    }

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zip.FullName, $tempPath)

    $targetFiles = Get-ChildItem -Path $tempPath -File -Recurse | 
        Select-String -Pattern 'fuel_category' -SimpleMatch -Encoding UTF8 | 
        Select-Object -ExpandProperty Path -Unique

    $wasModified = $false

    if ($null -ne $targetFiles) {
        foreach ($filePath in $targetFiles) {
            $content = Get-Content -Path $filePath -Raw -Encoding UTF8
            
            $updatedContent = [regex]::Replace($content, 'fuel_category\s*=\s*(["''].+?["''])', 'fuel_categories = { $1 }')
            $updatedContent = [regex]::Replace($updatedContent, '\.fuel_category\b', '.fuel_categories')
            $updatedContent = [regex]::Replace($updatedContent, '"fuel_category"', '"fuel_categories"')
            $updatedContent = [regex]::Replace($updatedContent, "'fuel_category'", "'fuel_categories'")
            
            if ($content -cne $updatedContent) {
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($filePath, $updatedContent, $utf8NoBom)
                $wasModified = $true
            }
        }
    }

    if ($wasModified) {
        Write-Host "  Modifications applied. Overwriting $($zip.Name)..."
        Remove-Item -Path $zip.FullName -Force
        
        # Open a new ZIP archive explicitly
        $zipArchive = [System.IO.Compression.ZipFile]::Open($zip.FullName, [System.IO.Compression.ZipArchiveMode]::Create)
        
        # Iterate through every extracted file to manually package them
        $allFiles = Get-ChildItem -Path $tempPath -File -Recurse
        foreach ($file in $allFiles) {
            # Determine the relative path of the file from the temp directory root
            $relativePath = $file.FullName.Substring($tempPath.Length + 1)
            
            # Force forward slashes for Linux compatibility
            $linuxPath = $relativePath.Replace('\', '/')
            
            # Add the file to the archive with the corrected path
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $linuxPath) | Out-Null
        }
        
        # Close and save the archive
        $zipArchive.Dispose()
    }

    Remove-Item -Path $tempPath -Recurse -Force
}