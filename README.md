#  MoveQuest

**Small steps, big adventures!**

MoveQuest is a mobile exergame developed using Flutter and Dart. The application aims to encourage higher education students to become more physically active by turning real-world movement into interactive gameplay.

Instead of focusing on competitive fitness tracking, MoveQuest provides a lighthearted adventure featuring Spud, a friendly potato character.

##  Project Goal

MoveQuest is developed as part of an individual Software Engineering project at Fontys University of Applied Sciences.

The main goal is to explore how a mobile exergame can encourage physical activity among students without increasing unnecessary digital dependency.

The application is designed around three principles:

- Encourage real-world movement.
- Keep gameplay simple and enjoyable.
- Avoid unnecessary engagement features such as daily streaks and forced login.

##  Planned Gameplay

Players explore different environments by completing movement-based challenges.

###  Sleepy Forest
A walking challenge where real steps help Spud progress through the forest.

###  Wobbly Beach
A planned adventure location with additional movement-based gameplay.

###  Potato Mountain
A planned adventure location with a more challenging activity.

The initial development focuses on making Sleepy Forest fully playable before expanding to other locations.

##  Features

### Implemented
- Welcome Screen
- Home Screen featuring Spud
- Android step-counting prototype
- Physical activity permission handling
- Walking session progress tracking
- Reset Session functionality
- 500-step prototype goal

### Planned
- Interactive Adventure Map
- Sleepy Forest gameplay
- Character movement based on physical steps
- Challenge completion screen
- Additional adventure locations
- User testing and usability improvements

##  Technologies

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Application programming language |
| Android Step Counter | Physical step detection |
| pedometer | Accessing step-count events |
| permission_handler | Managing Android activity permissions |

##  Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android device with a supported step sensor

### Installation

Clone the repository:

```bash
git clone https://github.com/Realgi022/movequest.git
cd movequest
```

Install dependencies:

```bash
flutter pub get
```

Connect an Android device and run:

```bash
flutter run
```

The application requires physical activity permission for step counting

**Note:** Step-counting functionality depends on Android sensor support. Testing on a physical Android device is recommended.

##  Development Status

MoveQuest is currently under development.

The Welcome Screen, Home Screen, and step-counting prototype have been implemented. Initial testing confirmed that physical walking can update the step counter on an Android device.

The Adventure Map and playable walking challenges are the next development priorities.

##  Testing

Initial testing was performed on an Android GM1913 device.

The following functionality has been checked:

- Application launch
- Physical activity permission request
- Step detection during walking
- Step-count updates
- Walking screen layout

Additional accuracy, usability, and device compatibility testing is planned.

##  Academic Context

**Institution:** Fontys University of Applied Sciences  
**Programme:** Software Engineering  
**Project:** Individual Project 2  
**Assessment Deadline:** 6 December 2026

MoveQuest is an educational project developed to demonstrate software engineering skills, including analysis, design, implementation, testing, and project management.

##  Developer

Developed by Realgi Hila.

GitHub: [Realgi022](https://github.com/Realgi022)

---

*Move more. Explore more. Have fun with Spud!* 🥔
