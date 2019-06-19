//
//  Key.swift
//  profileutil
//
//  Created by Erik Berglund on 2019-04-19.
//  Copyright © 2019 Erik Berglund. All rights reserved.
//

import Foundation

public enum Key {
    // Profile/Payload
    case uuid
    case payloads
    case scope
    case internalData
    case identifier
    
    // InternalData
    case fileModDate
    case installSource
    case installedByUID
    case payloadScope
    case syntheticInputDetected
    case cmsCertificatesInfo
    
    // CMSCertificatesInfo
    case isSignerCert
    case certData
    
    // Other
    case unknown(String)
}

extension Key: RawRepresentable {
    public typealias RawValue = String
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "UUID":                    self = .uuid
        case "Payloads":                self = .payloads
        case "Scope":                   self = .scope
        case "InternalData":            self = .internalData
        case "Identifier":              self = .identifier
        case "CMSCertificatesInfo":     self = .cmsCertificatesInfo
        case "FileModDate":             self = .fileModDate
        case "InstallSource":           self = .installSource
        case "InstalledByUID":          self = .installedByUID
        case "IsSignerCert":            self = .isSignerCert
        case "PayloadScope":            self = .payloadScope
        case "SyntheticInputDetected":  self = .syntheticInputDetected
        case "CertData":                self = .certData
            
        default:
            self = .unknown(rawValue)
        }
    }
    
    public var flags: Flags {
        switch self {
        case .certData,
             .isSignerCert:
            return .cmsInfo
            
        case .cmsCertificatesInfo,
             .fileModDate,
             .installSource,
             .installedByUID,
             .payloadScope,
             .syntheticInputDetected:
            return .internalData
            
        default:
            return []
        }
    }
    
    public var rawValue: RawValue {
        switch self {
        case .uuid:                     return "UUID"
        case .payloads:                 return "Payloads"
        case .scope:                    return "Scope"
        case .internalData:             return "InternalData"
        case .identifier:               return "Identifier"
        case .cmsCertificatesInfo:      return "CMSCertificatesInfo"
        case .fileModDate:              return "FileModDate"
        case .installSource:            return "InstallSource"
        case .installedByUID:           return "InstalledByUID"
        case .isSignerCert:             return "IsSignerCert"
        case .syntheticInputDetected:   return "SyntheticInputDetected"
        case .certData:                 return "CertData"
        case .payloadScope:             return "PayloadScope"
            
        case .unknown(let unknownKey):  return unknownKey
        }
    }
}

func valueForKey(_ key: Key, value: String) -> Any {
    
    switch key {
        
    // Date
    case .fileModDate:
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from:value) ?? value
        
    // Int
    case .installedByUID,
         .syntheticInputDetected:
        return Int(value) ?? value
        
    // Bool
    case .isSignerCert:
        return NSString(string:value).boolValue
        
    // Data
    case .certData:
        return Data(withHexString: value)
        
    default:
        return value
    }
}
