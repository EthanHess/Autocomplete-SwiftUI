//
//  ContentView.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/6/23.
//

import SwiftUI

struct ContentView: View {
    
    //@Binding var results : [String]
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        VStack {
            TextFieldContainer().environmentObject(viewModel).background(Color.blue).shadow(color: .cyan, radius: 5)
            TrieContainer().environmentObject(viewModel).background(Color.teal).shadow(color: .cyan, radius: 5)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewModel())
    }
}
