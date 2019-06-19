//
//  Utility.swift
//  profileutil
//
//  Created by Erik Berglund on 2019-04-19.
//  Copyright © 2019 Erik Berglund. All rights reserved.
//

import Foundation

extension String {
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}


extension Data {
    
    // Modified version from https://stackoverflow.com/a/26503955
    
    init(withHexString hexString: String) {
        self.init()
        var hex = hexString
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            self.append(&char, count: 1)
        }
    }
}
