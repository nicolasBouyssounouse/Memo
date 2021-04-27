//
//  MemoApp.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 27/04/2021.
//

import SwiftUI

@main
struct MemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
