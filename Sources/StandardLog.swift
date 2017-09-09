import Foundation

public struct StandardLog: Log {
    public let date: Date
    public let text: String
    public let logLevel: LogLevel

    public init(date: Date, text: String, logLevel: LogLevel = .info) {
        self.text = text
        self.date = date
        self.logLevel = logLevel
    }

    public init(text: String, logLevel: LogLevel = .info) {
        self.init(date: Date(), text: text, logLevel: logLevel)
    }
}
