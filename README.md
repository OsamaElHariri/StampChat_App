<p align="center">
  <img src="assets/app/logo.png" alt="stampchat" width="64" />
</p>


# StampChat Mobile App

A mobile chat app! Users can create a chat room and invite others to the chat room using dynamic links. Users can chat normally, and they can stamp their words anywhere on the chat screen

# What For?

This is a side-project. It's also a complete app, backed by servers using a basic microservices pattern, and it's on the Play Store. The main purpose of this project is to go through all the technical steps needed to launch an app.

# Video Walkthrough

<p align="center">
  <img src="app_media/docs_media/preview.gif" alt="stampchat" width="50%" />
</p>

# Running the App

The app is built using the Flutter mobile framework. It uses Firebase services like authentication and dynamic links.

---
The steps needed to run the app are:

1. Download and install [Flutter](https://flutter.dev/docs/get-started/install)
2. Get the dependencies by running
  ```sh
    flutter pub get
  ```
3. Add Firebase to your app by following the [Add Firebase to your Android project](https://firebase.google.com/docs/android/setup) guide. When complete, you should have a file called called `google-services.json`. The path of this file is: `android/app/google-services.json`
4. To test this app on your local machine, get your *internal IP and replace the `baseUrl` variable in `Api.dart` with your IP
```dart
static var baseUrl = "YOUR.INTERNAL.IP.HERE:8080";
```
5. Run the app using
```sh
flutter run
```

\* On linux, I get my internal IP using the `hostname -I` command

---

Running this app on it's own is not very useful as it will not work without the back-end servers that it needs. To run the backend servers, take a look at the [StampChat infrastructure repo](https://github.com/OsamaElHariri/StampChat_Kubernetes).