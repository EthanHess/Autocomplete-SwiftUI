//
//  ViewModel.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/7/23.
//

import Foundation
import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var results : [String] = []
    @Published var trie : Trie?
}
