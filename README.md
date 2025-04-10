# 🎓 CET Student Dashboard

<div align="center">
  <h3>📚 A comprehensive learning and testing platform for CET preparation 📝</h3>
</div>

## 📱 Overview

CET Student Dashboard is a Flutter-based mobile application designed to help students prepare for Common Entrance Tests (CET). The application provides a comprehensive platform for students to practice tests, track performance, access learning materials, and manage their preparation journey effectively.

## ✨ Features

### 🧪 Test Preparation
- **Topic-wise Tests**: Practice tests organized by specific topics
- **Subject-wise Tests**: Complete tests for Physics, Chemistry, Biology, and Mathematics
- **Full-Length Tests**: Simulated exam experience with timed full-length tests
- **Previous Year Papers**: Access to MHT CET previous year question papers

### 📊 Performance Tracking
- **Detailed Analytics**: Track performance across subjects and topics
- **Progress Monitoring**: View improvement over time with visual charts
- **Confidence Metrics**: Analyze confidence levels for different question types

### 📚 Learning Resources
- **Subject Materials**: Organized learning content by subject
- **Chapter-wise Content**: Detailed notes and explanations for each chapter
- **Interactive Content**: Support for mathematical formulas and scientific notation

### 🔄 Additional Features
- **🔍 Grievance System**: Report issues with questions or tests
- **💬 Feedback Mechanism**: Provide feedback on the application experience
- **🔐 User Authentication**: Secure login and registration system
- **🎨 Responsive UI**: Beautiful and intuitive user interface

## 🛠️ Technology Stack

- **🔷 Frontend**: Flutter (Dart)
- **🔄 State Management**: Provider
- **🌐 API Integration**: HTTP package
- **📈 Data Visualization**: FL Chart
- **📄 Content Rendering**: Flutter HTML, Flutter Math Fork
- **💾 Local Storage**: Shared Preferences
- **🔌 Backend Integration**: RESTful API endpoints

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.27.1)
- Dart SDK (>=3.6.0)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/student_dashboard.git
```

2. Navigate to the project directory:
```bash
cd student_dashboard
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

## 📂 Application Structure

```
lib/
├── api/                  # API services and endpoints
├── models/               # Data models
├── providers/            # State management
├── screens/              # UI screens
│   ├── login_page.dart
│   ├── register.dart
│   ├── MainScreen/       # Main application screens
│   │   ├── Tests/        # Test-related screens
│   │   ├── Learn/        # Learning materials
│   │   ├── Performance/  # Performance tracking
│   │   ├── Statistics/   # Statistical analysis
│   │   ├── Feedback/     # User feedback
│   │   └── Grievance/    # Grievance reporting
├── services/             # Business logic services
├── utils/                # Utility functions
├── widgets/              # Reusable UI components
└── main.dart             # Application entry point
```

## 🧩 Key Components

### 📝 Test Interface
The application features a universal test interface that supports:
- 🔄 Mixed content rendering (text and LaTeX formulas)
- 🧭 Question navigation and marking for review
- ⏱️ Timer functionality for timed tests
- ✅ Answer selection and submission
- 📊 Performance analysis after test completion

### 🔐 Authentication System
- 🔒 Secure login with credential storage
- 📝 Registration for new users
- 🔑 Password recovery functionality

### 📚 Learning Module
- 📋 Structured content organized by subjects and chapters
- 📐 Support for rich text and mathematical formulas
- 🎮 Interactive learning experience

## 🔜 Upcoming Features

- 🎮 Gamified test levels with progression system
- 📝 Enhanced question rendering with HTML and LaTeX
- 📈 Improved performance analytics
- 🏆 Rank predictor for students
- 📊 Chapter-wise statistics
- 📋 Enhanced feedback questionnaire

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - see the LICENSE file for details.

## 🙏 Acknowledgements

- Made with ❤️ in SAKEC
- Flutter and Dart community for the excellent tools and packages
- All contributors who have helped shape this project
