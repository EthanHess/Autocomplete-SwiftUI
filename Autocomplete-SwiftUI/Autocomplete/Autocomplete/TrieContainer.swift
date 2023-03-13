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
                        NodeUI(char: root.value).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: (geometry.size.width / 2) - 20, y: 100)
                        
                        let allKeys = Array(root.children.keys)
                        let arr = getIdentifiableArrayFromKeys(allKeys)
  
                        ForEach(0..<arr.count, id: \.self) { i in
                            let offset = offsetForIndex(i)
                            NodeUI(char: arr[i].key).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: offset.x + 60, y: offset.y + 60) //just for test
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
    
    fileprivate func offsetForIndex(_ i: Int) -> CGPoint {
        return CGPoint(x: i * 60, y: i * 60)
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
