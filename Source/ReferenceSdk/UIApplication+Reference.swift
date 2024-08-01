// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import Foundation

extension UIApplication {
    /// Fetches the top view controller on the first window on the first scene.
    /// This is not a robust method to do this, just a best attempt given we have no context on the
    /// structure of the host app.
    static func topViewController() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
           let keyWindow = windowScene.windows.first,
           let rootViewController = keyWindow.rootViewController
        {
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
