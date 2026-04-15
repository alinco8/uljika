import Foundation

func readMessage() -> [String: Any]? {
    let lenData = FileHandle.standardInput.readData(ofLength: 4)
    guard lenData.count == 4 else { return nil }

    let length = lenData.withUnsafeBytes {
        $0.load(as: UInt32.self).littleEndian
    }
    guard length > 0 else { return nil }

    let msgData = FileHandle.standardInput.readData(ofLength: Int(length))
    return try? JSONSerialization.jsonObject(with: msgData) as? [String: Any]
}

func sendMessage(_ dict: [String: Any]) {
    guard let data = try? JSONSerialization.data(withJSONObject: dict) else {
        return
    }
    var length = UInt32(data.count).littleEndian
    let lenData = Data(bytes: &length, count: 4)

    FileHandle.standardOutput.write(lenData)
    FileHandle.standardOutput.write(data)
}

while true {
    guard let msg = readMessage() else { break }

    let action = msg["type"] as? String
    switch action {
    case "ping":
        sendMessage(["type": "pong"])

    case "retrieve_latest_version":
        let defaults = UserDefaults(suiteName: "dev.alinco8.uljika")
        let latestVersion = defaults?.string(forKey: "latestVersion")
        
        sendMessage([
            "type": "latest_version",
            "payload": [
                "latest_version": latestVersion
            ]
        ])

    default:
        sendMessage([
            "type": "error",
            "message": "unknown action: \(action ?? "<nil>")",
        ])
    }
}
