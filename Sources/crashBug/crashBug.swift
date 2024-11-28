//
//  CrashBug.swift
//
//  ### dTechInternal File Header Information ###
//
//  UUID:                 A2138B1D-20D2-4B82-8661-B691844E9F92
//  File Name:            CrashBug.swift
//  Production Name:      CrashBug
//  File Creation Date:   9/19/24
//  Modification:         2024:D-Unit
//  Copyright:            TM and © D-Tech Media Creations, Inc. All Rights Reserved.
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
    
    // Singleton instance
     static let shared = CrashBug()
     var latestCrashLog: String?
    
    override init() {
        super.init()
        requestNotificationPermissions()
        if isEnabled {
            startMonitoring()
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





