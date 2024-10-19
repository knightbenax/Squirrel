//
//  Bundle+releaseVersion.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "\(releaseVersionNumber ?? "1.0.0")"
    }
}
