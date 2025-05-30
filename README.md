# Budget_Buddy 💸

A smart budgeting app that helps you manage your finances using the 50/30/20 rule, built with Flutter and Firebase.

## Features ✨

- 🔒 Firebase Authentication (Email/Password)
- 💰 Set monthly income and auto-calculate budget allocations
- 📊 50/30/20 Budget Rule Breakdown:
  - Needs (50%)
  - Wants (30%)
  - Savings (20%)
- 📝 Track expenses with customizable categories
- 📈 Visual progress bars for each budget category
- 📅 Transaction history with date tracking
- 🗑️ Swipe-to-delete transactions
- 🔄 Real-time sync with Firebase Firestore
- 🎨 Modern UI with Google Rubik font
- 🔄 Pull-to-refresh functionality

## Tech Stack 🛠️

- **Flutter** - Frontend framework
- **Firebase** - Backend services:
  - Authentication
  - Firestore Database
- **Google Fonts** - Typography

## Installation ⚙️

### Prerequisites
- Flutter SDK (version 3.0 or newer)
- Dart (version 2.17 or newer)
- Firebase project (see setup below)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/RushirajRavalji/buddget_buddy.git
   cd Budget_Buddy
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Firebase Setup:
   - Create a new Firebase project at [console.firebase.google.com]
   - Enable Email/Password authentication
   - Set up Firestore database with following rules:
     ```rules
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /users/{userId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
     ```
   - Add your Firebase configuration:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies 📦

Main packages used:
- `firebase_core: ^2.18.0`
- `firebase_auth: ^4.11.1`
- `cloud_firestore: ^4.14.1`
- `intl: ^0.18.1`
- `google_fonts: ^4.0.4`

## Usage 📱

1. **Authentication**
   - Sign up with email/password
   - Existing users can log in directly

2. **Set Monthly Income**
   - Enter your monthly income
   - Budget allocations auto-calculate using 50/30/20 rule

3. **Add Transactions**
   - Tap + button to add new entries
   - Select from predefined categories
   - Add optional descriptions

4. **Track Progress**
   - Visual progress bars show spending against budget
   - View recent transaction history
   - Swipe left to delete entries

5. **Security**
   - Log out using the logout button in app bar

## Contributing 🤝

Contributions are welcome! Please follow these steps:
1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


The security rules provided are basic - you might want to enhance them based on your specific security requirements.