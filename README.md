# Expense Tracker App

A Flutter-based expense tracking application with a clean and intuitive user interface.

## Features

- [x] Modern UI with Material Design 3
- [x] Navigation using Go Router
- [x] CI/CD Pipeline with GitHub Actions
- [ ] Expense management (coming soon)
- [ ] Data persistence (coming soon)
- [ ] Reports and analytics (coming soon)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/mahmoudgalal1989/expense_app.git
   cd expense_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Development Setup

### Git Hooks

This project includes a pre-push Git hook that runs essential checks before allowing a push to the remote repository. The hook will:

1. Check for uncommitted changes
2. Run Flutter analyzer
3. Check code formatting
4. Run tests

The hook is automatically configured when you clone the repository. If you need to manually set it up, run:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-push
```

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment. The pipeline includes:

- **Linting**: Ensures code quality and style consistency
- **Testing**: Runs all unit and widget tests with coverage reporting
- **Building**: Creates release builds for Android and web
- **Artifacts**: Uploads APK and web build artifacts for each push to main

### Code Coverage

Code coverage reports are uploaded to Codecov. To view coverage:

1. Set up a Codecov account (if not already done)
2. Add your `CODECOV_TOKEN` to the GitHub repository secrets
3. View coverage reports at [Codecov](https://about.codecov.io/)

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
