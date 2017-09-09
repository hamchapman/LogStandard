import Foundation

public struct LoggerOptions {
    public var printToConsole: Bool

    public init(printToConsole: Bool = true) {
        self.printToConsole = printToConsole
    }
}
