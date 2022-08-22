//
//  ReferenceAd.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
/// A dummy SDK designed to support the reference adapter.
/// Do NOT copy.
protocol ReferenceAd {
    /// The placement name identifying the current ad.
    var placement: String? {get set}
    
    /// The Helium logging mechanism.
    var logger: HeliumLogger? {get set}
    
    /// Load the ad with an optional ad markup.
    func load(adm: String?)
    
    /// Show the loaded ad, if any.
    func show()
    
    /// Destroy the current ad, if any.
    func destroy()
}
