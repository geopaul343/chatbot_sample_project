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
7. [Quick Reference](#quick-reference)

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

---

## 🔄 How to Update Your App Version

### 🎯 When to Update Versions

| Type of Change | Version Name Change | Version Code Change |
|---------------|-------------------|-------------------|
| 🐛 Bug fixes | `1.0.5` → `1.0.6` | `10` → `11` |
| ✨ New features | `1.0.5` → `1.1.0` | `10` → `11` |
| 🔥 Major changes | `1.0.5` → `2.0.0` | `10` → `11` |

### 📝 Step-by-Step Instructions

1. **Open `pubspec.yaml` file**
2. **Find this line:**
   ```yaml
   version: 1.0.5+10
   ```
3. **Update both numbers:**
   ```yaml
   version: 1.0.6+11  # New version!
   ```
4. **Update the CI/CD configuration:**
   - Open `cloudbuild.yaml`
   - Find this line: `_VERSION_PREFIX: '1.0.5'`
   - Change it to: `_VERSION_PREFIX: '1.0.6'`

5. **Save both files**
6. **Push to GitHub** (this starts the deployment!)

---

## 🚀 How to Deploy Your App

### 🌟 The Simple Way (Automatic)
1. **Make your changes** to the app code
2. **Update version numbers** (see above section)
3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Release version 1.0.6 - Fixed bug in chat"
   ```
4. **Push to GitHub:**
   ```bash
   git push origin main
   ```
5. **🎉 Wait for magic to happen!** (Takes about 10-15 minutes)

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

#### 🔴 Build Failed - "Version code not greater than current"
**Problem**: You forgot to increase the version code
**Solution**: 
1. Open `pubspec.yaml`
2. Change `version: 1.0.5+10` to `version: 1.0.5+11` (increase the number after +)
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

### 📞 Where to Get Help
1. Check [Google Cloud Build logs](https://console.cloud.google.com/cloud-build/builds)
2. Check [Play Console](https://play.google.com/console) for any warnings
3. Look at the error messages - they usually tell you exactly what's wrong!

---

## 📋 Quick Reference

### 🔥 Emergency Checklist - "My Build Failed!"
- [ ] Did you increase the version code number (the +X part)?
- [ ] Did you push to the `main` branch?
- [ ] Are there any linting errors in your code?
- [ ] Did you check the Cloud Build logs for error messages?

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
git commit -m "Release version X.Y.Z - What you changed"
git push origin main
```

### 🔗 Important Links
- [Google Cloud Build Console](https://console.cloud.google.com/cloud-build/builds?project=sample-gcp-actions-geo)
- [Google Play Console](https://play.google.com/console)
- [Google Cloud Secret Manager](https://console.cloud.google.com/security/secret-manager?project=sample-gcp-actions-geo)
- [Storage Bucket](https://console.cloud.google.com/storage/browser/chatbot_laennec_geo?project=sample-gcp-actions-geo)

---

## 🎉 Congratulations!

You now have a fully automated deployment system! Every time you push code to GitHub, your app will automatically:
- ✅ Build and test
- ✅ Sign with your certificates  
- ✅ Upload to Play Store
- ✅ Make available to your test users

**🚀 Pro Tip**: Always test your changes locally before pushing to make sure everything works!

---

*💡 Remember: With great automation comes great responsibility. Always make sure your code works before pushing to main branch!* 