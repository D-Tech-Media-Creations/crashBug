//
//  CrashBug.swift
//
//  ### dTechInternal File Header Information ###
//
//  UUID:                             A2138B1D-20D2-4B82-8661-B691844E9F92
//  File Name:                     CrashBug.swift
//  Production Name:         CrashBug
//  File Creation Date:        9/19/24
//  Modification:                 2024-11-28.dSwan(2378)
//  Copyright:                     TM and © D-Tech Media Creations, Inc. All Rights Reserved.
//
//  ### dTechInternal File Header Information ###
//

import UIKit
import UserNotifications


@available(iOS 13.0, *)
@MainActor
 public class CrashBug: NSObject {
    // Property to check if CrashBug is enabled
     var isEnabled: Bool {
         get {
             UserDefaults.standard.bool(forKey: "crashBugEnabled")
         }
         set {
             UserDefaults.standard.set(newValue, forKey: "crashBugEnabled")
         }
     }

     private var hasShownWelcomeMessage: Bool {
         get {
             UserDefaults.standard.bool(forKey: "hasShownCrashBugWelcome")
         }
         set {
             UserDefaults.standard.set(newValue, forKey: "hasShownCrashBugWelcome")
         }
     }
    
    // Singleton instance
     public static let shared = CrashBug()
     var latestCrashLog: String?
    
     override init() {
         super.init()
         requestNotificationPermissions()
         if !hasShownWelcomeMessage {
             NSLog("Presenting crashBug Welcome Message in 5 seconds")
             presentWelcomeMessage()
         } else if isEnabled {
             startMonitoring()
         }
     }
     
     private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
         let button = UIButton(type: .system)
         button.setTitle(title, for: .normal)
         button.backgroundColor = backgroundColor
         button.tintColor = .white // Text color
         button.layer.cornerRadius = 8
         button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
         return button
     }
     
      func presentWelcomeMessage() {

         DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
             guard let window = UIApplication.shared.windows.first else { return }

             // Container for the blurred view and content
             let containerView = UIView()
             containerView.translatesAutoresizingMaskIntoConstraints = false
             containerView.backgroundColor = .clear // Make background transparent
             containerView.layer.cornerRadius = 12
             containerView.layer.masksToBounds = true
             window.addSubview(containerView)

             // Create a blurred background view inside the container
             let blurEffect = UIBlurEffect(style: .systemMaterialDark)
             let blurView = UIVisualEffectView(effect: blurEffect)
             blurView.translatesAutoresizingMaskIntoConstraints = false
             containerView.addSubview(blurView)

             // Title Label
             let titleLabel = UILabel()
             titleLabel.text = "Welcome to crashBug™ Crash Detection & Error Reporting System"
             titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
             titleLabel.textAlignment = .center
             titleLabel.textColor = .white
             titleLabel.numberOfLines = 0
             titleLabel.translatesAutoresizingMaskIntoConstraints = false
             containerView.addSubview(titleLabel)

             // Message Label
             let messageLabel = UILabel()
             messageLabel.text = "Hello! I see this is your first time running crashBug. Would you like to start enabling the monitoring system?"
             messageLabel.font = UIFont.systemFont(ofSize: 16)
             messageLabel.textAlignment = .center
             messageLabel.textColor = .white
             messageLabel.numberOfLines = 0
             messageLabel.translatesAutoresizingMaskIntoConstraints = false
             containerView.addSubview(messageLabel)

             // Styled Buttons
             let yesButton = self.createButton(title: "Yes", backgroundColor: .systemGreen)
             yesButton.addTarget(self, action: #selector(self.enableMonitoring), for: .touchUpInside)
             containerView.addSubview(yesButton)

             let noButton = self.createButton(title: "No", backgroundColor: .systemYellow)
             noButton.addTarget(self, action: #selector(self.disableMonitoring), for: .touchUpInside)
             containerView.addSubview(noButton)

             let noShowAgainButton = self.createButton(title: "No, Don't Show Again", backgroundColor: .systemRed)
             noShowAgainButton.addTarget(self, action: #selector(self.disableMonitoringPermanently), for: .touchUpInside)
             containerView.addSubview(noShowAgainButton)

             // Add constraints
             NSLayoutConstraint.activate([
                 containerView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                 containerView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                 containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 350),

                 blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
                 blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                 blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                 blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

                 titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
                 titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                 titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

                 messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                 messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                 messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

                 yesButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
                 yesButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                 yesButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                 yesButton.heightAnchor.constraint(equalToConstant: 44),

                 noButton.topAnchor.constraint(equalTo: yesButton.bottomAnchor, constant: 10),
                 noButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                 noButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                 noButton.heightAnchor.constraint(equalToConstant: 44),

                 noShowAgainButton.topAnchor.constraint(equalTo: noButton.bottomAnchor, constant: 10),
                 noShowAgainButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                 noShowAgainButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                 noShowAgainButton.heightAnchor.constraint(equalToConstant: 44),
                 noShowAgainButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
             ])
         }
     }
     
     @objc private func enableMonitoring() {
         isEnabled = true
         hasShownWelcomeMessage = true
         startMonitoring()
         removeWelcomeMessage()
     }

     @objc private func disableMonitoring() {
         isEnabled = false
         hasShownWelcomeMessage = true
         removeWelcomeMessage()
     }

     @objc private func disableMonitoringPermanently() {
         isEnabled = false
         hasShownWelcomeMessage = true
         UserDefaults.standard.set(true, forKey: "crashBugDoNotShowWelcomeAgain")
         removeWelcomeMessage()
     }
     
     private func removeWelcomeMessage() {
         guard let window = UIApplication.shared.windows.first else { return }
         
         // Find the blur view by its tag
         if let blurView = window.viewWithTag(999) {
             UIView.animate(withDuration: 0.3, animations: {
                 blurView.alpha = 0
             }) { _ in
                 blurView.removeFromSuperview()
             }
         }
     }
    
    // Start monitoring for app crashes
    public func startMonitoring() {
        NSSetUncaughtExceptionHandler { exception in
            CrashBug.handleException(exception: exception)
        }
        CrashBug.setupSignalHandler()
    }
    
    // Set up signal handlers for common signals
     static public func setupSignalHandler() {
        signal(SIGABRT, crashSignalHandler)
        signal(SIGILL, crashSignalHandler)
        signal(SIGSEGV, crashSignalHandler)
        signal(SIGFPE, crashSignalHandler)
        signal(SIGBUS, crashSignalHandler)
        signal(SIGPIPE, crashSignalHandler)
    }
    
    // C-compatible signal handler
     static let crashSignalHandler: @convention(c) (Int32) -> Void = { signal in
        CrashBug.handleSignal(signal)
    }
    
    // Handle uncaught exceptions
     static public func handleException(exception: NSException) {
        let crashLog = CrashBug.shared.createLog(for: exception)
        CrashBug.shared.saveCrashLog(crashLog)
        CrashBug.shared.displayCrashNotification(with: crashLog)
    }
    
    // Handle signal-based crashes
     static public func handleSignal(_ signal: Int32) {
        var crashInfo = "App received signal: \(signal)\n"
        crashInfo += "Call stack:\n"
        crashInfo += Thread.callStackSymbols.joined(separator: "\n")
        CrashBug.shared.saveCrashLog(crashInfo)
        CrashBug.shared.displayCrashNotification(with: crashInfo)
    }
    
    // Create a log for the given exception
     public func createLog(for exception: NSException) -> String {
        var log = "App Crash Log\n"
        log += "====================\n"
        log += "Human Readable Section\n"
        log += "====================\n"
        log += "Crash Reason: \(exception.reason ?? "Unknown")\n"
        log += "Crash Location: \(exception.callStackSymbols.first ?? "Unknown")\n"
        log += "Crash Time: \(Date())\n"
        log += "====================\n"
        log += "Advanced Information\n"
        log += "====================\n"
        log += "Call Stack:\n"
        log += exception.callStackSymbols.joined(separator: "\n")
        return log
    }
    
    // Save the crash log to a file
     public func saveCrashLog(_ log: String) {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let logFilePath = documentsPath.appendingPathComponent("CrashLog_\(Date()).txt")
        do {
            try log.write(to: logFilePath, atomically: true, encoding: .utf8)
            print("Crash log saved at: \(logFilePath)")
            latestCrashLog = log
        } catch {
            print("Failed to save crash log: \(error)")
        }
    }
    
    // Request notification permissions
     public func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // Display crash notification with summary
     public func displayCrashNotification(with log: String) {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "The App"
        let logSummary = log.split(separator: "\n").prefix(5).joined(separator: "\n")
        
        let content = UNMutableNotificationContent()
        content.title = "\(appName) has crashed"
        content.body = "Summary:\n\(logSummary)"
        content.sound = .default
        content.userInfo = ["crashLog": log]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "crashBugNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to display notification: \(error)")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Test crash public function
    public func testCrash(after duration: TimeInterval, reason: String, shouldGenerateLog: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if shouldGenerateLog {
                let exception = NSException(name: .genericException, reason: reason, userInfo: nil)
                CrashBug.handleException(exception: exception)
            }
            fatalError(reason)
        }
    }
}

// Extend CrashBug to conform to UNUserNotificationCenterDelegate
@available(iOS 13.0, *)
extension CrashBug: UNUserNotificationCenterDelegate {

    
    // Display the log file within the app
     public func displayCrashLog(_ log: String) {
        let alert = UIAlertController(title: "Crash Log", message: log, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}











