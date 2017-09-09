import Foundation

public class UserDefaultsLogStore<LogType: Log>: AnyLogStore<LogType> {

    // TODO: This should keep its own cache of logs so that it doesn't
    // have to always fetch to append

    public let defaults = UserDefaults.standard
    public let identifier: String

    public init(identifier: String) {
        self.identifier = identifier
        super.init(self)
    }

    override public func appendLog(_ log: LogType) {
        var currentLogs = self.fetchLogs()
        currentLogs.append(log)

        let encodedLogs = currentLogs.flatMap { try? PropertyListEncoder().encode($0) }

        defaults.set(encodedLogs, forKey: self.identifier)

        // TODO: Synchronizing after every append is unnecessary
        defaults.synchronize()
    }

    override public func fetchLogs(cursor: String? = nil, limit: Int? = nil) -> [LogType] {
        let dataLogs = self.defaults.value(forKey: self.identifier) as? [Data]
        return dataLogs?.flatMap { try? PropertyListDecoder().decode(LogType.self, from: $0) } ?? [LogType]()
    }
}
