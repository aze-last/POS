#!/usr/bin/env bash
# Release script for Banana POS (Linux/macOS)
# Usage: ./scripts/release.sh [patch|minor|major] ["Release notes summary"]

set -euo pipefail

TYPE="${1:-patch}"
NOTES="${2:-Maintenance and update release}"

echo "=== Banana POS Release Workflow ==="

# 1. Check working directory
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found. Please run this script from the project root." >&2
    exit 1
fi

# 2. Check keystore configuration and keystore file
if [ ! -f "android/key.properties" ]; then
    echo "Error: android/key.properties is missing! Release builds require a configured release keystore. See AGENTS.md for setup instructions." >&2
    exit 1
fi

STORE_PATH=$(grep '^storeFile=' android/key.properties | cut -d'=' -f2 | tr -d ' \r')
if [ -n "$STORE_PATH" ]; then
    if [ ! -f "android/$STORE_PATH" ] && [ ! -f "$STORE_PATH" ]; then
        echo "Error: Keystore file '$STORE_PATH' referenced in android/key.properties not found! Per AGENTS.md §7, restore release.keystore." >&2
        exit 1
    fi
else
    echo "Error: storeFile property missing in android/key.properties." >&2
    exit 1
fi

# 3. Run test suite BEFORE touching pubspec.yaml or CHANGELOG.md (p7-15)
echo "Running tests prior to release bump..."
flutter test

# 4. Read current version from pubspec.yaml
VERSION_LINE=$(grep '^version:' pubspec.yaml)
RAW_VERSION=$(echo "$VERSION_LINE" | sed -E 's/version:[[:space:]]*//')
SEMVER=$(echo "$RAW_VERSION" | cut -d'+' -f1)
BUILD=$(echo "$RAW_VERSION" | cut -d'+' -f2)

MAJOR=$(echo "$SEMVER" | cut -d'.' -f1)
MINOR=$(echo "$SEMVER" | cut -d'.' -f2)
PATCH=$(echo "$SEMVER" | cut -d'.' -f3)

OLD_VERSION="$MAJOR.$MINOR.$PATCH+$BUILD"

case "$TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Error: Invalid version bump type '$TYPE'. Choose patch, minor, or major." >&2
        exit 1
        ;;
esac

BUILD=$((BUILD + 1))
NEW_VERSION_NAME="$MAJOR.$MINOR.$PATCH"
NEW_VERSION="$NEW_VERSION_NAME+$BUILD"
TAG="v$NEW_VERSION_NAME"

echo "Bumping version: $OLD_VERSION -> $NEW_VERSION (Tag: $TAG)"

# 5. Update pubspec.yaml
sed -i.bak -E "s/^version:[[:space:]]*.*/version: $NEW_VERSION/" pubspec.yaml
rm -f pubspec.yaml.bak

# 6. Update CHANGELOG.md
DATE_STR=$(date +%Y-%m-%d)
ENTRY="## [$TAG] - $DATE_STR\n\n$NOTES\n"

if [ -f "CHANGELOG.md" ]; then
    echo -e "$ENTRY\n$(cat CHANGELOG.md)" > CHANGELOG.md
else
    echo -e "# Changelog\n\n$ENTRY" > CHANGELOG.md
fi

# 7. Build signed release APK
echo "Building release APK..."
if [ -f ".env" ]; then
    flutter build apk --release --dart-define-from-file=.env
else
    flutter build apk --release
fi

# 8. Prepare releases directory
mkdir -p releases
BUILT_APK="build/app/outputs/flutter-apk/app-release.apk"
TARGET_APK="releases/banana-pos-$TAG.apk"
TARGET_SHA="releases/banana-pos-$TAG.apk.sha256"

cp "$BUILT_APK" "$TARGET_APK"

# Generate SHA-256
if command -v sha256sum >/dev/null 2>&1; then
    HASH=$(sha256sum "$TARGET_APK" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
    HASH=$(shasum -a 256 "$TARGET_APK" | awk '{print $1}')
else
    HASH=$(openssl dgst -sha256 "$TARGET_APK" | awk '{print $NF}')
fi

echo "$HASH  banana-pos-$TAG.apk" > "$TARGET_SHA"

echo ""
echo "Release artifact generated successfully!"
echo "APK:    $TARGET_APK"
echo "SHA256: $TARGET_SHA ($HASH)"

# 9. Output exact publish commands (do not publish automatically)
echo ""
echo "=== To Publish to GitHub Releases ==="
echo "Run the following command using GitHub CLI:"
echo "gh release create $TAG \"$TARGET_APK\" \"$TARGET_SHA\" --title \"Banana POS $TAG\" --notes \"$NOTES\""
echo ""
echo "Or upload manually via GitHub Web:"
echo "1. Go to: https://github.com/aze-last/POS/releases/new"
echo "2. Choose tag: $TAG"
echo "3. Title: Banana POS $TAG"
echo "4. Attach binaries: $TARGET_APK and $TARGET_SHA"
echo "5. Click 'Publish release'."
