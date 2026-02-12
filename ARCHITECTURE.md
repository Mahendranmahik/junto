# Project Architecture

This project follows a **simple GetX-friendly structure** that's easy to understand and maintain.

## Folder Structure

```
lib/
├── core/                    # Core functionality shared across the app
│   ├── constants/          # App-wide constants (colors, strings, etc.)
│   ├── routes/             # Route definitions and navigation
│   ├── services/          # Core services (Firebase, etc.)
│   └── utils/             # Utility functions
│
├── modules/                # Feature modules (GetX style)
│   ├── auth/              # Authentication module
│   │   ├── controllers/   # GetX controllers (state management)
│   │   ├── views/         # UI screens/pages
│   │   ├── bindings/      # Dependency bindings
│   │   ├── models/        # Data models
│   │   └── services/      # Business logic services
│   │
│   ├── chat/              # Chat module
│   │   └── [same structure]
│   │
│   └── home/              # Home module
│       └── [same structure]
│
├── shared/                # Shared resources
│   └── widgets/          # Reusable widgets
│
└── di/                    # Dependency Injection
    └── locator.dart      # Service locator setup
```

## Module Structure

Each module follows this simple pattern:

- **controllers/** - GetX controllers for state management
- **views/** - UI screens/pages
- **bindings/** - GetX bindings for dependency injection
- **models/** - Data models/DTOs
- **services/** - Business logic and API calls

## Key Principles

1. **Simplicity**: Easy to understand and navigate
2. **GetX Convention**: Follows GetX best practices
3. **Feature Isolation**: Each module is self-contained
4. **Separation of Concerns**: Clear separation between UI, logic, and data

## Adding a New Feature

1. Create a new folder under `modules/`
2. Add folders: `controllers/`, `views/`, `bindings/`, `models/`, `services/`
3. Create your controller, views, and services
4. Register services in `di/locator.dart`
5. Add routes in `core/routes/app_pages.dart`

## Benefits

- ✅ **Simple**: Easy to understand structure
- ✅ **GetX-Friendly**: Follows GetX conventions
- ✅ **Modular**: Features are isolated
- ✅ **Maintainable**: Clear organization
- ✅ **Scalable**: Easy to add new features
