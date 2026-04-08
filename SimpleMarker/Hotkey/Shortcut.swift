import AppKit
import Carbon.HIToolbox

struct Shortcut: Codable, Equatable {
    static let defaultValue = Shortcut(keyCode: UInt16(kVK_ANSI_A), modifiers: [.command, .option])
    private static let storageKey = "simpleMarker.shortcut"
    private static let supportedModifiers: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
    private static let modifierOnlyKeyCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]

    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags

    init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers.intersection(Self.supportedModifiers)
    }

    enum CodingKeys: String, CodingKey {
        case keyCode
        case modifierFlags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyCode = try container.decode(UInt16.self, forKey: .keyCode)
        let modifierFlags = try container.decode(UInt.self, forKey: .modifierFlags)
        self.init(keyCode: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: modifierFlags))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyCode, forKey: .keyCode)
        try container.encode(modifiers.rawValue, forKey: .modifierFlags)
    }

    static func load() -> Shortcut {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let shortcut = try? JSONDecoder().decode(Shortcut.self, from: data)
        else {
            return defaultValue
        }

        return shortcut
    }

    static func save(_ shortcut: Shortcut) {
        guard let data = try? JSONEncoder().encode(shortcut) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func capture(from event: NSEvent) -> Shortcut? {
        let modifiers = event.modifierFlags.intersection(supportedModifiers)
        guard !modifiers.isEmpty else {
            return nil
        }

        guard !modifierOnlyKeyCodes.contains(event.keyCode) else {
            return nil
        }

        return Shortcut(keyCode: event.keyCode, modifiers: modifiers)
    }

    var carbonModifiers: UInt32 {
        var flags: UInt32 = 0

        if modifiers.contains(.command) {
            flags |= UInt32(cmdKey)
        }
        if modifiers.contains(.option) {
            flags |= UInt32(optionKey)
        }
        if modifiers.contains(.control) {
            flags |= UInt32(controlKey)
        }
        if modifiers.contains(.shift) {
            flags |= UInt32(shiftKey)
        }

        return flags
    }

    var displayString: String {
        modifierSymbols + keyString
    }

    private var modifierSymbols: String {
        var result = ""

        if modifiers.contains(.control) {
            result += "⌃"
        }
        if modifiers.contains(.option) {
            result += "⌥"
        }
        if modifiers.contains(.shift) {
            result += "⇧"
        }
        if modifiers.contains(.command) {
            result += "⌘"
        }

        return result
    }

    private var keyString: String {
        switch keyCode {
        case UInt16(kVK_ANSI_A): return "A"
        case UInt16(kVK_ANSI_B): return "B"
        case UInt16(kVK_ANSI_C): return "C"
        case UInt16(kVK_ANSI_D): return "D"
        case UInt16(kVK_ANSI_E): return "E"
        case UInt16(kVK_ANSI_F): return "F"
        case UInt16(kVK_ANSI_G): return "G"
        case UInt16(kVK_ANSI_H): return "H"
        case UInt16(kVK_ANSI_I): return "I"
        case UInt16(kVK_ANSI_J): return "J"
        case UInt16(kVK_ANSI_K): return "K"
        case UInt16(kVK_ANSI_L): return "L"
        case UInt16(kVK_ANSI_M): return "M"
        case UInt16(kVK_ANSI_N): return "N"
        case UInt16(kVK_ANSI_O): return "O"
        case UInt16(kVK_ANSI_P): return "P"
        case UInt16(kVK_ANSI_Q): return "Q"
        case UInt16(kVK_ANSI_R): return "R"
        case UInt16(kVK_ANSI_S): return "S"
        case UInt16(kVK_ANSI_T): return "T"
        case UInt16(kVK_ANSI_U): return "U"
        case UInt16(kVK_ANSI_V): return "V"
        case UInt16(kVK_ANSI_W): return "W"
        case UInt16(kVK_ANSI_X): return "X"
        case UInt16(kVK_ANSI_Y): return "Y"
        case UInt16(kVK_ANSI_Z): return "Z"
        case UInt16(kVK_ANSI_0): return "0"
        case UInt16(kVK_ANSI_1): return "1"
        case UInt16(kVK_ANSI_2): return "2"
        case UInt16(kVK_ANSI_3): return "3"
        case UInt16(kVK_ANSI_4): return "4"
        case UInt16(kVK_ANSI_5): return "5"
        case UInt16(kVK_ANSI_6): return "6"
        case UInt16(kVK_ANSI_7): return "7"
        case UInt16(kVK_ANSI_8): return "8"
        case UInt16(kVK_ANSI_9): return "9"
        case UInt16(kVK_Space): return "Space"
        case UInt16(kVK_Return): return "↩"
        case UInt16(kVK_Escape): return "Esc"
        case UInt16(kVK_Delete): return "⌫"
        case UInt16(kVK_ForwardDelete): return "⌦"
        case UInt16(kVK_Tab): return "⇥"
        case UInt16(kVK_LeftArrow): return "←"
        case UInt16(kVK_RightArrow): return "→"
        case UInt16(kVK_UpArrow): return "↑"
        case UInt16(kVK_DownArrow): return "↓"
        default: return "KeyCode \(keyCode)"
        }
    }
}
