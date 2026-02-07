## 🏗️ 1. Project Initialization
Run these commands once to link your Flutter project with Firebase and set up GitHub integration.

### Login & Init
```bash
# 1. Login to Google
firebase login

# 2. Initialize Hosting
firebase init hosting

```

### Configuration Wizard Answers:

* **Public directory:** `build/web`
* **Configure as a single-page app?** `Yes`
* **Set up automatic builds and deploys with GitHub?** `Yes`
* *This will ask for your GitHub credentials.*
* *It creates a Service Account secret in your repo automatically.*


* **For which GitHub repository would you like to set up a GitHub workflow?** `username/repo-name`
* **Set up the workflow to run a build script before every deploy?** `Yes`
* *Script to run:* `flutter build web --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY`


* **Set up automatic deployment to your site's live channel when a PR is merged?** `Yes`

---

## 🛠️ 2. Manual Deployment (Quick Fixes)

Use this method when testing locally or if GitHub Actions is failing.

```bash
# 1. Build the web app (Injecting the Key)
flutter build web --release --dart-define=GEMINI_API_KEY=YOUR_REAL_KEY_HERE

# 2. Deploy to Live Channel
firebase deploy --only hosting

```

---

## 🤖 3. Automated Deployment (GitHub Actions)

This allows the app to deploy automatically when you push code to GitHub.

### ⚠️ Critical Setup for API Keys

Since we are **not** using `.env` files, you must add your API Key to GitHub Secrets for the automation to work.

1. Go to your GitHub Repo > **Settings** > **Secrets and variables** > **Actions**.
2. Click **New repository secret**.
3. Name: `GEMINI_API_KEY`
4. Value: `Paste_Your_Real_Google_Studio_Key_Here`

### The Workflow File (`.github/workflows/firebase-hosting-merge.yml`)

Ensure your YAML file looks like this to properly inject the key during the build:

```yaml
name: Deploy to Firebase Hosting on merge
on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # 1. Install Flutter
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      # 2. Get Dependencies
      - run: flutter pub get

      # 3. Build Web (Injecting the Secret Key)
      - run: flutter build web --release --dart-define=GEMINI_API_KEY="${{ secrets.GEMINI_API_KEY }}"

      # 4. Deploy to Firebase
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_SKETCHMAGE_FC268 }}'
          channelId: live
          projectId: sketchmage-fc268

```

---

## 🧪 4. Preview Channels (Temporary URLs)

If you want to share a test version without replacing the live site.

**Option A: Automatic (Pull Requests)**
Just open a Pull Request in GitHub. The action will automatically deploy a preview link (e.g., `https://sketchmage-fc268--pr-123.web.app`).

**Option B: Manual Command**

```bash
# Deploy to a temporary channel named 'beta' that expires in 7 days
firebase hosting:channel:deploy beta --expires 7d

```

---

## 📝 Summary of Commands

| Action | Command |
| --- | --- |
| **Login** | `firebase login` |
| **Setup** | `firebase init hosting` |
| **Build (Manual)** | `flutter build web --release --dart-define=GEMINI_API_KEY=...` |
| **Deploy (Live)** | `firebase deploy --only hosting` |
| **Deploy (Preview)** | `firebase hosting:channel:deploy beta` |

