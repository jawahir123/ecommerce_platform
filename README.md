# 📦 E-Commerce App

## 📌 Project Overview
This is a **Flutter-based E-Commerce Application** that allows users to browse products, add them to the cart, checkout, and manage their profile. It also includes **dark mode, authentication, and state management using GetX**.

## ✨ Features
- 🏠 **Home Screen**: Displays products fetched from the backend.
- 🛒 **Cart**: Add, remove, and update product quantities.
- 🛍️ **Order History**: View past orders.
- 👤 **Profile Management**: Edit user details.
- 🔑 **Authentication**: User login/logout using token-based authentication.

## 🏗️ Tech Stack
- **Flutter** (Dart)
- **GetX** (State Management)
- **Node.js & Express** (Backend API)
- **MongoDB** (Database)
- **Shared Preferences** (Local Storage for Auth Tokens)

## 🚀 Installation & Setup
### 1️⃣ Clone the Repository
```bash
git clone https://github.com/your-repo/ecommerce-app.git
cd ecommerce-app
```

### 2️⃣ Install Dependencies
```bash
flutter pub get
```

### 3️⃣ Run the App
For Android Emulator:
```bash
flutter run
```
For Web:
```bash
flutter run -d chrome
```

## 🌍 API Configuration
The app fetches data from a **Node.js API**. Change the **base URL** in the API requests if needed:
```dart
const BASE_URL = 'http://10.0.2.2:3000/api/';
```

## 📂 Project Structure
```
📦 ecommerce-app
 ┣ 📂 lib
 ┃ ┣ 📂 controllers      # State management using GetX
 ┃ ┣ 📂 models          # Data models
 ┃ ┣ 📂 screens        # UI Screens (Home, Cart, Profile, etc.)
 ┃ ┗ main.dart        # Main entry point
```

## 🛠️ Known Issues & Fixes
- **Image Not Loading?**
  - Ensure your backend is running (`npm start` if using Node.js).
  - Replace `localhost` with `10.0.2.2` for Android Emulator.
- **Login Issues?**
  - Check if the correct token is stored in **Shared Preferences**.

## 📜 License
This project is for educational purposes. Feel free to modify and expand.

---
### 📧 Contact
For any queries, reach out at [your-email@example.com] or [GitHub Profile](https://github.com/your-username).

