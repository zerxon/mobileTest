//
//  BookingService.swift
//  mobileTest
//
//  Created by walllceleung on 8/8/2025.
//

import Foundation

#if DEBUG

func debugLog(_ message: Any) {
    if let object = message as? CustomDebugStringConvertible {
        print(object.debugDescription)
    } else if let object = message as? CustomStringConvertible {
        print(object.description)
    } else {
        let mirror = Mirror(reflecting: message)
        var description = "\(type(of: message)):\n"
        for child in mirror.children {
            if let label = child.label {
                description += "  \(label): \(child.value)\n"
            }
        }
        print(description)
    }
}

#else

func debugLog(_ message: Any) {
    // In release mode, do nothing
}

#endif
