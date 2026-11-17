# Release script for Banana POS (Windows PowerShell)
# Usage: .\scripts\release.ps1 [-Type patch|minor|major] [-Notes "Release notes summary"]

param(
    [ValidateSet("patch", "minor", "major")]
    [string]$Type = "patch",
    [string]$Notes = "Maintenance and update release"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Banana POS Release Workflow ===" -ForegroundColor Cyan

# 1. Check working directory
if (!(Test-Path "pubspec.yaml")) {
    Write-Error "pubspec.yaml not found. Please run this script from the project root directory."
}

# 2. Check keystore configuration and keystore file
if (!(Test-Path "android/key.properties")) {
    Write-Error "android/key.properties is missing! Release builds require a configured release keystore. See AGENTS.md for setup instructions."
}
$keyProps = Get-Content "android/key.properties" -Raw
if ($keyProps -match 'storeFile\s*=\s*(.+)') {
    $storePath = $Matches[1].Trim()
    $fullStorePath = Join-Path "android" $storePath
    if (!(Test-Path $fullStorePath) -and !(Test-Path $storePath)) {
        Write-Error "Keystore file '$storePath' referenced in android/key.properties not found! Per AGENTS.md §7, restore release.keystore."
    }
} else {
    Write-Error "storeFile property missing in android/key.properties."
}

# 3. Run test suite BEFORE touching pubspec.yaml or CHANGELOG.md (p7-15)
Write-Host "Running tests prior to release bump..." -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed! Aborting release without bumping version."
}

# 4. Read current version from pubspec.yaml
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -notmatch 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') {
    Write-Error "Could not parse version: MAJOR.MINOR.PATCH+BUILD from pubspec.yaml"
}

[int]$major = $Matches[1]
[int]$minor = $Matches[2]
[int]$patch = $Matches[3]
[int]$build = $Matches[4]

$oldVersion = "$major.$minor.$patch+$build"

# Compute new version
switch ($Type) {
    "major" { $major++; $minor = 0; $patch = 0 }
    "minor" { $minor++; $patch = 0 }
    "patch" { $patch++ }
}
$build++

$newVersionName = "$major.$minor.$patch"
$newVersion = "$newVersionName+$build"
$tag = "v$newVersionName"

Write-Host "Bumping version: $oldVersion -> $newVersion (Tag: $tag)" -ForegroundColor Yellow

# 5. Update pubspec.yaml
$updatedPubspec = $pubspecContent -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newVersion"
[System.IO.File]::WriteAllText("$PWD/pubspec.yaml", $updatedPubspec)

# 6. Update CHANGELOG.md
$dateStr = Get-Date -Format "yyyy-MM-dd"
$changelogEntry = @"
## [$tag] - $dateStr

$Notes

"@

if (Test-Path "CHANGELOG.md") {
    $existingChangelog = Get-Content "CHANGELOG.md" -Raw
    $newChangelog = $changelogEntry + "`n" + $existingChangelog
    [System.IO.File]::WriteAllText("$PWD/CHANGELOG.md", $newChangelog)
} else {
    [System.IO.File]::WriteAllText("$PWD/CHANGELOG.md", "# Changelog`n`n" + $changelogEntry)
}

# 7. Build signed release APK
Write-Host "Building release APK..." -ForegroundColor Cyan
if (Test-Path ".env") {
    flutter build apk --release --dart-define-from-file=.env
} else {
    flutter build apk --release
}
if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter build apk --release failed! Aborting release."
}

# 8. Prepare releases directory
$releaseDir = "releases"
if (!(Test-Path $releaseDir)) {
    New-Item -ItemType Directory -Path $releaseDir | Out-Null
}

$builtApk = "build/app/outputs/flutter-apk/app-release.apk"
$targetApk = "$releaseDir/banana-pos-$tag.apk"
$targetSha = "$releaseDir/banana-pos-$tag.apk.sha256"

Copy-Item $builtApk $targetApk -Force

# Generate SHA256 checksum
$hash = (Get-FileHash -Path $targetApk -Algorithm SHA256).Hash.ToLower()
$shaContent = "$hash  banana-pos-$tag.apk"
[System.IO.File]::WriteAllText("$PWD/$targetSha", $shaContent)

Write-Host "`nRelease artifact generated successfully!" -ForegroundColor Green
Write-Host "APK:    $targetApk" -ForegroundColor Gray
Write-Host "SHA256: $targetSha ($hash)" -ForegroundColor Gray

# 9. Output exact publish commands (do not publish automatically)
Write-Host "`n=== To Publish to GitHub Releases ===" -ForegroundColor Cyan
Write-Host "Run the following command using GitHub CLI:" -ForegroundColor Yellow
Write-Host "gh release create $tag `"$targetApk`" `"$targetSha`" --title `"Banana POS $tag`" --notes `"$Notes`"" -ForegroundColor White

Write-Host "`nOr upload manually via GitHub Web:" -ForegroundColor Yellow
Write-Host "1. Go to: https://github.com/aze-last/POS/releases/new"
Write-Host "2. Choose tag: $tag"
Write-Host "3. Title: Banana POS $tag"
Write-Host "4. Attach binaries: $targetApk and $targetSha"
Write-Host "5. Click 'Publish release'."
