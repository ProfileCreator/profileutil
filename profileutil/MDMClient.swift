//
//  MDMClient.swift
//  profileutil
//
//  Created by Erik Berglund on 2019-04-19.
//  Copyright © 2019 Erik Berglund. All rights reserved.
//

import Foundation

public class MDMClient {
    
    // MARK: -
    // MARK: Generic Convenience Functions - Single Profile
    
    private class func profile<T: Equatable>(withValue value: Any, ofType type: T.Type, forKey key: Key, invert: Bool) throws -> [String: Any]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.first(where: {
            $0.value.contains(where: {
                (invert) ? $0[key.rawValue] as? T != value as? T : $0[key.rawValue] as? T == value as? T
            })
        })?.value.first
    }
    
    private class func profile<T: Equatable>(withValue value: Any, ofType type: T.Type, forPayloadKey key: Key, invert: Bool) throws -> [String: Any]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.first(where: {
            $0.value.contains(where: {
                ($0[Key.payloads.rawValue] as? [[String: Any]])?.contains(where: {
                    (invert) ? $0[key.rawValue] as? T != value as? T : $0[key.rawValue] as? T == value as? T
                }) ?? (invert) ? true : false
            })
        })?.value.first
    }
    
    private class func profile<T: Equatable>(withValue value: Any, ofType type: T.Type, forInternalDataKey key: Key, invert: Bool) throws -> [String: Any]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.first(where: {
            $0.value.contains(where: {
                let internalData = ($0[Key.internalData.rawValue] as? [String: Any])
                return (invert) ? internalData?[key.rawValue] as? T != value as? T : internalData?[key.rawValue] as? T == value as? T
            })
        })?.value.first
    }
    
    private class func profile<T: Equatable>(withValue value: Any, ofType type: T.Type, forCMSCertificateKey key: Key, invert: Bool) throws -> [String: Any]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.first(where: {
            $0.value.contains(where: {
                (($0[Key.internalData.rawValue] as? [String: Any])?[Key.cmsCertificatesInfo.rawValue] as? [[String: Any]])?.contains(where: {
                    (invert) ? $0[key.rawValue] as? T != value as? T : $0[key.rawValue] as? T == value as? T
                }) ?? (invert) ? true : false
            })
        })?.value.first
    }
    
    // MARK: -
    // MARK: Convenience Functions - Single Profile
    
    private class func profile<T: Equatable>(withValue value: Any, ofType type: T.Type, forKey key: Key, level: Level, flags: Flags = [], invert: Bool) throws -> [String: Any]? {
        if flags.contains(.cmsInfo) {
            return try self.profile(withValue: value, ofType: type, forCMSCertificateKey: key, invert: invert)
        } else if flags.contains(.internalData) {
            return try self.profile(withValue: value, ofType: type, forInternalDataKey: key, invert: invert)
        }
        switch level {
        case .none:
            return try self.profile(withValue: value, ofType: type, forKey: key, invert: invert) ?? self.profile(withValue: value, ofType: type, forPayloadKey: key, invert: invert)
        case .payload:
            return try self.profile(withValue: value, ofType: type, forPayloadKey: key, invert: invert)
        case .profile:
            return try self.profile(withValue: value, ofType: type, forKey: key, invert: invert)
        }
    }
    
    public class func profile(withValue value: Any, forKey key: Key, level: Level = .none, invert: Bool = false) throws -> [String: Any]? {
        switch key {
        case .fileModDate:
            return try self.profile(withValue: value, ofType: Date.self, forKey: key, level: .none, flags: key.flags, invert: invert)
        case .installedByUID,
             .syntheticInputDetected:
            return try self.profile(withValue: value, ofType: Int.self, forKey: key, level: .none, flags: key.flags, invert: invert)
        default:
            return try self.profile(withValue: value, ofType: String.self, forKey: key, level: level, flags: key.flags, invert: invert)
        }
    }
    
    // MARK: -
    // MARK: Generic Convenience Functions - All Profiles
    
    private class func profiles<T: Equatable>(withValue value: Any, ofType type: T.Type, forKey key: Key, invert: Bool) throws -> [[String: Any]]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.filter({
            $0.value.contains(where: {
                (invert) ? $0[key.rawValue] as? T != value as? T : $0[key.rawValue] as? T == value as? T
            })
        }).values.flatMap { $0 }
    }
    
    private class func profiles<T: Equatable>(withValue value: Any, ofType type: T.Type, forPayloadKey key: Key, invert: Bool) throws -> [[String: Any]]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.filter({
            $0.value.contains(where: {
                ($0[Key.payloads.rawValue] as? [[String: Any]])?.contains(where: {
                    (invert) ? $0[key.rawValue] as? T != value as? T : $0[key.rawValue] as? T == value as? T
                }) ?? (invert) ? true : false
            })
        }).values.flatMap { $0 }
    }
    
    private class func profiles<T: Equatable>(withValue value: Any, ofType type: T.Type, forInternalDataKey key: Key, invert: Bool) throws -> [[String: Any]]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.filter({
            $0.value.contains(where: {
                let internalData = ($0[Key.internalData.rawValue] as? [String: Any])
                return (invert) ? internalData?[key.rawValue] as? T != value as? T : internalData?[key.rawValue] as? T == value as? T
            })
        }).values.flatMap { $0 }
    }
    
    private class func profiles<T: Equatable>(withValue value: Any, ofType type: T.Type, forCMSCertificateKey key: Key, invert: Bool) throws -> [[String: Any]]? {
        let installedProfiles = try self.installedProfiles()
        return installedProfiles.filter({
            $0.value.contains(where: {
                (($0[Key.internalData.rawValue] as? [String: Any])?[Key.cmsCertificatesInfo.rawValue] as? [[String: Any]])?.contains(where: {
                    (invert) ? $0[key.rawValue] as? T != value as? T : $0[key.rawValue] as? T == value as? T
                }) ?? (invert) ? true : false
            })
        }).values.flatMap { $0 }
    }
    
    // MARK: -
    // MARK: Convenience Functions - All Profiles
    
    private class func profiles<T: Equatable>(withValue value: Any, ofType type: T.Type, forKey key: Key, level: Level, flags: Flags = [], invert: Bool) throws -> [[String: Any]]? {
        if flags.contains(.cmsInfo) {
            return try self.profiles(withValue: value, ofType: type, forCMSCertificateKey: key, invert: invert)
        } else if flags.contains(.internalData) {
            return try self.profiles(withValue: value, ofType: type, forInternalDataKey: key, invert: invert)
        }
        switch level {
        case .none:
            return try self.profiles(withValue: value, ofType: type, forKey: key, invert: invert) ?? self.profiles(withValue: value, ofType: type, forPayloadKey: key, invert: invert)
        case .payload:
            return try self.profiles(withValue: value, ofType: type, forPayloadKey: key, invert: invert)
        case .profile:
            return try self.profiles(withValue: value, ofType: type, forKey: key, invert: invert)
        }
    }
    
    public class func profiles(withValue value: Any, forKey key: Key, level: Level = .none, invert: Bool = false) throws -> [[String: Any]]? {
        switch key {
        case .fileModDate:
            return try self.profiles(withValue: value, ofType: Date.self, forKey: key, level: .none, flags: key.flags, invert: invert)
        case .installedByUID,
             .syntheticInputDetected:
            return try self.profiles(withValue: value, ofType: Int.self, forKey: key, level: .none, flags: key.flags, invert: invert)
        default:
            return try self.profiles(withValue: value, ofType: String.self, forKey: key, level: level, flags: key.flags, invert: invert)
        }
    }
    
    
    // MARK: -
    // MARK: Command Functions
    
    public class func installedProfiles() throws -> [String: [[String: Any]]] {
        
        var installedProfiles = [String: [[String: Any]]]()
        
        let data = try runCommand(path: "/usr/libexec/mdmclient", arguments: ["installedProfiles"])
        
        if let aStreamReader = StreamReader(data: data) {
            defer {
                aStreamReader.close()
            }
            
            var currentProfile = [String: Any]()
            var currentProfiles = [[String: Any]]()
            
            var currentPayload = [String: String]()
            var currentPayloads = [[String: Any]]()
            
            var currentInternalData = [String: Any]()
            
            var currentCMSInfoArray = [[String: Any]]()
            var currentCMSInfo = [String: Any]()
            
            var state = State()
            
            while let line = aStreamReader.nextLine() {
                switch true {
                case line.contains("* System profile"):
                    state.setScope(.system)
                case line.contains("* User profile"):
                    if state.scope == .system, !currentProfiles.isEmpty {
                        installedProfiles["System"] = currentProfiles
                        currentProfiles = [[String: Any]]()
                    }
                    state.setScope(.user)
                case line.contains("**************************************"):
                    if !currentPayload.isEmpty {
                        currentPayloads.append(currentPayload)
                        currentPayload = [String: String]()
                    }
                    if !currentPayloads.isEmpty {
                        currentProfile[Key.payloads.rawValue] = currentPayloads
                        currentPayloads = [[String: Any]]()
                    }
                    if !currentProfile.isEmpty {
                        currentProfiles.append(currentProfile)
                        currentProfile = [String: Any]()
                    }
                    state.level = .none
                case line.contains("... Payload"):
                    state.level = .payload
                    if !currentPayload.isEmpty {
                        currentPayloads.append(currentPayload)
                        currentPayload = [String: String]()
                    }
                case line.contains(Key.cmsCertificatesInfo.rawValue):
                    state.flags.insert(.cmsInfo)
                case line.contains("Internal data"):
                    state.flags.insert(.internalData)
                case line.contains(");"):
                    if state.flags.contains(.cmsInfo) {
                        state.flags.remove(.cmsInfo)
                        if !currentCMSInfoArray.isEmpty {
                            currentInternalData[Key.cmsCertificatesInfo.rawValue] = currentCMSInfoArray
                            currentCMSInfoArray = [[String: Any]]()
                        }
                    }
                case line.contains("},"):
                    if state.flags.contains(.cmsInfo), !currentCMSInfo.isEmpty {
                        currentCMSInfoArray.append(currentCMSInfo)
                        currentCMSInfo = [String: Any]()
                    }
                case line.contains("}"): // SHOULD USE HAS PREFIX AS IT'S ONLY WHEN IT'S THE FIRST CHAR
                    if state.flags.contains(.cmsInfo) {
                        if !currentCMSInfo.isEmpty {
                            currentCMSInfoArray.append(currentCMSInfo)
                            currentCMSInfo = [String: Any]()
                        }
                    } else {
                        state.flags.remove(.internalData)
                        if !currentInternalData.isEmpty {
                            currentProfile[Key.internalData.rawValue] = currentInternalData
                            currentInternalData = [String: Any]()
                        }
                    }
                default:
                    let lineArray: [Substring]
                    if state.flags.contains(.internalData) {
                        lineArray = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)
                    } else {
                        lineArray = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
                    }
                    
                    if 2 <= lineArray.count {
                        guard let key = Key(rawValue: String(lineArray[0].trimmingCharacters(in: .whitespacesAndNewlines))) else { continue }
                        let value = String(lineArray[1].trimmingCharacters(in: .whitespacesAndNewlines))
                        if state.flags.contains(.cmsInfo) {
                            currentCMSInfo[key.rawValue] = valueForKey(key, value: value.replacingOccurrences(of: "[<> ]", with: "", options: [.regularExpression]).deletingSuffix(";"))
                        } else if state.flags.contains(.internalData) {
                            currentInternalData[key.rawValue] = valueForKey(key, value: value.trimmingCharacters(in: CharacterSet(charactersIn: "\";")))
                        } else if state.level == .profile {
                            currentProfile[key.rawValue] = value
                        } else if state.level == .payload {
                            currentPayload[key.rawValue] = value
                        }
                    }
                }
            }
            
            if !currentProfiles.isEmpty {
                switch state.scope {
                case .system:
                    installedProfiles["System"] = currentProfiles
                case .user:
                    installedProfiles["User"] = currentProfiles
                }
            }
        }
        
        return installedProfiles
    }
}
