// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import Foundation

extension URL {
    /// A failable init to avoid encoding invalid `unsafeString` characters in the `URL`.
    /// - Parameter unsafeString: An unsanitized string that potentially contains invalid characters for representing a URL.
    init?(unsafeString: String) {
        if #available(iOS 17.0, *) {
            // On iOS 17+, `URL(string:)` assumes `encodingInvalidCharacters` being `true`, which is
            // inconsistent with older iOS versions and makes bad URL less obvious.
            self.init(string: unsafeString, encodingInvalidCharacters: false)
        } else {
            self.init(string: unsafeString)
        }
    }
}
