import Foundation
import UIKit

public typealias StandardLogger = GenericLogger<StandardLog>

public class GenericLogger<LogType: Log> {
    public var options: LoggerOptions

    private lazy var gestureRecognizer: UIGestureRecognizer = {
        if let gesture = self.providedGestureRecognizer {
            return gesture
        } else {
            let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(gesturePerformed))
            gestureRecognizer.numberOfTouchesRequired = 3
            gestureRecognizer.direction = .up

            return gestureRecognizer
        }
    }()

    public let providedGestureRecognizer: UIGestureRecognizer?

    public var logs: [LogType] = []
    public var gestureRecognizerToViewControllerMap: [UIGestureRecognizer: UIViewController] = [:]
    public lazy var logsViewController = LogsViewController<LogType>(logger: self)

    public let store: AnyLogStore<LogType>

    public init(store: AnyLogStore<LogType>, options: LoggerOptions = LoggerOptions(), gestureRecognizer: UIGestureRecognizer? = nil) {
        self.store = store
        self.options = options
        self.providedGestureRecognizer = gestureRecognizer
        self.logs = store.fetchLogs()
    }

    public func addLogViewGesture(_ vc: UIViewController) {
        gestureRecognizerToViewControllerMap[self.gestureRecognizer] = vc
        vc.view.addGestureRecognizer(self.gestureRecognizer)
    }

    @objc public func gesturePerformed(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .recognized {
            if let vc = gestureRecognizerToViewControllerMap[recognizer] {
                presentLogsInViewController(vc)
            } else {
                print("Did not find registered gesture recognizer")
            }
        }
    }

    public func presentLogsInViewController(_ vc: UIViewController) {
        let navController = UINavigationController(rootViewController: logsViewController)
        vc.present(navController, animated: true)
    }

    // TODO: better log
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: LogLevel) {
        //        let log = LogType(text: message(), logLevel: HCLogLevel)
    }

    // TODO: Option to log by passing in LogType directly rather than string message

    public func addToLogs(text: String) {
        // TODO: Fixme - pass in logLevel
        let log = LogType(text: text, logLevel: .info)

        if options.printToConsole {
            print("[HCLogger]: \(log)")
        }

        self.store.appendLog(log)
        // TODO: Use a success / failure callback here?
        self.logs.append(log)
        logsViewController.logsTableView.reloadData()
    }

    // TODO: Probably need something like this
    public func addToLogs(log: LogType) {
        //        debugPrint("DEBUG PRINT HC LOG: \(log.debugDescription)")
        self.store.appendLog(log)
        // TODO: Use a success / failure callback here?
        self.logs.append(log)
        logsViewController.logsTableView.reloadData()
    }

    public func fetchLogs() -> [LogType] {
        return self.store.fetchLogs()
    }
}
