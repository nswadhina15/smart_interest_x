# SmartInterestX 💸

A modern, cloud-synced financial tracking application designed to simplify the management of personal loans, borrowed amounts, and accrued interest. 

Unlike traditional ledger apps, SmartInterestX focuses on a seamless user experience, offering real-time data synchronization, smart alerts for upcoming due dates, and secure receipt management.

## ✨ Key Features

* **Smart Priority Alerts:** A logic-driven dashboard that actively monitors loan due dates and surfaces urgent actions automatically.
* **Dynamic Theming:** Built-in Light and Dark mode support, utilizing state management for seamless, instant transitions without app reloads.
* **Cloud Document Storage:** Direct integration with device galleries to upload, crop, and store transaction receipts securely in the cloud.
* **Micro-Interactions:** Premium user experience featuring dynamic Lottie animations for database write confirmations.
* **Real-Time Analytics:** Visual representation of financial flow using interactive bar charts and automated interest calculations.

## 🛠️ Tech Stack

**Frontend Framework:** Flutter (Dart)
**Backend & Database:** Firebase (Authentication, Cloud Firestore)
**Media Storage:** Cloudinary API
**State Management:** Provider
**Visuals & UI:** `fl_chart` (Analytics), `lottie` (Animations)

## 🏗️ Project Architecture

The application follows a clean separation of concerns:
* `/models`: Data structures defining Transactions and Contacts.
* `/services`: Business logic handling API calls, database reads/writes, and state management (`auth_service`, `database_service`, `theme_provider`).
* `/screens`: UI components divided by feature (Dashboard, Transactions, Authentication).
* `/assets`: Root-level storage for static files and Lottie JSON animations.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.19.0 or higher)
* Android Studio (Configured for API 36 / Android 16)
* A Firebase Project with Firestore and Authentication enabled.

### Installation

1. **Clone the repository**
   ```bash
   git clone [https://github.com/nswadhina15/smart_interest_x]
   cd smart_interest_x

2. **Install Dependencies**
    ```bash
    flutter pub get


3. **Configure Environment**
    - Place your google-services.json file in the android/app/ directory.

    - Ensure your Cloudinary API keys are configured in the services folder.

4. **Run the App**
    ```bash
    flutter run