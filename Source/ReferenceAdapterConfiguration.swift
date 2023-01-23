// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

//
//  ReferenceAdapterConfiguration.swift
//  ChartboostHeliumAdapterReference
//
//  Created by Vu Chau on 8/29/22.
//

import Foundation

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class ReferenceAdapterConfiguration: NSObject {
    
    /// Flag that can optionally be set to enable the partner's test mode.
    /// Disabled by default.
    @objc public static var testMode: Bool = false {
        didSet {
            ReferenceSdk.setTestMode(enabled: testMode)
            print("Reference SDK test mode set to \(testMode)")
        }
    }
    
    /// Flag that can optionally be set to enable the partner's verbose logging.
    /// Disabled by default.
    @objc public static var verboseLogging: Bool = false {
        didSet {
            ReferenceSdk.setVerboseLogging(enabled: verboseLogging)
            print("Reference SDK verbose logging set to \(verboseLogging)")
        }
    }
    
    /// Append any other properties that publishers can configure.
}
