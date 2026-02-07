# 📖 Execution Guide: SketchMage (using `dart-define`)

Since we removed the `.env` file, you must **always** pass your API key using the `--dart-define` flag. If you forget to include it, the app will run, but the variable will be empty, and Gemini will not respond.

### 🔹 The Golden Rule

Any Flutter command you use (`run` or `build`) must include this "suffix" at the end:

`--dart-define=GEMINI_API_KEY=YOUR_REAL_KEY_HERE`

---
~~~~
### 🤖 1. Android

#### To test on Emulator or Device (Debug)

```bash
flutter run --dart-define=GEMINI_API_KEY=your_real_api_key

```

#### To generate the APK (Installable file)

```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=your_real_api_key

```

#### To generate the App Bundle (For Play Store upload)

```bash
flutter build appbundle --release --dart-define=GEMINI_API_KEY=your_real_api_key

```

---

### 🌐 2. Web

#### To test in Chrome (Localhost)

```bash
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_real_api_key

```

#### To build for Production (Firebase Hosting)

```bash
flutter build web --release --dart-define=GEMINI_API_KEY=your_real_api_key

```

---

### 🍎 3. iOS

*(Note: Requires a Mac with Xcode installed)*

#### To test on Simulator or iPhone

```bash
flutter run --dart-define=GEMINI_API_KEY=your_real_api_key

```

#### To generate the IPA file (App Store / TestFlight)

```bash
flutter build ipa --release --dart-define=GEMINI_API_KEY=your_real_api_key

```

---

### ⚡ Pro Tip: Configure VS Code (Avoid typing the key every time)

Typing the long command in the terminal every time you want to test is tedious. You can configure the "Play" ▶️ button in VS Code to do it for you.

1. Create a folder named `.vscode` in the root of your project (if it doesn't exist).
2. Inside, create a file named `launch.json`.
3. Paste the following content (replace with your real key):

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "SketchMage (Debug)",
            "request": "launch",
            "type": "dart",
            "args": [
                "--dart-define=GEMINI_API_KEY=PASTE_YOUR_REAL_KEY_HERE"
            ]
        },
        {
            "name": "SketchMage (Release Mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "release",
            "args": [
                "--dart-define=GEMINI_API_KEY=PASTE_YOUR_REAL_KEY_HERE"
            ]
        }
    ]
}

```

**Now, when you press F5 or the Play button in VS Code, the key will be injected automatically.**

---

### 🛡️ Security Reminder (Google Console)

Since the key now travels inside the compiled app, make sure to restrict it in the Google Cloud Console ([console.cloud.google.com/apis/credentials](https://console.cloud.google.com/apis/credentials)):

1. **For Web:** Restrict by "Websites" and enter your domain (`your-project.web.app`).
2. **For Android:** Restrict by "Android apps" and enter your package name (`com.your.project`) and SHA-1 fingerprint.
3. **For iOS:** Restrict by "iOS apps" and enter your Bundle ID (`com.your.project`).
