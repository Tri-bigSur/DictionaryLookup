//
//  AppMainView.swift
//  DictionaryLookup
//
//  Created by warbo on 11/6/26.
//

import SwiftUI

struct AppMainView: View {
enum AppTab{
        case searchWord
        case wordList
}
   @State private var currentTab = AppTab.searchWord
    var body: some View {
        TabView(selection: $currentTab){
            ContentView()
                .tabItem{
                    Label("Search Word",systemImage: "text.page.badge.magnifyingglass")
                }
                .tag(AppTab.searchWord)
            WordBookView()
                .tabItem{
                    Label("Word List",systemImage: "bookmark")
                }
                .tag(AppTab.wordList)
        }
    }
}

#Preview {
    AppMainView()
}
