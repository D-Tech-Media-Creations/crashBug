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
     let blurFrame = CGRect(x: 463, y: 316, width: 450, height: 400)

     let blurView: UIVisualEffectView! = .init(effect: UIBlurEffect(style: .systemMaterialDark))
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
             NSLog("Presenting crashBug Welcome Message in 10 seconds")
             presentWelcomeMessage()
         } else if isEnabled {
             startMonitoring()
         }
     }
     
     private func createButton(title: String, frame: CGRect, backgroundColor: UIColor) -> UIButton {
         let button = UIButton(type: .system)
         button.frame = frame
         button.setTitle(title, for: .normal)
         button.backgroundColor = backgroundColor
         button.setTitleColor(.black, for: .normal)
         button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
         button.layer.cornerRadius = 8
         return button
     }
     
      func presentWelcomeMessage() {

          DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [self] in
             guard let window = UIApplication.shared.windows.first else { return }

             // Set fixed frame for the blur view

             // Create the blurred background view

             blurView.frame = blurFrame
             blurView.layer.cornerRadius = 12
             blurView.clipsToBounds = true
             window.addSubview(blurView)

             // Title Label
             let titleLabel = UILabel()
             titleLabel.frame = CGRect(x: 20, y: 20, width: blurFrame.width - 40, height: 60)
             titleLabel.text = "Welcome to crashBug!"
             titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
             titleLabel.textAlignment = .center
             titleLabel.textColor = .white
             titleLabel.numberOfLines = 0
             blurView.contentView.addSubview(titleLabel)

             // Message Label
             let messageLabel = UILabel()
             messageLabel.frame = CGRect(x: 20, y: 90, width: blurFrame.width - 40, height: 80)
             messageLabel.text = "Would you like to start crashBug the crash monitoring system?"
             messageLabel.font = UIFont.systemFont(ofSize: 16)
             messageLabel.textAlignment = .center
             messageLabel.textColor = .white
             messageLabel.numberOfLines = 0
             blurView.contentView.addSubview(messageLabel)

             // Buttons
             let buttonWidth: CGFloat = 150
             let buttonHeight: CGFloat = 44
             let buttonSpacing: CGFloat = 10

             let yesButton = self.createButton(
                 title: "Yes",
                 frame: CGRect(
                     x: (blurFrame.width - buttonWidth) / 2,
                     y: blurFrame.height - buttonHeight * 3 - buttonSpacing * 2 - 20,
                     width: buttonWidth,
                     height: buttonHeight
                 ),
                 backgroundColor: .systemGreen
             )
             yesButton.addTarget(self, action: #selector(self.enableMonitoring), for: .touchUpInside)
             blurView.contentView.addSubview(yesButton)

             let noButton = self.createButton(
                 title: "No",
                 frame: CGRect(
                     x: (blurFrame.width - buttonWidth) / 2,
                     y: blurFrame.height - buttonHeight * 2 - buttonSpacing - 20,
                     width: buttonWidth,
                     height: buttonHeight
                 ),
                 backgroundColor: .systemYellow
             )
             noButton.addTarget(self, action: #selector(self.disableMonitoring), for: .touchUpInside)
             blurView.contentView.addSubview(noButton)

             let noShowAgainButton = self.createButton(
                 title: "Don't Show Again",
                 frame: CGRect(
                     x: (blurFrame.width - buttonWidth) / 2,
                     y: blurFrame.height - buttonHeight - 20,
                     width: buttonWidth,
                     height: buttonHeight
                 ),
                 backgroundColor: .systemRed
             )
             noShowAgainButton.addTarget(self, action: #selector(self.disableMonitoringPermanently), for: .touchUpInside)
             blurView.contentView.addSubview(noShowAgainButton)
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
         NSLog(#function)
          let window = UIApplication.shared.windows.first
         
         // Find the blur view by its tag
         if let blurView = window?.viewWithTag(0) {
             UIView.animate(withDuration: 0.3, animations: {
                 blurView.alpha = 0
          
             }) { _ in
                 window?.removeFromSuperview()
                 blurView.removeFromSuperview()
                 resetViewControllers()
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
            rootVC.modalPresentationStyle = .overFullScreen
            rootVC.modalTransitionStyle = .coverVertical
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}














func resetViewControllers() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
        print("No active window scene found")
        return
    }

    // Dismiss all presented view controllers recursively
    func dismissRecursively(_ viewController: UIViewController, completion: @escaping () -> Void) {
        if let presentedVC = viewController.presentedViewController {
            presentedVC.dismiss(animated: true) {
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
                viewController.view = nil
                dTechTimer(time: 0.5) { (true) in
                    dismissRecursively(viewController, completion: completion)
                }
            }
        } else {
            completion()
        }
    }

    if let rootVC = window.rootViewController {
        dismissRecursively(rootVC) {
            // After dismissing all presented view controllers, reset to the initial view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                // Reset the root view controller
                window.rootViewController = initialViewController
                window.makeKeyAndVisible()

                // Add a transition animation for a smoother reset effect
                let transition = CATransition()
                transition.type = .fade
                transition.duration = 0.3
                window.layer.add(transition, forKey: kCATransition)
            } else {
                print("Unable to instantiate the initial view controller")
            }
        }
    }
}


func dTechTimer(time: Double, completion: @escaping (Bool) -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
        completion(true)
    })
    
}
