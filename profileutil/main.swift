//
//  main.swift
//  profileutil
//
//  Created by Erik Berglund on 2019-04-19.
//  Copyright © 2019 Erik Berglund. All rights reserved.
//

import Foundation

var outputFiltered = false
var outputDicts: [[String: Any]]?

var arraySystem = [[String: Any]]()
var arrayUser = [[String: Any]]()
var arrayUnknown = [[String: Any]]()

// Parse all command line arguments to a dict
let arguments = CommandLine.parse()

func printUsage() {
    let usage = """
                \n\t# Filter
                \t  Use either key/value OR signed

                \t--key\t\tstring\tPayload key to match. (Requires --value)
                \t--value\t\tstring\tValue to match for Payload Key. (Requires --key)
                \t--signed\tstring\t(true|false) Only return profiles with selected signing status. (Default true)

                \t# Output

                \t--output\tstring\t(xml|identifier|uuid) The output format. (Default xml)
                \t--first\t\t-\tReturns only the first matched profile.
                \n
                """
    FileHandle.standardOutput.write(usage.data(using: .utf8)!)
}

if !Set(["-h", "--h", "-help", "--help"]).isDisjoint(with: Set(arguments.keys)) {
    printUsage()
    exit(0)
}

func run() {
    do {
        if let keyString = arguments["--key"], let value = arguments["--value"], let key = Key(rawValue: keyString) {
            outputFiltered = true
            if arguments.keys.contains("--first") {
                if let outputDict = try MDMClient.profile(withValue: valueForKey(key, value: value), forKey: key, level: .none) {
                    outputDicts = [outputDict]
                }
            } else {
                outputDicts = try MDMClient.profiles(withValue: valueForKey(key, value: value), forKey: key, level: .none)
            }
        } else if let isSignedString = arguments["--signed"], let isSigned = valueForKey(.isSignerCert, value: isSignedString.isEmpty ? "1" : isSignedString) as? Bool {
            outputFiltered = true
            outputDicts = try MDMClient.profiles(withValue: true, forKey: .isSignerCert, level: .none, invert: !isSigned)
        } else {
            let outputDict = try MDMClient.installedProfiles()
            if !outputDict.isEmpty {
                outputDicts = [outputDict]
            }
        }
        
        // Verify something was returned
        guard let output = outputDicts, !output.isEmpty else {
            return
        }
        
        for dict in output {
            if let outputFormat = arguments["--output"] {
                switch outputFormat {
                case "xml":
                    if outputFiltered {
                        addXMLToArray(dict)
                    }
                    guard output.count != 1 else {
                        if outputFiltered {
                            try printXMLArrays()
                        } else {
                            try printXML(dict)
                        }
                        exit(0)
                    }
                case "identifier":
                    printIdentifier(dict)
                case "uuid":
                    printUUID(dict)
                default:
                    if let errorData = "Unknown Output Format: \(outputFormat)\n".data(using: .utf8) {
                        FileHandle.standardError.write(errorData)
                    }
                    exit(0)
                }
            } else {
                if outputFiltered {
                    addXMLToArray(dict)
                }
                guard output.count != 1 else {
                    if outputFiltered {
                        try printXMLArrays()
                    } else {
                        try printXML(dict)
                    }
                    exit(0)
                }
            }
        }
        
        try printXMLArrays()
    } catch {
        Swift.print(error)
    }
}

func addXMLToArray(_ dict: [String: Any]) {
    if let scope = (dict["InternalData"] as? [String: Any])?["PayloadScope"] as? String {
        if scope == "System" {
            arraySystem.append(dict)
        } else if scope == "User" {
            arrayUser.append(dict)
        } else {
            arrayUnknown.append(dict)
        }
    } else {
        arrayUnknown.append(dict)
    }
}

func printXML(_ dict: [String: Any]) throws {
    let outputData = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
    FileHandle.standardOutput.write(outputData)
}

func printXMLArrays() throws {
    var outputDict = [String: [[String: Any]]]()
    
    if !arraySystem.isEmpty { outputDict["System"] = arraySystem }
    if !arrayUser.isEmpty { outputDict["User"] = arrayUser }
    if !arrayUnknown.isEmpty { outputDict["Unknown"] = arrayUnknown }
    
    if !outputDict.isEmpty {
        try printXML(outputDict)
    }
}

func printIdentifier(_ dict: [String: Any]) {
    var outputData: Data
    if let identifier = (dict as NSDictionary).value(forKey: Key.identifier.rawValue) as? String, let identifierData = (identifier + "\n").data(using: .utf8) {
        outputData = identifierData
    } else {
        outputData = "-\n".data(using: .utf8)!
    }
    FileHandle.standardOutput.write(outputData)
}

func printUUID(_ dict: [String: Any]) {
    var outputData: Data
    if let uuid = (dict as NSDictionary).value(forKey: Key.uuid.rawValue) as? String, let uuidData = (uuid + "\n").data(using: .utf8) {
        outputData = uuidData
    } else {
        outputData = "-\n".data(using: .utf8)!
    }
    FileHandle.standardOutput.write(outputData)
}

run()
