//
//  LykoiApp.swift
//  Lykoi
//
//  Created by Thomas on 2020/12/11.
//

import SwiftUI

@main
struct LykoiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
