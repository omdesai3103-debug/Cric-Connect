# Cric-Connect

A Flutter mobile app prototype for scoring grassroots cricket matches ball-by-ball and running
small tournaments, with no club or registration needed.

Built for **COMP826 Mobile Systems Development, Milestone 2** at Auckland University of Technology
(role: UI/UX Designer).

---

## Download and install (Android)

1. On an Android phone, open the
   [**Releases page**](https://github.com/omdesai3103-debug/Cric-Connect/releases/tag/v1.0.0-evaluation)
   and tap **`cric-connect-v1.0.0.apk`** under **Assets**.
2. Open the downloaded file.
3. If asked, allow **Install unknown apps** for your browser, then tap **Install**.
4. If Google Play Protect shows a warning, tap **More details → Install anyway**.

---

## Run from source

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, 3.x)
- [Android Studio](https://developer.android.com/studio) (Android SDK and emulator)
- [Git](https://git-scm.com/)
- Optional: [VS Code](https://code.visualstudio.com/) with the Flutter extension

Check your setup:
```bash
flutter doctor
```
**Flutter** and **Android toolchain** must show a tick. A cross next to *Visual Studio* can be ignored.

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/omdesai3103-debug/Cric-Connect.git
   cd Cric-Connect
   ```
2. Install the packages:
   ```bash
   flutter pub get
   ```
3. Start an Android emulator (Android Studio → *Device Manager* → ▶ on a device such as Pixel 7),
   or connect an Android phone with USB debugging turned on.
4. Run the app:
   ```bash
   flutter run
   ```
   The first build takes a few minutes.

### Troubleshooting
| Problem | Fix |
|---|---|
| `flutter` is not recognised | Add the Flutter `bin` folder to your PATH and open a new terminal |
| Build asks for an NDK version | Android Studio → SDK Manager → SDK Tools → *Show Package Details* → install the NDK version named in the error |
| `Unable to load asset` or theme not updating | Run `flutter pub get`, then stop and start the app again |

---

## How to use

1. The app opens on **Home** as a guest, so no login is needed.
2. **Score a match:** *Score* tab → **Start new match** → complete the 4 setup steps → tap one button per ball. Use **UNDO** to fix mistakes.
3. **Run a tournament:** *Tournaments* tab → **Create**, or open the sample *Auckland Friday League* and tap **Start** on a fixture.
4. **Settings and help:** ☰ menu → **Settings** (light/dark mode) or **How to use Cric-Connect**.

> Note: this is a prototype. Login is mocked and data is kept in memory, so it resets when the app closes.

---

## Repository contents

| Folder | Contents |
|---|---|
| `lib/` | App source code (MVVM: `models`, `repositories`, `viewmodels`, `views`) |
| `assets/images/` | Logo and app icon |
| `docs/design/` | UI design iterations, personas and workflow diagrams |
| `docs/testing/` | Usability testing materials and results |
| `docs/screenshots/` | Screenshots of the app running on an emulator |

---

## Author

**Omkumar Desai** (25304643), Master of Computer and Information Sciences, AUT

AI tools (Claude) were used to support learning Flutter, generating and explaining code. All design decisions, testing and evaluation were carried out by the author.
