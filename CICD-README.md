# Laennec AI Health Assistant - CI/CD Setup Guide

This guide will help you set up a complete CI/CD pipeline for the Laennec AI Health Assistant Flutter app using Google Cloud Build.

## 📋 Prerequisites

- Google Cloud Project with billing enabled
- Flutter app with Android signing configured
- GitHub repository
- Google Play Console account with API access
- `gcloud` CLI installed and configured

## 🏗️ Architecture Overview

The CI/CD pipeline consists of 8 stages:

1. **Flutter Dependencies** - Install Flutter packages
2. **Android Signing Setup** - Configure release signing from Secret Manager
3. **Flutter Tests** - Run unit and widget tests
4. **Build Android AAB** - Create release Android App Bundle
5. **Prepare Artifacts** - Package build artifacts with version info
6. **Upload to Storage** - Store AAB in Google Cloud Storage
7. **Get Play Store Credentials** - Retrieve service account key from Secret Manager
8. **Deploy to Play Store** - Upload to Google Play Console internal track

## 🚀 Setup Instructions

### Step 1: Prepare Your Environment

1. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd chatbot_sample_project
   ```

2. **Update configuration files**
   
   Edit `setup-gcp-cicd.sh` and replace:
   - `YOUR_PROJECT_ID` with your GCP project ID
   - `YOUR_GITHUB_USERNAME` with your GitHub username
   - `YOUR_REPOSITORY_NAME` with your repository name

   Edit `cloudbuild-trigger.yaml` and update the same values.

### Step 2: Run the Setup Script

```bash
chmod +x setup-gcp-cicd.sh
./setup-gcp-cicd.sh
```

This script will:
- Enable required GCP APIs
- Create a service account with necessary permissions
- Create a storage bucket for artifacts
- Set up Cloud Build trigger

### Step 3: Configure Secrets

#### Android Keystore

1. **Upload your keystore to Secret Manager:**
   ```bash
   gcloud secrets create android-keystore --project=YOUR_PROJECT_ID
   gcloud secrets versions add android-keystore --data-file=android/app/laennec-ai-release-key.jks --project=YOUR_PROJECT_ID
   ```

#### Play Store Credentials

1. **Create a service account in Google Play Console:**
   - Go to Google Play Console → Setup → API access
   - Create a new service account or use existing one
   - Download the JSON key file

2. **Upload to Secret Manager:**
   ```bash
   gcloud secrets create playstore-credentials --project=YOUR_PROJECT_ID
   gcloud secrets versions add playstore-credentials --data-file=path/to/play-console-key.json --project=YOUR_PROJECT_ID
   ```

### Step 4: Connect GitHub Repository

1. Go to [Google Cloud Build](https://console.cloud.google.com/cloud-build/triggers)
2. Click "Connect Repository"
3. Select GitHub and authenticate
4. Choose your repository
5. Create trigger using the configuration in `cloudbuild-trigger.yaml`

### Step 5: Test the Pipeline

1. **Make a small change to your code**
2. **Commit and push to main branch:**
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```

3. **Monitor the build:**
   - Go to [Cloud Build Console](https://console.cloud.google.com/cloud-build/builds)
   - Watch your build progress

## 📁 File Structure

```
.
├── cloudbuild.yaml              # Main CI/CD pipeline configuration
├── cloudbuild-trigger.yaml     # Cloud Build trigger configuration
├── setup-gcp-cicd.sh          # GCP setup script
├── CICD-README.md              # This file
├── android/
│   ├── key.properties          # Android signing configuration
│   └── app/
│       └── build.gradle.kts    # Android build configuration
└── lib/                        # Flutter source code
```

## 🔧 Configuration Details

### Environment Variables

The pipeline uses these substitution variables:
- `_BUCKET_NAME`: Google Cloud Storage bucket name
- `_VERSION_PREFIX`: App version prefix for releases

### Secrets Used

- `android-keystore`: Your Android release keystore (.jks file)
- `playstore-credentials`: Google Play Console service account key (JSON)

### Service Account Permissions

The CI/CD service account needs these roles:
- `roles/cloudbuild.builds.builder`
- `roles/secretmanager.secretAccessor`
- `roles/storage.objectAdmin`
- `roles/logging.logWriter`

## 🐛 Troubleshooting

### Common Issues

1. **Build fails at signing step**
   - Verify keystore is uploaded to Secret Manager
   - Check key.properties file paths
   - Ensure keystore password matches key.properties

2. **Play Store upload fails**
   - Verify service account has Play Console access
   - Check package name matches your app
   - Ensure app is created in Play Console

3. **Flutter build fails**
   - Check pubspec.yaml for dependency issues
   - Verify Flutter version compatibility
   - Review test failures in build logs

### Debug Commands

```bash
# Check Cloud Build logs
gcloud builds log <BUILD_ID> --project=YOUR_PROJECT_ID

# List secrets
gcloud secrets list --project=YOUR_PROJECT_ID

# Check service account permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID

# Test storage bucket access
gsutil ls gs://chatbot_laennec_geo
```

## 📊 Monitoring

### Build Status

Monitor your builds at:
- [Cloud Build Console](https://console.cloud.google.com/cloud-build/builds)
- [Cloud Build History](https://console.cloud.google.com/cloud-build/builds)

### Artifacts

View build artifacts at:
- [Cloud Storage](https://console.cloud.google.com/storage/browser/chatbot_laennec_geo)

### Logs

Access detailed logs at:
- [Cloud Logging](https://console.cloud.google.com/logs)

## 🔄 Pipeline Customization

### Adding New Stages

To add new stages to the pipeline, edit `cloudbuild.yaml`:

```yaml
- name: 'your-custom-image'
  id: 'custom-stage'
  entrypoint: 'your-command'
  args: ['arg1', 'arg2']
  waitFor: ['previous-stage']
```

### Environment-Specific Builds

Create separate cloudbuild files for different environments:
- `cloudbuild-dev.yaml`
- `cloudbuild-staging.yaml`
- `cloudbuild-prod.yaml`

## 📚 Additional Resources

- [Google Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Fastlane for Flutter](https://docs.fastlane.tools/getting-started/cross-platform/flutter/)
- [Google Play Console API](https://developers.google.com/android-publisher)

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review build logs in Cloud Build Console
3. Verify all prerequisites are met
4. Check GCP service quotas and billing

---

**Happy Building! 🚀** 