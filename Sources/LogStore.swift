import Foundation

public protocol LogStore {
    associatedtype LogType

    func fetchLogs(cursor: String?, limit: Int?) -> [LogType]
    func appendLog(_ log: LogType)
}

extension LogStore {
    public func fetchLogs(cursor: String? = nil, limit: Int? = nil) -> [LogType] {
        return fetchLogs(cursor: cursor, limit: limit)
    }
}

// MARK: Type erasure of LogStore

private class _AnyLogStoreBase<LogType>: LogStore {
    init() {
        guard type(of: self) != _AnyLogStoreBase.self else {
            fatalError("Cannot initialise, must subclass")
        }
    }

    func fetchLogs(cursor: String?, limit: Int?) -> [LogType] {
        fatalError("Must override")
    }

    func appendLog(_ log: LogType) {
        fatalError("Must override")
    }
}

private final class _AnyLogStoreBox<ConcreteLogStore: LogStore>: _AnyLogStoreBase<ConcreteLogStore.LogType> {
    var concrete: ConcreteLogStore

    init(_ concrete: ConcreteLogStore) {
        self.concrete = concrete
    }

    override func fetchLogs(cursor: String?, limit: Int?) -> [LogType] {
        return concrete.fetchLogs(cursor: cursor, limit: limit)
    }

    override func appendLog(_ log: LogType) {
        concrete.appendLog(log)
    }
}

public class AnyLogStore<LogType>: LogStore {
    private let box: _AnyLogStoreBase<LogType>

    public init<Concrete: LogStore>(_ concrete: Concrete) where Concrete.LogType == LogType {
        box = _AnyLogStoreBox(concrete)
    }

    public func fetchLogs(cursor: String?, limit: Int?) -> [LogType] {
        return box.fetchLogs(cursor: cursor, limit: limit)
    }

    public func appendLog(_ log: LogType) {
        box.appendLog(log)
    }
}
