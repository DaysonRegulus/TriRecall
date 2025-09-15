# TriRecall

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

A focused, offline-first spaced repetition app designed for efficient, date-based revision, initially tailored for GATE CS + DA preparation.

## About The Project

TriRecall was born from the need for a simple, distraction-free tool to manage a spaced repetition study schedule. The core principles of the app are the "3 R's": **Repetition**, **Recall**, and **Retrieval**.

This project began with a comprehensive specification for a two-user, cloud-synchronized application using Supabase. However, to prioritize the core user experience and ensure the fastest path to a usable tool, the development pivoted to a **100% offline-first, single-user architecture**. All data is stored locally on the user's device, ensuring speed, privacy, and full functionality without an internet connection.

The application serves as the "scheduling brain" for your revision, telling you *what* to study and *when*, while your physical notes remain the "knowledge base."

## Features

*   ✅ **100% Offline-First:** All data is stored locally on your device using an SQLite database. No internet connection is required.
*   ✅ **Subject Management:** Create and organize your study material into subjects, each with a unique, user-selected custom color.
*   ✅ **Topic Creation:** Easily add new topics with detailed notes and associate them with a subject.
*   ✅ **Custom Study Dates:** Log topics you learned in the past by selecting a custom `studied_on` date, ensuring the SRS schedule is always accurate.
*   ✅ **Spaced Repetition System (SRS):** A robust, built-in SRS engine schedules your reviews on a fixed interval schedule: **1, 3, 7, 15, and 30 days**.
*   ✅ **"Today" Dashboard:** The main screen gives you an at-a-glance summary of exactly how many topics are due for review today.
*   ✅ **Focused Review Sessions:** Enter a dedicated review mode to go through your due topics one by one, with clear action buttons ("Mastered," "Revised," "Needs Work," "Reset") to record your progress.
*   ✅ **Subject-Specific Views:** Drill down into any subject to see a complete list of its associated topics.
*   ✅ **Sorting & Filtering:** Easily sort and filter your topics within a subject by status (All, Active, Mastered) or order (Newest, Oldest, Due Soonest).

## Technology Stack

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Language:** [Dart](https://dart.dev/)
*   **State Management:** [Flutter Riverpod](https://riverpod.dev/)
*   **Local Database:** [sqflite](https://pub.dev/packages/sqflite)
*   **Key Packages:**
    *   `path_provider`: To find the correct local path for the database.
    *   `intl`: For user-friendly date formatting.
    *   `flutter_colorpicker`: For the custom subject color picker UI.
*   **Dev Tools:**
    *   `flutter_launcher_icons`: To generate the application icon.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   **Flutter SDK:** Make sure you have the Flutter SDK installed on your machine. You can follow the official guide [here](https://docs.flutter.dev/get-started/install).
*   **Code Editor:** An editor like VS Code with the Flutter extension is recommended.
*   **Emulator/Device:** An Android Emulator set up via Android Studio or a physical Android device.

### Installation & Running

1.  **Clone the repo:**
    ```sh
    git clone https://github.com/your_username/trirecall.git
    ```
2.  **Navigate to the project directory:**
    ```sh
    cd trirecall
    ```
3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```
4.  **Run the app:**
    ```sh
    flutter run
    ```

## Building for Release

To install a fast, optimized version of the app on your physical Android phone:

1.  **Run the build command:**
    ```sh
    flutter build apk --release
    ```
2.  **Locate the APK:** The command will output the path to the installable file, typically located at `build\app\outputs\flutter-apk\app-release.apk`.
3.  **Install on your device:** Copy this `.apk` file to your phone and tap on it to install. You may need to enable "Install from unknown sources" in your phone's settings.

**⚠️ Important:** This is a fully offline application. All data is stored on your device. Uninstalling the app or clearing its data will permanently delete all your subjects and topics.

## Project Structure

The project follows a clean, feature-first architecture to keep the code organized and scalable.

```
lib/
├── core/               # Shared code: models, services (DB), utils, theme
│   ├── models/
│   ├── services/
│   ├── theme/
│   └── utils/
├── features/           # Each major feature gets its own folder
│   ├── dashboard/      # The main "Today" screen and Nav Hub
│   ├── review/         # The review session screen and logic
│   ├── subjects/       # Subject list and creation screens
│   └── topics/         # Topic list and creation screens
└── main.dart           # The main entry point of the application
```

## Roadmap: Future Enhancements

The current version provides a complete offline-first experience. Future development can focus on re-introducing the features from the original specification:

*   **Cloud Backup & Sync:** Integrate with a backend service like Supabase to enable cloud backups and synchronization across devices.
*   **User Authentication:** Add user accounts to support the cloud sync feature.
*   **Analytics Dashboard:** Build the analytics screen with progress charts and a calendar heatmap as originally planned.
*   **Data Import/Export:** Create a feature to manually export the local database as a backup file and import it.

---