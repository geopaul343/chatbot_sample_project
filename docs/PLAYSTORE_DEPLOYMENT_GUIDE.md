# 🚀 Play Store Deployment Guide
## The Complete Guide to Deploy Your Flutter App to Google Play Store using CI/CD

> 🎯 **Goal**: This guide will help you deploy your Flutter app to Google Play Store automatically every time you make changes to your code. Even a 10-year-old can follow this guide!

---

## 📚 Table of Contents
1. [What We Built Today](#what-we-built-today)
2. [How Version Numbers Work](#how-version-numbers-work)
3. [How to Update Your App Version](#how-to-update-your-app-version)
4. [How to Deploy Your App](#how-to-deploy-your-app)
5. [Understanding Play Store Release Types](#understanding-play-store-release-types)
6. [Troubleshooting](#troubleshooting)
7. [Version Synchronization Guide](#version-synchronization-guide)
8. [Quick Reference](#quick-reference)

---

## 🛠️ What We Built Today

Today we set up an **automatic deployment system** for your Flutter app. Here's what it does:

### 🔄 The Magic Pipeline
When you make changes to your app and push them to GitHub, this happens automatically:

1. **📱 Build Your App**: Creates a release version of your app
2. **✅ Run Tests**: Makes sure everything works correctly  
3. **🔐 Sign Your App**: Adds security certificates (like a digital signature)
4. **📦 Package Your App**: Creates an `.aab` file (Android App Bundle)
5. **🚀 Upload to Play Store**: Sends your app to Google Play Store
6. **🎉 Make it Available**: Users can download your app!

### 🏗️ What Files We Created
- `cloudbuild.yaml` - The recipe that tells Google Cloud how to build your app
- `cloudbuild-trigger.yaml` - The settings for when to start building
- `setup-gcp-cicd.sh` - A script that set up everything in Google Cloud
- `android/app/build.gradle.kts` - Android build settings with signing

---

## 🔢 How Version Numbers Work

Your app has two important numbers:

### 📊 Version Name (What Users See)
- Format: `X.Y.Z` (like `1.0.5`)
- **X** = Major version (big changes)
- **Y** = Minor version (new features)  
- **Z** = Patch version (bug fixes)

### 🏷️ Version Code (Internal Number)
- Format: Just a number (like `10`)
- This number must **always increase**
- Google Play Store uses this to know which version is newer

### 📍 Where to Find Them
In your `pubspec.yaml` file:
```yaml
version: 1.0.5+10
#        ↑     ↑
#   Version   Version
#    Name      Code
```

### ⚠️ **CRITICAL**: Version numbers must be synchronized across **4 files**:
1. `pubspec.yaml`
2. `android/app/build.gradle.kts`
3. `cloudbuild.yaml`
4. `cloudbuild-trigger.yaml`

---

## 🔄 How to Update Your App Version

### 🎯 When to Update Versions

| Type of Change | Version Name Change | Version Code Change |
|---------------|-------------------|-------------------|
| 🐛 Bug fixes | `1.0.5` → `1.0.6` | `10` → `11` |
| ✨ New features | `1.0.5` → `1.1.0` | `10` → `11` |
| 🔥 Major changes | `1.0.5` → `2.0.0` | `10` → `11` |

### 📝 Step-by-Step Instructions

**⚠️ IMPORTANT**: You must update **ALL 4 FILES** every time, or your build will fail!

#### 1. **Update `pubspec.yaml`**
```yaml
# OLD
version: 1.0.5+10

# NEW
version: 1.0.6+11
```

#### 2. **Update `android/app/build.gradle.kts`**
```kotlin
defaultConfig {
    // ... other settings ...
    versionCode = 11        // ← Match the +11 from pubspec.yaml
    versionName = "1.0.6"   // ← Match the 1.0.6 from pubspec.yaml
}
```

#### 3. **Update `cloudbuild.yaml`**
```yaml
substitutions:
  _BUCKET_NAME: 'chatbot_laennec_geo'
  _VERSION_PREFIX: '1.0.6'  # ← Match pubspec.yaml
```

#### 4. **Update `cloudbuild-trigger.yaml`**
```yaml
substitutions:
  _BUCKET_NAME: "chatbot_laennec_geo"
  _VERSION_PREFIX: "1.0.6"  # ← Match pubspec.yaml
```

#### 5. **Save ALL files and push**
```bash
git add .
git commit -m "Release version 1.0.6+11 - Fixed bug in chat"
git push origin main
```

---

## 🚀 How to Deploy Your App

### 🌟 The Simple Way (Automatic)
1. **Make your changes** to the app code
2. **Update version numbers in ALL 4 files** (see above section)
3. **Use the version synchronization checklist** (see below)
4. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Release version 1.0.6+11 - Fixed bug in chat"
   ```
5. **Push to GitHub:**
   ```bash
   git push origin main
   ```
6. **🎉 Wait for magic to happen!** (Takes about 10-15 minutes)

### 🔍 How to Check if it Worked
1. Go to [Google Cloud Build Console](https://console.cloud.google.com/cloud-build/builds)
2. You should see a build running with ✅ green checkmarks
3. Check your [Play Store Console](https://play.google.com/console) for the new version

---

## 🎯 Understanding Play Store Release Types

### 🧪 Internal Testing (What We Use)
- **Who can see it**: Only people you invite
- **Perfect for**: Testing before everyone sees it
- **How it works**: Automatically goes live when build succeeds

### 🔄 Release Status Options

#### ✅ **"Completed" Release** (Current Setup)
```yaml
release_status: "completed"  # In cloudbuild.yaml
```
- **What it does**: Immediately available to your test users
- **Best for**: When you're confident the update works

#### 📝 **"Draft" Release** (Alternative)
```yaml
release_status: "draft"  # Change this in cloudbuild.yaml
```
- **What it does**: Creates the release but doesn't publish it
- **Best for**: When you want to review before publishing
- **Extra step needed**: You must manually publish from Play Console

### 🎚️ How to Switch Between Draft and Completed

1. **Open `cloudbuild.yaml`**
2. **Find this section:**
   ```yaml
   upload_to_play_store(
     json_key: "key.json",
     package_name: "com.laennecai.healthassistant",
     track: "internal",
     aab: "artifacts/app-release.aab",
     release_status: "completed"  # ← Change this line
   )
   ```
3. **Change `"completed"` to `"draft"`** if you want to review before publishing
4. **Save and push to GitHub**

### 🌍 Moving to Production (When Ready)

To release to everyone:
1. **Change the track from `"internal"` to `"production"`**
2. **Make sure `release_status` is `"completed"`**
3. **Push to GitHub**

**⚠️ Warning**: Production releases go to ALL users immediately!

---

## 🔧 Troubleshooting

### ❌ Common Problems and Solutions

#### 🔴 Build Failed - "Version code X has already been used"
**Problem**: You're trying to upload a version code that was already used
**Solution**: 
1. Check [Play Console](https://play.google.com/console) to see the highest version code used
2. Update `pubspec.yaml` to use a higher version code: `version: 1.0.6+XX` (where XX is higher than the last used)
3. Update **ALL 4 FILES** with the new version
4. Push again

#### 🔴 Build Failed - "Version code not greater than current"
**Problem**: Your new version code isn't higher than the last uploaded version
**Solution**: 
1. Open `pubspec.yaml`
2. Increase the version code: `version: 1.0.5+10` → `version: 1.0.5+11`
3. Update **ALL 4 FILES** (see version synchronization guide)
4. Push again

#### 🔴 Build Failed - "Version mismatch between files"
**Problem**: Version numbers don't match across configuration files
**Solution**: 
1. Use the **Version Synchronization Checklist** below
2. Make sure all 4 files have matching version numbers
3. Push again

#### 🔴 Build Failed - "Keystore not found"
**Problem**: Android signing is broken
**Solution**: Check that your keystore is properly uploaded to Google Secret Manager

#### 🔴 Build Failed - "Play Store credentials invalid"
**Problem**: Play Store service account key is wrong
**Solution**: Re-upload your Play Store service account key to Google Secret Manager

#### 🔴 App not showing in Play Store
**Problem**: Release is in draft mode
**Solution**: 
1. Go to [Play Console](https://play.google.com/console)
2. Find your app → Internal Testing
3. Click "Publish" on the draft release

#### 🔴 CI/CD Was Working, Now It's Broken
**Common Causes**:
- **Merge conflicts** that weren't properly resolved
- **Version numbers out of sync** across files
- **Old configuration files** not updated
- **Package name changes** during app renaming

**Solution**: Use the complete **Version Synchronization Guide** below

### 📞 Where to Get Help
1. Check [Google Cloud Build logs](https://console.cloud.google.com/cloud-build/builds)
2. Check [Play Console](https://play.google.com/console) for any warnings
3. Look at the error messages - they usually tell you exactly what's wrong!

---

## 🔄 Version Synchronization Guide

### 🚨 **CRITICAL**: Always Keep These 4 Files in Sync

When your CI/CD breaks, it's usually because these files have different version numbers:

#### ✅ **Pre-Release Checklist**

**1. Check `pubspec.yaml`:**
```yaml
version: 1.0.6+11  # ← Note these numbers
```

**2. Check `android/app/build.gradle.kts`:**
```kotlin
versionCode = 11        # ← Must match +11 above
versionName = "1.0.6"   # ← Must match 1.0.6 above
```

**3. Check `cloudbuild.yaml`:**
```yaml
_VERSION_PREFIX: '1.0.6'  # ← Must match 1.0.6 above
```

**4. Check `cloudbuild-trigger.yaml`:**
```yaml
_VERSION_PREFIX: "1.0.6"  # ← Must match 1.0.6 above
```

### 🔍 **Version Sync Verification Commands**

Before pushing, run these commands to verify sync:

```bash
# Check pubspec.yaml version
grep "version:" pubspec.yaml

# Check Android version
grep -A 2 -B 2 "versionCode\|versionName" android/app/build.gradle.kts

# Check cloudbuild.yaml version
grep "_VERSION_PREFIX" cloudbuild.yaml

# Check trigger version
grep "_VERSION_PREFIX" cloudbuild-trigger.yaml
```

### 🛠️ **How to Fix Version Sync Issues**

If your versions are out of sync:

1. **Choose the highest version code** from any of the files
2. **Add 1 to that number** for your new version code
3. **Update ALL 4 files** to use the new version
4. **Commit and push**

**Example Fix:**
```bash
# If your files show different versions, pick the highest and increment:
# pubspec.yaml: 1.0.5+10
# build.gradle.kts: versionCode = 7
# cloudbuild.yaml: _VERSION_PREFIX: '1.0.3'

# Choose highest version code (10) and increment to 11
# Update all files to: 1.0.6+11
```

---

## 📋 Quick Reference

### 🔥 Emergency Checklist - "My Build Failed!"
- [ ] Did you increase the version code number (the +X part)?
- [ ] Did you update **ALL 4 configuration files**?
- [ ] Do all 4 files have **matching version numbers**?
- [ ] Did you push to the `main` branch?
- [ ] Are there any linting errors in your code?
- [ ] Did you check the Cloud Build logs for error messages?
- [ ] Are you in the middle of a merge? (Complete it first!)

### 📊 Version Update Cheat Sheet
```yaml
# In pubspec.yaml
# Old version
version: 1.0.5+10

# Bug fix update
version: 1.0.6+11

# New feature update  
version: 1.1.0+11

# Major update
version: 2.0.0+11
```

### 🚀 Deployment Commands
```bash
# The only commands you need!
git add .
git commit -m "Release version X.Y.Z+N - What you changed"
git push origin main
```

### 📁 **The 4 Files You Must Always Update Together**
1. `pubspec.yaml` → `version: X.Y.Z+N`
2. `android/app/build.gradle.kts` → `versionCode = N` & `versionName = "X.Y.Z"`
3. `cloudbuild.yaml` → `_VERSION_PREFIX: 'X.Y.Z'`
4. `cloudbuild-trigger.yaml` → `_VERSION_PREFIX: "X.Y.Z"`

### 🔗 Important Links
- [Google Cloud Build Console](https://console.cloud.google.com/cloud-build/builds?project=sample-gcp-actions-geo)
- [Google Play Console](https://play.google.com/console)
- [Google Cloud Secret Manager](https://console.cloud.google.com/security/secret-manager?project=sample-gcp-actions-geo)
- [Storage Bucket](https://console.cloud.google.com/storage/browser/chatbot_laennec_geo?project=sample-gcp-actions-geo)

### 🎯 **Remember: The Golden Rule**
**Never update just one file!** Always update all 4 version configuration files together, or your build will fail with version conflicts.

---

## 🎉 Congratulations!

You now have a fully automated deployment system! Every time you push code to GitHub, your app will automatically:
- ✅ Build and test
- ✅ Sign with your certificates  
- ✅ Upload to Play Store

**🔑 Key to Success**: Always keep your version numbers synchronized across all 4 configuration files! 