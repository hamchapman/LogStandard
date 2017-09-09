import Foundation

public enum LogLevel: Int, Comparable, Codable {
    case verbose = 1, debug, info, warning, error

    public static func < (a: LogLevel, b: LogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }

    public func stringRepresentation() -> String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}
