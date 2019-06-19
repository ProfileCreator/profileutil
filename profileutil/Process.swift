//
//  Process.swift
//  profileutil
//
//  Created by Erik Berglund on 2019-04-19.
//  Copyright © 2019 Erik Berglund. All rights reserved.
//

import Foundation

public func runCommand(path: String, arguments: [String]?) throws -> Data {
    let task = Process()
    let stdOutPipe = Pipe()
    
    task.launchPath = path
    task.arguments = arguments
    task.standardOutput = stdOutPipe
    
    try task.run()
    return stdOutPipe.fileHandleForReading.readDataToEndOfFile()
}
