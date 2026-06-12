# RoboBuilders 🤖

A kid-friendly mobile game (ages 7–13, **no coding experience needed**) that teaches the
**engineering design cycle** by building and programming robots. Built with **Flutter**, so the
same code runs on both **iOS and Android**.

## What the game does

Each level presents a problem on a grid. To solve it the player follows the real engineering loop:

1. **Design the Robot** — drag-and-drop components (wheels, sensors, tools) onto a base chassis.
2. **Program it** — snap together **block-coding** instructions (Move, Turn, Grab, Repeat loops).
3. **Test & Improve** — run the robot. If it fails, redesign and retest.

Extra features from the idea:

- 🎓 **Each level teaches a new concept** — movement, turning, loops, sensors, tools, then a full combined build.
- 🔓 **Progressive unlocks** — finishing levels unlocks new parts (Distance Sensor, Gripper Arm).
- 🪙 **Coins** — earned on first completion of a level.
- 🛍️ **Robot Shop** — spend coins on patterns and accessories to customize your robot.
- 🤖 **AI robot mentor ("Volt")** — gives context-aware tips on every screen and reacts when a test run fails.
- 💾 **Progress is saved** on the device (coins, unlocks, completed levels).

## Project structure

```
lib/
  main.dart                 App entry + splash
  models/                   Data models (component, block, level, game_state)
  data/                     Static content (components, levels, shop items)
  utils/simulator.dart      Pure robot-run engine (also unit-tested)
  widgets/                  Reusable UI (mentor bubble, coin badge, robot view)
  screens/                  Home, Level Select, Level (Design→Code→Test), Shop
test/                       Unit tests for the simulation engine
```

---

## ▶️ How to run it

> The `android/` and `ios/` native folders are **not** checked into git (standard Flutter practice).
> You generate them once with `flutter create .` — see step 3. This does **not** touch the game code in `lib/`.

### 0. Install Flutter (one time)

- Install Flutter (3.16 or newer recommended): https://docs.flutter.dev/get-started/install
- Verify everything is set up:
  ```bash
  flutter doctor
  ```

### Run in VS Code (Android emulator, iOS simulator on Mac, or a real device)

1. Open VS Code and install the **Flutter** extension (it pulls in the Dart extension too).
2. Open this project folder (`RoboApp`) in VS Code.
3. Open a terminal (`` Ctrl+` ``) **inside the project folder** and generate the native projects + dependencies:
   ```bash
   flutter create .
   flutter pub get
   ```
4. Pick a device in the bottom-right status bar of VS Code (an emulator/simulator or a plugged-in phone).
5. Press **F5** (or Run ▸ Start Debugging). The app builds and launches with hot reload.

To run from the terminal instead:
```bash
flutter run
```

### Run on iPhone / iOS Simulator with Xcode (Mac only)

1. Make sure Xcode is installed (App Store) and its command-line tools are set up:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
2. From the project folder, generate native projects, get packages, and install iOS pods:
   ```bash
   flutter create .
   flutter pub get
   cd ios && pod install && cd ..
   ```
   (If you don't have CocoaPods: `sudo gem install cocoapods`.)
3. Open the iOS workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ Open `Runner.xcworkspace`, **not** `Runner.xcodeproj`.
4. In Xcode, select the **Runner** target ▸ **Signing & Capabilities**, choose your Apple ID **Team**,
   and set a unique **Bundle Identifier** (e.g. `com.yourname.robobuilders`). Required to run on a real iPhone.
5. Choose a simulator (e.g. *iPhone 15*) or your connected iPhone from the device menu, then press the
   ▶️ **Run** button.

> Tip: For day-to-day development just use `flutter run` / VS Code. Use Xcode mainly for iOS signing,
> running on a physical iPhone, or building for the App Store.

### Run the tests

```bash
flutter test
```

---

## How to play (for a kid)

1. Tap **Play**, choose **Level 1**.
2. **Design:** drag the wheels onto the *Wheels* mount, then tap **To Coding**.
3. **Code:** tap blocks (like *Move Forward*) to add them. Use **Repeat** for long paths.
4. **Test:** press **TEST ROBOT** and watch it go. If it misses the goal, tap **Edit my program**, fix a block, and test again.
5. Win coins, unlock new parts, and visit the **Robot Shop** to decorate your robot!
