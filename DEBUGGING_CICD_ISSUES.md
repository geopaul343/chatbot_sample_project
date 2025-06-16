# 🚨 CICD Flutter App Debugging Guide

## Quick Issue Identification Checklist

When your Flutter app crashes after CICD setup, follow this systematic approach:

### 1. **Immediate Checks (First 5 minutes)**

```bash
# Check for basic compilation errors
flutter analyze

# Check dependencies
flutter pub get

# Check Flutter environment
flutter doctor -v
```

### 2. **Critical Error Patterns**

| Error Pattern | Likely Cause | Quick Fix |
|---------------|--------------|-----------|
| `ClassNotFoundException: MainActivity` | Package name mismatch | Check MainActivity location |
| `depend_on_referenced_packages` | Missing dependency | Add to pubspec.yaml |
| `GradleException: keystore not found` | Android signing config | Make signing optional for debug |
| `The Dart compiler exited unexpectedly` | Syntax/import errors | Check main.dart and imports |

## 🔍 Detailed Debugging Steps

### **Step 1: Analyze Flutter Output**
```bash
flutter analyze --verbose
```
**Look for:**
- Missing dependencies (`depend_on_referenced_packages`)
- Import errors
- Syntax issues

### **Step 2: Check Android Configuration**

#### **A. Verify MainActivity Location**
```bash
find android/app/src -name "MainActivity.kt" -o -name "MainActivity.java"
```

**Expected Location Pattern:**
```
android/app/src/main/kotlin/com/[your]/[package]/[name]/MainActivity.kt
```

**Common Issues:**
- MainActivity in wrong package directory
- Package declaration doesn't match app package name
- File completely missing

#### **B. Check Package Names Match**

**Files to verify:**
1. `android/app/build.gradle.kts` → `applicationId`
2. `MainActivity.kt` → `package` declaration
3. `AndroidManifest.xml` → Activity name reference

```bash
# Quick check for package consistency
grep -r "applicationId" android/app/build.gradle.kts
grep -r "package " android/app/src/main/kotlin/
```

#### **C. Android Build Configuration**
Check `android/app/build.gradle.kts` for:
```kotlin
// ❌ PROBLEMATIC: Forces keystore for debug
signingConfig = signingConfigs.getByName("release")

// ✅ CORRECT: Conditional signing
if (keystorePropertiesFile.exists()) {
    signingConfig = signingConfigs.getByName("release")
}
```

### **Step 3: Dependency Issues**

#### **Check pubspec.yaml vs actual imports**
```bash
# Find all import statements
grep -r "import 'package:" lib/ | grep -v "flutter" | sort | uniq

# Compare with pubspec.yaml dependencies
cat pubspec.yaml | grep -A 20 "dependencies:"
```

#### **Common Missing Dependencies After CICD:**
- `bloc: ^9.0.0` (if using flutter_bloc)
- Platform-specific packages
- Custom dependencies removed during CICD setup

### **Step 4: Runtime Crash Debugging**

#### **Get Detailed Logs**
```bash
# Clear and monitor logcat for Android crashes
adb logcat -c
adb logcat | grep -E "(flutter|[your-package-name]|FATAL|AndroidRuntime)"

# Or run with verbose output
flutter run --verbose 2>&1 | tee flutter_debug.log
```

#### **Key Error Patterns to Look For:**

**ClassNotFoundException:**
```
E/AndroidRuntime: java.lang.ClassNotFoundException: 
Didn't find class "com.yourpackage.MainActivity"
```
→ **Fix:** Correct MainActivity package structure

**Asset Loading Errors:**
```
E/flutter: Unable to load asset: assets/your_file.png
```
→ **Fix:** Verify assets exist and pubspec.yaml asset declarations

**Network/Permission Errors:**
```
E/flutter: SocketException: Failed host lookup
```
→ **Fix:** Check AndroidManifest.xml permissions

## 🛠️ Standard Fix Commands

### **Complete Clean & Rebuild**
```bash
# Full cleanup
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf android/.gradle/

# Fresh start
flutter pub get
flutter pub upgrade --major-versions
flutter run
```

### **Android-Specific Cleanup**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

### **Fix MainActivity Package Issues**
```bash
# 1. Find current package name in build.gradle
grep applicationId android/app/build.gradle.kts

# 2. Create correct directory structure
mkdir -p android/app/src/main/kotlin/com/your/package/name

# 3. Create/move MainActivity.kt with correct package
```

## 📋 Prevention Checklist

### **Before CICD Setup:**
- [ ] Document current package names
- [ ] Backup MainActivity.kt location
- [ ] Save pubspec.yaml dependencies list
- [ ] Note any custom Android configurations

### **After CICD Setup:**
- [ ] Verify MainActivity package/location
- [ ] Check all dependencies still present
- [ ] Test debug build (not just release)
- [ ] Verify asset loading still works
- [ ] Run flutter analyze
- [ ] Test on device/emulator

## 🆘 Emergency Quick Fixes

### **App Won't Start (ClassNotFoundException)**
```bash
# Quick fix MainActivity issue
find android/app/src -name "*.kt" -exec grep -l "MainActivity" {} \;
# Move to correct package location based on applicationId
```

### **Missing Dependencies**
```bash
# Add missing common dependencies
flutter pub add bloc
flutter pub add flutter_bloc
flutter pub get
```

### **Build Failures**
```bash
# Reset to working state
git checkout HEAD -- android/app/build.gradle.kts
git checkout HEAD -- android/app/src/main/AndroidManifest.xml
flutter clean && flutter pub get
```

## 📞 When to Escalate

**Escalate to senior developer when:**
1. Multiple package name mismatches across files
2. Custom native Android/iOS code modifications needed
3. Complex keystore/signing issues in production
4. Platform-specific dependency conflicts
5. Flutter engine or framework-level errors

## 📚 Useful Commands Reference

```bash
# Debugging Commands
flutter analyze --verbose
flutter run --verbose
flutter doctor -v
adb logcat | grep flutter

# Package/File Finding
find . -name "MainActivity.*"
grep -r "package " android/app/src/
grep -r "applicationId" android/

# Cleanup Commands
flutter clean
rm -rf build/ .dart_tool/
flutter pub get

# Build Testing
flutter build apk --debug
flutter install
```

---

## 💡 Pro Tips

1. **Always test debug builds** after CICD changes, not just release builds
2. **Keep a backup** of working Android configuration files
3. **Document package name changes** during CICD setup
4. **Use version control** to easily revert problematic changes
5. **Test incrementally** - don't change everything at once

**Remember:** Most CICD issues are configuration mismatches, not code bugs! 