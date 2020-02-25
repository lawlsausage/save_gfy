# save_gfy

A Flutter app to save Gfycat and Reddit videos locally. The original idea was to be able to download the non-mobile version of Gfycat videos in a simpler workflow. Later Reddit videos were added since saving videos hosted on the v.redd.it URL seemed very convoluted.

The project is evolving and being changed dependent on pretty much fulfilling various annoyances with mobile sites or apps with missing or obstructive features.

In a way, it would have been simpler to register and use the API given by Gfycat and/or Reddit. The decision was to go the more difficult route to have an opportunity to explore Flutter's native platform views out of personal interest.

> This project is wildly in the "just get something working" state, but I like to refactor as I go along.

## Current App Platform Support

| OS | Support |
| --- | --- |
| Android | ✓ |
| iOS | - |
| Web | - |
| Desktop | - |

This app is a hybrid app requiring a use of a native web view to load web pages. So far only Android implementation of the WebView platform view is available and in working condition. Although it may have been easier to get the video URLs directly through APIs, playing with platform views seemed fun.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

### Run the app

Open a command line terminal.

Change the directory to the project directory.

Enter `flutter run -t lib/main_dev.dart --flavor dev`.

#### Using the app

##### Android

The save_gfy app will respond to URL links with the following hosts tapped on Android:

* gfycat
* v.redd.it

You may also share URLs with the following hosts through the Android Share Dialog from another app:

* gfycat
* reddit
* v.redd.it

##### iOS

TBD

### Debugging in Visual Studio Code

If you are using Visual Studio Code, the following is an example `.vscode/launch.json` file.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter - Dev",
            "request": "launch",
            "type": "dart",
            "program": "lib/main_dev.dart",
            "args": [
                "--flavor",
                "dev"
            ]
        },
        {
            "name": "Flutter - Prod",
            "request": "launch",
            "type": "dart",
            "program": "lib/main_prod.dart",
            "args": [
                "--flavor",
                "prod"
            ]
        }
    ]
}
```

## App Configuration

App configuration is contained in the `dev.json` and `prod.json` files located in the `assets/config` directory.

To run the app with a certain configuration, target the corresponding `main_[dev|prod].dart` file by running the `flutter run -t lib/main_[dev|prod].dart --flavor [dev|prod]` command.

If a custom development configuration is preferred, simply create a `dev-local.json` file. Properties in `dev.json` will be overwritten by any property that matches in `dev-local.json`.

### App Flavors

The app has two flavors `dev` and `prod`.

#### Android

The app flavors are defined in the `android/app/build.gradle` file. The flavor allows for [merged AndroidManifest.xml files](https://developer.android.com/studio/build/manifest-merge) from the `android/app/src/main` and `android/app/src/devDebug` directories.

By default, the `android/app/src/devDebug` directory does not have an AndroidManifest.xml file. This is on purpose for independent local development configuration of additional `intent-filters` specifically for URL data matching.

#### iOS

TBD

## Future Plans

The following are some things I would personally like to do to make the app either better, out of curiosity, or to solve some problem:

* Add additional sources. 
* Adopt the BLoC pattern to separate business logic from visual.
* Chip away at the larger Widgets to break them into smaller and focused Widgets. 
* Some of the Widgets may be reorganized between pages and components.
* Adding test coverage to become acquainted with how unit tests works in Flutter.
* Add web (PWA) and future desktop support because Flutter is adding more than just mobile app platform support.
* Refactor code to better fit the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

> There is no particular order to when I will be taking these plans on. Keep in mind that this is a one-man side project.

There may be obvious issues which may be revealed with further development and usage.