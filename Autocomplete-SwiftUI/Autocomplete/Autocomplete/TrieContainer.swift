//
//  TrieContainer.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/6/23.
//

import SwiftUI

struct TrieContainer: View {
    
    @State var trie : Trie?
    @State var results : [String] = []
    
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    if viewModel.trie != nil {
                        let root = viewModel.trie!.root
                        NodeUI(char: root.value).frame(width: 40, height: 40, alignment: .center).cornerRadius(20)
                        let allKeys = Array(root.children.keys)
                        let arr = getIdentifiableArrayFromKeys(allKeys)
            
//                        var offsetX = 0
//                        var offsetY = 0
                        
                        ForEach(arr) { idDict in
                            NodeUI(char: idDict.key).frame(width: 40, height: 40, alignment: .center).cornerRadius(20)
                            
                            //Need to wrap this in function
                              //  .offset(x: CGFloat(offsetX), y: CGFloat(offsetY))
//                            offsetX += 60
//                            offsetY += 60 //Just testing something
                            
                        }
                    }
                }.onChange(of: viewModel.results) { newValue in
                    handleChangeResults(newValue)
                }.onChange(of: viewModel.trie) { newValue in //Bad to unwrap here?
                    if let newVal = newValue {
                        handleChangeTrie(newVal)
                    }
                }
            }
        }.onAppear(
            
        )
    }
    
    fileprivate func handleChangeResults(_ newVal: [String]) {
        print("New Results \(newVal)")
    }
    
    fileprivate func handleChangeTrie(_ newVal: Trie) {
        print("New Trie \(newVal)")
    }
    
    //If tree grows this is not efficient, make sure original map is identifiable to not iterate twice

    //For a small tree example / workaround this is okay though
    
    fileprivate func getIdentifiableArrayFromKeys(_ allKeys: [String]) -> [IdentifiableDictionary] {
        var returnArray : [IdentifiableDictionary] = []
        for str in allKeys {
            let dict = IdentifiableDictionary(key: str)
            returnArray.append(dict)
        }
        return returnArray
    }
    
    //"some" just means it conforms to View protocol, it could be VStack / HStack / Text etc. with whatever children but we know View is the opaque type, no need to be any more specific and expose type info
    
//    fileprivate func bezierPathBetweenViews(_ viewOne: some View, viewTwo: some View, geometry: GeometryProxy) -> Path {
//        //TODO imp.
          //https://stackoverflow.com/questions/68792805/swiftui-drawing-curved-paths-between-views
//    }
}

//TODO move to own file
struct NodeUI: View {
    
    @State var char : String
    // @State var shouldHighlight: Bool = false // when traversing tree
    
    var body: some View {
        ZStack {
            Circle().background(Color.green)
            Text(char).foregroundColor(.white).background(.clear)
        }.background(.clear)
    }
}

struct IdentifiableDictionary : Identifiable {
    var id = ""
    var key : String
}
