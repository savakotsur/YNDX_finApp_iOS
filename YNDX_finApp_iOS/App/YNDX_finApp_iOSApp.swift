//
//  YNDX_finApp_iOSApp.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import SwiftUI

@main
struct YNDX_finApp_iOSApp: App {
    @State private var isSplashFinished = false

    var body: some Scene {
        WindowGroup {
            if isSplashFinished {
                TabBarView()
            } else {
                SplashScreen {
                    isSplashFinished = true
                }
            }
        }
    }
}
