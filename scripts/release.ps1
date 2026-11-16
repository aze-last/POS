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

# 2. Check keystore configuration
if (!(Test-Path "android/key.properties")) {
    Write-Error "android/key.properties is missing! Release builds require a configured release keystore. See AGENTS.md for setup instructions."
}

# 3. Read current version from pubspec.yaml
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

# 4. Update pubspec.yaml
$updatedPubspec = $pubspecContent -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newVersion"
[System.IO.File]::WriteAllText("$PWD/pubspec.yaml", $updatedPubspec)

# 5. Update CHANGELOG.md
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

# 6. Run test suite
Write-Host "Running tests..." -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed! Aborting release."
}

# 7. Build signed release APK
Write-Host "Building release APK..." -ForegroundColor Cyan
flutter build apk --release
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
