# RPG POS

A Point of Sale (POS) system built with Flutter for managing events and transactions.

## Features

- **Login System** - Secure authentication with demo credentials
- **Event Management** - Create, view, and delete events
- **POS Interface** - Add items to cart with quantity controls
- **Transaction History** - View all past transactions grouped by date

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

### Demo Credentials

| Username | Password   |
|----------|------------|
| admin    | admin123   |
| staff    | staff123   |

## Project Structure

```
lib/
├── main.dart                    # App entry point
└── features/
    ├── models/
    │   ├── user.dart           # User model
    │   ├── event.dart          # Event model
    │   ├── item.dart           # Item model
    │   └── transaction.dart    # Transaction model
    ├── pages/
    │   ├── login_page.dart     # Login screen
    │   ├── home_page.dart      # Main/Home screen
    │   ├── pos_page.dart       # POS interface
    │   └── history_page.dart   # Transaction history
    └── services/
        └── data_service.dart   # Data persistence service
```

## Usage

1. **Login** - Use demo credentials to sign in
2. **Create Event** - Tap "New Event" to create a POS session
3. **Add Items** - In POS, tap + to add items with name and price
4. **Checkout** - Complete transaction with optional notes
5. **View History** - Access transaction history from the home screen