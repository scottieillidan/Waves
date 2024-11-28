//
//  WavesApp.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI

@main
struct WavesApp: App {
    var body: some Scene {
        WindowGroup {
            // let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path())
            WavesPlayer()
                .colorScheme(.dark)
        }
    }
}
