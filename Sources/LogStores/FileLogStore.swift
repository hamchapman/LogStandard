import Foundation

public class FileLogStore<LogType: Log>: AnyLogStore<LogType> {

    // TODO: This should keep its own cache of logs so that it doesn't
    // have to always fetch to append

    public let filePath: URL

    public init(filePath: URL) {
        self.filePath = filePath
        super.init(self)
    }

    override public func appendLog(_ log: LogType) {
        writeToFile(path: filePath, log: log)
    }

    override public func fetchLogs(cursor: String? = nil, limit: Int? = nil) -> [LogType] {
        let logString = readFromFile(path: filePath)

        // TODO: See if Codable can be used to encode / decode "special" format

        let logLines = logString.split(separator: "\n")
        return logLines.flatMap { logLine in
            guard let logLineData = logLine.data(using: .utf8) else {
                return nil
            }

            return try? JSONDecoder().decode(LogType.self, from: logLineData)
        }
    }

    private func writeToFile(path: URL, log: LogType) {
        guard let encodedLog = try? JSONEncoder().encode(log) else {
            print("Failed to encode log before writing to file. Log: \(log)")
            return
        }

        guard let encodedLogString = String(data: encodedLog, encoding: .utf8) else {
            print("Failed to convert encoded log data to a string before writing to file")
            return
        }

        let textToWrite = "\(encodedLogString)\n"

        if let fileHandle = try? FileHandle(forWritingTo: path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(textToWrite.data(using: .utf8)!)
            print("Appended to file at path \(path)")
        } else {
            do {
                try textToWrite.write(to: path, atomically: true, encoding: .utf8)
                print("Wrote to file at path \(path)")
            } catch let error {
                print("Error writing file at \(path). Error: \(error)")
            }
        }
    }

    private func readFromFile(path: URL) -> String {
        do {
            return try String(contentsOf: path, encoding: .utf8)
        } catch let err {
            print("Error reading logs from path \(path): \(err)")
            return ""
        }
    }
}
