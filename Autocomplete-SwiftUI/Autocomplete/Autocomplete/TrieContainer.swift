//
//  TrieContainer.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/6/23.
//

import SwiftUI

struct TrieContainer: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        if viewModel.trie != nil {
                            let root = viewModel.trie!.root
                            let rootPointX = (geometry.size.width / 2) - 20
                            let startPointRoot = CGPoint(x: rootPointX, y: 100)
                            let endPointRoot = CGPoint(x: rootPointX, y: offsetYForIndex(1))
                            
                            NodeUI(char: root.value).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: rootPointX, y: offsetYForIndex(1)).overlay(alignment: .center) {
                                Path { path in
                                    path.move(to: startPointRoot)
                                    path.addLine(to: endPointRoot)
                                    path.closeSubpath()
                                }.stroke(.white, lineWidth: 2)
                            }
                            
                            let allKeys = Array(root.children.keys)
                            //Need to recur and get children of children etc. for each letter to build tree
                            
                            let arr = getIdentifiableArrayFromKeys(allKeys)
                            
                            ForEach(0..<arr.count, id: \.self) { i in
                                let offsetX = offsetXForIndex(i)
                                let offsetY = offsetYForIndex(2)
                                NodeUI(char: arr[i].key).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: offsetX, y: offsetY).overlay(alignment: .center) {
                                    //won't add path to last node
                                    if i < (arr.count - 1) {
                                        let startPointChild = CGPoint(x: rootPointX, y: 100)
                                        let endPointChild = CGPoint(x: offsetX, y: offsetY)
                                        Path { path in
                                            path.move(to: startPointChild)
                                            path.addLine(to: endPointChild)
                                            path.closeSubpath()
                                        }.stroke(.white, lineWidth: 2)
                                    } else {
                                        Spacer()
                                    }
                                }
                            }
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
    
    //Will want to set x / y separately since one may be altered by index but not the other
    fileprivate func offsetYForIndex(_ layer: Int) -> CGFloat {
        return CGFloat(layer) * 60
    }
    
    fileprivate func offsetXForIndex(_ i: Int) -> CGFloat {
        return CGFloat(i) * 60
    }
    
    //MARK: TODO imp. get w / h of tree and size nodes accordingly (i.e. if bigger tree make nodes smaller and fit into view)
//    fileprivate func getFullWidthOfTrie(_ trie: Trie) -> Int {
//
//    }
//
//    fileprivate func getFullHeightOfTrie(_ trie: Trie) -> Int {
//
//    }
    
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
            Circle().foregroundColor(.green)
            Text(char).foregroundColor(.white).background(.clear)
        }.background(.clear)
    }
}

struct IdentifiableDictionary : Identifiable {
    var id = ""
    var key : String
}
