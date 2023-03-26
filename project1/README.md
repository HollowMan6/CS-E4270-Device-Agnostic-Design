# Device-Agnostic Design Course Project I - 5f31bd29-7026-4af6-a49a-1f51a612da11
Completed with merit

## Name of the application
Flutter Quiz App

## Brief description of the application
Flutter Quiz App is a mobile application built using Flutter that allows users to take quizzes on different topics. The app connects to an existing Quiz API to retrieve topics and randomly generated questions. The user is presented with a list of available topics and can choose any topic they want. Once the user selects a topic, they are presented with a multiple-choice question. The user can select an answer, and the app shows whether the selected answer is correct or not. The user can continue to select other options if they chose an incorrect answer. Once the user selects the correct answer, they can move on to the next question. The app also has a statistics page that shows the number of correctly answered questions.

## 3 key challenges faced during the project
1. Implementing the API calls and handling the responses from the API was challenging, as it required handling asynchronous programming.
2. Creating the layout and design of the app was a significant challenge, as the app needed to be aesthetically pleasing while being functional.
3. Managing state in the app was a challenge, as the state of the app needed to be maintained throughout the app and updated when needed.

## 3 key learning moments from working on the project
1. Understanding and implementing asynchronous programming concepts in Flutter.
2. Understanding and utilizing state management techniques in Flutter, such as using the Provider package.
3. Designing and implementing the user interface of the app.

## list of dependencies and their versions
```yaml
dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.3.2
  flutter_riverpod: ^2.3.2
  go_router: ^6.5.0
  http: ^0.13.5
  shared_preferences: ^2.0.20

dev_dependencies:
  flutter_test:
    sdk: flutter
  nock: ^1.2.1
```
