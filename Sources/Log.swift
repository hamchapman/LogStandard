import Foundation

public protocol Log: Codable {
    init(text: String, logLevel: LogLevel)

    // TODO: short, medium, long, or unix timestamp version
    var date: Date { get }
    var text: String { get }
    var logLevel: LogLevel { get }
}
