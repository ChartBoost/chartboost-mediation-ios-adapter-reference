//
//  ReferenceError.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation

/// TODO: Remove once https://github.com/ChartBoost/ios-helium-sdk/pull/673 is available for use.
enum ReferenceError: Error {
    case tempError
    
    var localizedDescription: String {
        switch self {
        case .tempError:
            return "This is a temporary error. Remember to adopt PartnerAdapterErrors once it's finalized."
        }
    }
}
