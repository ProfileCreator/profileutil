//
//  Enums.swift
//  profileutil
//
//  Created by Erik Berglund on 2019-04-19.
//  Copyright © 2019 Erik Berglund. All rights reserved.
//

import Foundation

public struct State {
    public var scope: Scope = .system
    public var level: Level = .profile
    public var flags: Flags = []
    
    public mutating func setScope(_ scope: Scope) {
        self.scope = scope
        self.level = .profile
        self.flags = []
    }
}

public enum Scope {
    case system
    case user
}

public enum Level {
    case none
    case profile
    case payload
}

public struct Flags: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public let rawValue: Int
    public static let internalData  = Flags(rawValue: 1 << 0)
    public static let cmsInfo       = Flags(rawValue: 1 << 1)
}
