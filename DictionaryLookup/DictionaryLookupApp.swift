//
//  DictionaryLookupApp.swift
//  DictionaryLookup
//
//  Created by warbo on 7/6/26.
//

import SwiftUI
import SwiftData

@main
struct DictionaryLookupApp: App {
    var body: some Scene {
        WindowGroup {
            AppMainView()
        }
        .modelContainer(for: [WordFolder.self,FavoriteWord.self])
        
    }
}
