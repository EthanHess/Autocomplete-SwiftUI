//
//  AutocompleteApp.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/6/23.
//

import SwiftUI

@main
struct AutocompleteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ViewModel()).background(Color.black)
        }
    }
}
