# crashBug 1.0

`crashBug` is a Swift (UIKit) class designed to detect, log, and notify about app crashes. It provides comprehensive crash reporting and an easy-to-use interface for testing crash scenarios. This can be useful during development to ensure you catch and diagnose crashes efficiently.

## Features

- **Crash Detection:** Automatically detects app crashes and logs details such as the reason, location, and call stack.
- **Crash Logging:** Generates detailed crash logs with human-readable information as well as advanced technical details.
- **Crash Notifications:** Displays a local notification after a crash with a summary of the crash log. Tapping on the notification will show the full log within the app.
- **Test Crashes:** Easily simulate crashes for testing purposes with customizable delay, reason, and log generation options.

## Installation

1. Clone the repository or download the `crashBug.swift` file.
2. Add `crashBug.swift` to your Xcode project.
3. Initialize `crashBug` in your App Delegate or main View Controller.

```swift
// Enable crashBug
crashBug.shared.isEnabled = true
```

## Usage

### Enabling Crash Monitoring

To enable crash monitoring, set `isEnabled` to `true`:

```swift
crashBug.shared.isEnabled = true
```

### Simulating a Crash

Use the `testCrash(after:reason:shouldGenerateLog:)` method to simulate a crash for testing:

```swift
// Simulate a crash after 5 seconds with a custom reason and log generation
crashBug.shared.testCrash(after: 5, reason: "Test crash reason", shouldGenerateLog: true)
```

### Crash Log Example

A typical crash log will look like this:

```
App Crash Log
====================
Human Readable Section
====================
Crash Reason: Test crash reason
Crash Location: __hidden#2762_ (__hidden#2762_:0)
Crash Time: 2024-09-19 12:34:56 +0000
====================
Advanced Information
====================
Call Stack:
0   MyApp                             0x0000000100b0f000 crashBug.handleSignal + 32
1   libsystem_platform.dylib          0x00000001e4f1b000 _sigtramp + 56
...
```

## Handling Crash Notifications

The `crashBug` class will display a local notification 5 seconds after a crash is detected. The notification will include a summary of the crash log. Tapping on the notification will display the full crash log within the app.

### Requesting Notification Permissions

Ensure that your app has permission to display notifications:

```swift
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
    if granted {
        print("Notification permission granted.")
    } else {
        print("Notification permission denied.")
    }
}
```

## Advanced Configuration

You can customize the logging and notification behavior of `crashBug` by modifying the following methods:

- **`createLog(for:)`**: Customize the format and content of the crash log.
- **`displayCrashNotification(with:)`**: Modify the notification appearance and timing.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to submit a pull request or open an issue to suggest improvements or report bugs.

