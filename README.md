# Pocket Utility

Pocket Utility is a comprehensive, all-in-one toolbox application built with Flutter. It consolidates over 40 everyday utilities and developer tools into a single, cohesive, and performant mobile experience.

## Features

The application is modularized by feature, offering tools across several categories:

* **Calculators & Converters:** Standard Calculator, Currency Converter, Unit Converter, BMI Calculator, Discount Calculator, Age Calculator, Loan Calculator, Tip Calculator, Unit Price Calculator.
* **Developer Tools:** JSON Formatter, Markdown Preview, Base64 Encoder/Decoder, Hash Generator, UUID Generator, URL Encoder/Decoder, Color Picker & Palette, ASCII/Binary/Hex Converters, Lorem Ipsum Generator.
* **Hardware & Sensors:** Compass, GPS Info, Level, Sound Meter, Speedometer, Pedometer, Flashlight, Magnifier, Sensors Data, QR Scanner.
* **Time & Productivity:** World Clock, Stopwatch, Timer, Pomodoro Timer, Alarm.
* **Text & Utilities:** Clipboard Manager, Word Counter, Whitespace Remover, Text Repeater, Morse Code, TTS (Text-to-Speech), Password Generator, Dice Roller, Coin Flipper, Random Picker.

## Project Structure

The codebase is organized using a feature-first approach for scalability and maintainability.

```text
lib/
├── core/
│   ├── providers/          # Global state management
│   ├── theme/              # Theming and styling constants
│   └── utils/              # Shared helper functions
├── features/
│   ├── dashboard/          # Main landing screen & tool grid
│   ├── device_info/        # Device stats & app settings
│   ├── emergency/          # Quick emergency utilities
│   ├── onboarding/         # First-time setup & permissions
│   ├── splash/             # Application initialization
│   └── tools/              # Individual utility modules
│       ├── age_calculator/
│       ├── alarm/
│       ├── base64/
│       ├── calculator/
│       ├── compass/
│       ├── qrcode_scanner/
│       └── ... (40+ individual tools)
└── main.dart               # Application entry point
```

## Getting Started

### Prerequisites

* Flutter SDK (`^3.10.4` or higher)
* Dart SDK

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kiran-embedded/pocket-utility.git
   ```
2. Navigate to the project directory:
   ```bash
   cd pocket-utility
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
