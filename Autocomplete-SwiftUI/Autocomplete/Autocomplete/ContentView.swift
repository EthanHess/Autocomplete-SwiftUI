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
    
    //TODO display conditionally on algorithm scroll selection
    var body: some View {
        VStack {
//            GeometryReader { geo in
//            let width = geo.size.width
//            let height = geo.size.height
            
            //MARK: TODO map indices to correct struct + switch statement, but for now we'll just test these
            if viewModel.selectedIndex == 0 {
                TextFieldContainer().environmentObject(viewModel).background(Color.blue).shadow(color: .cyan, radius: 5)
                TrieContainer().environmentObject(viewModel).background(Color.teal).shadow(color: .cyan, radius: 5)
            } else if viewModel.selectedIndex == 1 {
                MatrixContainer().environmentObject(viewModel).background(Color.green)
            }
            
            //Always at the bottom to navigate between
            AlgorithmChoiceScroll().environmentObject(viewModel).background(Color.white).shadow(color: .cyan, radius: 5)
                    //.frame(width: width * 0.8, height: 100)
  //          }
        }.onChange(of: viewModel.selectedIndex, perform: { newValue in
            print("VM index \(newValue)")
        })
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() //Environment var here vs @main
    }
}
