<h1 align="center">🇯🇴 Jovisit - Jordan Tourism App</h1>
<h3 align="center">An immersive mobile application showcasing Jordan's cultural heritage and iconic destinations</h3>

---

### 📱 About The Project

**Jovisit** is a premium Flutter mobile application designed to promote Jordan as a world-class tourism destination. The app provides an engaging, interactive experience featuring stunning visuals, immersive content, gamification elements, and seamless navigation through Jordan's most iconic landmarks.

* 🏛️ **Explore Landmarks**: Discover iconic Jordanian destinations including Petra, Wadi Rum, Dead Sea, Jerash, Aqaba, and Amman Citadel
* 📚 **Rich Content**: Comprehensive information about each landmark including historical significance, cultural value, and travel tips
* 🎯 **Interactive Quiz**: Enhanced quiz system with gamification, scoring, and confetti celebrations
* ⭐ **Rating System**: Rate landmarks and share your feedback
* ❤️ **Favorites**: Save your favorite landmarks for quick access
* 🎮 **Gamification**: Progress tracking, achievements, and interactive elements
* 🎨 **Modern UI/UX**: Frosted glass effects, smooth animations, and beautiful design
* 🌓 **Dark/Light Theme**: System-aware theme switching
* 🎬 **Video Content**: YouTube integration and local video playback
* 🔊 **Audio Feedback**: Sound effects for interactions and quiz responses

---

### 🛠️ Tech Stack

<p align="left">
  <img src="https://skillicons.dev/icons?i=flutter,dart" />
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
</p>

**Core Technologies:**
* **Flutter 3.0+** - Cross-platform mobile framework
* **Dart 3.0+** - Programming language
* **Provider 6.1.1** - State management
* **Google Fonts 6.1.0** - Typography

**Key Packages:**
* **Video Player 2.8.2** - Video playback
* **Chewie 1.7.4** - Video player UI
* **YouTube Player Flutter 9.0.0** - YouTube video integration
* **Audio Players 5.2.1** - Audio playback and sound effects
* **Cached Network Image 3.3.1** - Optimized image loading
* **Animations 2.0.11** - Smooth page transitions
* **Confetti 0.7.0** - Celebration effects
* **Flutter Animate 4.5.0** - Advanced animations
* **Shimmer 3.0.0** - Loading placeholders
* **SharedPreferences 2.2.2** - Local data persistence
* **Flutter SVG 2.0.0** - SVG support
* **URL Launcher 6.2.0** - External links

---

### ✨ Features

#### 🎯 Core Functionality
- ✅ **Onboarding Experience**: First-time user introduction
- ✅ **Landmarks Gallery**: Browse through major Jordanian destinations
- ✅ **Detailed Information**: Comprehensive details about each landmark:
- ✅ **Enhanced Quiz System**: 
- ✅ **Favorites Management**: Save and manage favorite landmarks
- ✅ **Profile Screen**: User progress and achievements
- ✅ **Rating System**: Rate landmarks and provide feedback

---

### 📁 Project Structure

```
jovisit/
│
├── lib/
│   ├── main.dart                 # Application entry point
│   │
│   ├── core/
│   │   ├── constants/            # App constants
│   │   ├── services/             # Core services
│   │   └── theme/                # Theme configuration
│   │
│   ├── data/
│   │   ├── landmarks_data.dart   # Landmark data source
│   │   └── quiz_data.dart        # Quiz questions data
│   │
│   ├── domain/
│   │   └── providers/             # State management providers
│   │       ├── favorites_provider.dart
│   │       ├── quiz_provider.dart
│   │       └── gamification_provider.dart
│   │
│   ├── models/
│   │   ├── landmark.dart         # Landmark data model
│   │   └── quiz_question.dart    # Quiz question model
│   │
│   ├── presentation/
│   │   └── widgets/               # Reusable UI components
│   │       ├── frosted_glass_effect.dart
│   │       ├── glass_container.dart
│   │       ├── image_carousel.dart
│   │       ├── favorite_button.dart
│   │       ├── animated_fab.dart
│   │       ├── confetti_widget.dart
│   │       └── ...
│   │
│   ├── screens/                   # Screen widgets
│   │   ├── onboarding_screen.dart
│   │   ├── home_screen.dart
│   │   ├── landmarks_screen.dart
│   │   ├── landmark_detail_screen.dart
│   │   ├── quiz_screen_enhanced.dart
│   │   ├── favorites_screen.dart
│   │   ├── profile_screen.dart
│   │   └── rating_screen.dart
│   │
│   └── theme/
│       └── app_theme.dart         # App theme configuration
│
├── assets/
│   ├── audio/                     # Audio effects
│   │   ├── clapping.mp3
│   │   ├── success_chime.mp3
│   │   └── wrong-buzzer.mp3
│   └── shaders/
│       └── frosted_glass.frag     # Custom shader
│
├── pics/                          # Landmark images
│   ├── petra.jpg
│   ├── wadi-rum.jpg
│   ├── dead-sea.jpg
│   ├── jerash.jpg
│   ├── aqaba.jpg
│   └── amman-citadel.jpg
│
├── android/                       # Android platform files
├── ios/                           # iOS platform files
├── web/                           # Web platform files
├── windows/                       # Windows platform files
├── linux/                         # Linux platform files
├── macos/                         # macOS platform files
│
├── v0.7.0/                        # Version 0.7.0 archive
├── v0.8.0/                        # Version 0.8.0 archive
│
├── pubspec.yaml                   # Dependencies and assets
└── README.md                      # This file
```

---

### 🎯 Featured Landmarks

The app showcases these iconic Jordanian destinations:

1. **🏛️ Petra** - The Rose City, one of the New Seven Wonders of the World
2. **🏜️ Wadi Rum** - The Valley of the Moon, a stunning desert landscape
3. **🌊 Dead Sea** - The lowest point on Earth with unique saltwater properties
4. **🏛️ Jerash** - One of the best-preserved Roman cities outside Italy
5. **🏖️ Aqaba** - Jordan's only coastal city on the Red Sea
6. **🏰 Amman Citadel** - Historical hilltop site in the capital

---

### 🎨 Design System

- **Frosted Glass**: Custom shader-based glassmorphism effects
- **Smooth Animations**: Flutter Animate for advanced animations
- **Custom Shaders**: GLSL shaders for visual effects
- **Material Design 3**: Modern Material Design principles
- **Responsive Layout**: Adaptive layouts for different screen sizes
- **Theme System**: Comprehensive light and dark themes

---

### 🎮 Gamification Features

- **Quiz Scoring**: Track performance across quiz sessions
- **Progress Tracking**: Monitor learning progress
- **Achievements**: Unlock achievements based on activity
- **Confetti Celebrations**: Visual feedback for achievements
- **Audio Feedback**: Sound effects for correct/incorrect answers
- **Haptic Feedback**: Tactile responses for better UX

---

### 📱 Screens

- **Onboarding**: First-time user introduction
- **Home**: Hero section with featured landmarks and quick actions
- **Discover**: Browse all landmarks with search and filtering
- **Landmark Detail**: Comprehensive information with image carousels
- **Quiz Enhanced**: Interactive quiz with gamification
- **Favorites**: Saved landmarks collection
- **Profile**: User progress, achievements, and settings
- **Rating**: Rate landmarks and provide feedback

---

### 👨‍💻 Developer

**Laith Amin Alawneh**

* Mobile App Developer | Flutter Enthusiast
* Building immersive, user-friendly mobile applications
* Passionate about UI/UX design and gamification

---

### 📝 Notes

* This project was developed as part of BTEC Level 3 Unit 7 coursework
* The application demonstrates modern Flutter development practices
* Features gamification elements for enhanced user engagement
* Includes custom shaders for advanced visual effects
* Optimized for performance with image caching and lazy loading
* Local data persistence using SharedPreferences
* Version history maintained in `v0.7.0/` and `v0.8.0/` directories

---

### 🔄 Version History

- **v0.7.0** - Initial version with core features
- **v0.8.0** - Enhanced UI and bug fixes
- **v1.0.0** - Current version with all features and improvements

---

### 📄 License

This project is created for educational purposes.

---

### 🙏 Acknowledgments

* Jordan Tourism Board for inspiration
* Flutter community for excellent resources and packages
* All contributors and testers who provided valuable feedback

---

### 🌟 Key Highlights

* 🎨 **Modern Design**: Frosted glass effects and smooth animations
* 🎮 **Gamification**: Progress tracking and achievements
* 🎬 **Rich Media**: YouTube integration and local video playback
* 🔊 **Audio Feedback**: Sound effects for enhanced UX
* 🌓 **Theme Support**: Automatic dark/light mode
* 📱 **Cross-Platform**: Android, iOS, Web, Windows, Linux, macOS

---

<p align="center">
  <b>Built with ❤️ using Flutter</b>
  <br>
  <i>Discover the beauty of Jordan 🇯🇴</i>
</p>
