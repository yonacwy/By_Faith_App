# By Faith App

A cross platform application built with Flutter, designed to provide resources for reading, studying, praying, and evangelism

## Features

- **Home:** Features a dashboard.
- **Gospel:** Content related to the Gospel, and integration of map data, potentially for         geographical context related to soul winning or missions.
- **Pray:** Features to support a prayer life.
- **Read:** Access to read the KJV Bible.
- **Study:** Tools and resources for in-depth study of the scriptures using Strong's Greek and Hebrew KJV definitions.

## Getting Started

This project is a Flutter application. To get started:

1. Ensure you have Flutter installed. Follow the official guide: [Install Flutter](https://docs.flutter.dev/get-started/install)
2. Clone the repository:
   ```bash
   git clone <repository_url>
   ```
3. Navigate to the project directory:
   ```bash
   cd by_faith_app
   ```
4. Get the project dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/`: Contains the main application code.
  - `adapters/`: Adapters for various data models.
  - `assets/`: Application assets, including maps and map data.
    - `maps/`: Map files and render themes.
  - `bible_data/`: Bible texts and dictionaries.
  - `models/`: Data models.
  - `providers/`: State management providers.
  - `ui/`: User interface components and pages.
  - `main.dart`: Application entry point.

## Contributing

Contributions are welcome! Please see the CONTRIBUTING.md (if it exists) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
