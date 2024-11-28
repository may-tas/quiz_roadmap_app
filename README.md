# Exercise Roadmap Application

An interactive roadmap app developed using Flutter that presents daily exercises in an engaging format. The app tracks progress, unlocks new days and exercises sequentially, and stores user data in Firestore with persistent storage using `shared_preferences`.

---

## Table of Contents

1. [Setup & Compilation Instructions](#setup--compilation-instructions)
2. [Architecture Overview](#architecture-overview)
3. [Design Decisions](#design-decisions)
4. [Known Limitations](#known-limitations)
5. [Database Schema Documentation](#database-schema-documentation)

---

## Setup & Compilation Instructions

### Prerequisites

1. [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.24.3)
2. [Firebase CLI](https://firebase.google.com/docs/cli) installed and configured
3. Android Studio/VS Code with Flutter and Dart plugins
4. A valid Firebase project configured with Firestore

### Steps to Run the App

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```
2. **Install Dependencies**
   ```bash
   flutter pub get
   ```
3. **Run the App**
   ```bash
   flutter run
   ```

## Architecture Overview

### Layered Architecture

- UI Layer: Handles the display of the roadmap and exercises (views and widgets).
- State Management: Cubit (Bloc) for managing the state of the roadmap and exercises.
- Data Layer:
  - Firestore for storing exercises, questions, and user progress.
  - shared_preferences for local persistence of UI state.

### Folder Structure

        lib/
    ├── cubits/                  # State management
    ├── models/                  # Data model (Question)
    ├── services/                # Firebase setup , helper methods and Firestore interaction logic
    ├── presentation/            # UI components (screens, widgets)
    ├── utils/                   # routes
    └── main.dart                # App entry point

## Design Decisions

1. State Management: Cubit was chosen for its simplicity and predictable state handling.
2. Firestore Integration: Firestore ensures scalable, real-time data syncing.
3. Custom Animations: Custom animations using CustomPainter and AnimationController create a dynamic user experience.
4. Data Persistence: shared_preferences allows local data storage, ensuring a seamless user experience even during network interruptions.

## Known Limitations

1. Node Placement: Nodes are randomly positioned horizontally, which may overlap on smaller devices.
2. Offline Support: The app has limited offline functionality since it requires an internet connection to sync with Firestore.
3. Customization: The UI adheres closely to the provided design, with minimal flexibility for further customization.
4. Scores : Currently the excercises doesn't show scores after completing them in front of their names.

### Database Schema Documentation

### users collection :

```yaml
JohnDoe:
  progress:
    day1:
      exercise1: true
      exercise2: false
      exercise3: false
    day2:
      exercise1: false
      exercise2: false
  unlockedDays:
    - day1
    - day2
```

### roadmap collection :

```yaml
day1:
title: "Adjectives"
exercises:
  - title: "Compound Adjectives"
    questions:
      - question: "The company implemented a _ security protocol for their data centers."
        options:
          - "cutting-edge"
          - "cutting edge"
          - "edge-cutting"
          - "edge cutting"
        answer: "cutting-edge"
      - question: "The physicist presented a _ theory about quantum entanglement."
        options:
          - "ground breaking"
          - "ground-breaking"
          - "breaking-ground"
          - "break-grounding"
        answer: "ground-breaking"

  - title: "Participle Adjectives"
    questions:
      - question: "The _ evidence presented at the trial changed the jury's perspective."
        options:
          - "overwhelming"
          - "overwhelmed"
          - "overwhelm"
          - "overwhelms"
        answer: "overwhelming"
```
