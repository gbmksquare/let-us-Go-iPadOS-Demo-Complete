//
//  OSLog.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 2019/08/03.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    // MARK: - Log
    static var `default`: OSLog {
        return log(category: "default")
    }
    
    // MARK: - Helper
    private static func log(category: String) -> OSLog {
        let identifier = Bundle.main.bundleIdentifier ?? "com.gbmksquare.iPadOS-Step-by-Step"
        return OSLog(subsystem: identifier, category: category)
    }
}
