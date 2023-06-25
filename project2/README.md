# Device-Agnostic Design Course Project II - 5f31bd29-7026-4af6-a49a-1f51a612da11

## Name
Recipes

## Description
This one should pass with merits. The Recipes Application is designed to provide users with a platform to browse and search for recipes based on various categories. The application also includes user authentication, allowing users to log in. Once logged in, users can save recipes as favorites, create or edit their own recipes visible to everyone, and delete their own recipes.

## 3 key challenges faced during the project
1. Using the firebase and login was challenging.
2. Creating the layout and design of the app was a significant challenge, as the app needed to be aesthetically pleasing while being functional.
3. Managing state in the app was a challenge, as the state of the app needed to be maintained throughout the app and updated when needed.

## 3 key learning moments from working on the project
1. Understanding and implementing asynchronous programming concepts in Flutter.
2. Understanding and utilizing state management techniques in Flutter, such as using the Provider package.
3. Designing and implementing the user interface of the app.

## Firebase Database Structure
- recipes
  - name
  - category
  - favourites
  - ingredients
  - steps
  - creator

## pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^4.8.0
  collection: ^1.17.1
  cupertino_icons: ^1.0.2
  firebase_auth: ^4.6.2
  firebase_core: ^2.13.1
  flutter_riverpod: ^2.3.6
  go_router: ^8.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^2.0.0
```
