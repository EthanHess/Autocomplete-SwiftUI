//
//  TrieContainer.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/6/23.
//

import SwiftUI

struct TrieContainer: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    func offsetChildRow(_ i: Int, childWidth: CGFloat) -> CGFloat {
        return childWidth * CGFloat(i)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        let geoSize = geometry.size
                        if viewModel.trie != nil {
                            let root = viewModel.trie!.root
                            let rootPointX = (geoSize.width / 2) - 20
                            let startPointRoot = CGPoint(x: rootPointX, y: 100)
                            let endPointRoot = CGPoint(x: rootPointX, y: NodeHelper.offsetYForIndex(1))
                            
                            NodeUI(char: root.value).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: rootPointX, y: NodeHelper.offsetYForIndex(1)).overlay(alignment: .center) {
                                Path { path in
                                    path.move(to: startPointRoot)
                                    path.addLine(to: endPointRoot)
                                    path.closeSubpath()
                                }.stroke(.white, lineWidth: 2)
                            }
            
                            
                            //MARK: Other approach (Keep for reference then discard)
                            
                            //let allKeys = Array(root.children.keys)
                            //Need to recur and get children of children etc. for each letter to build tree

                            let arr = NodeHelper.getIdentifiableArrayFromKeys(root)
                            let childWidth = geoSize.width / CGFloat(arr.count) //TODO factor in width of their children (length, if they have them etc.)

                            ForEach(0..<arr.count, id: \.self) { i in
                                //Top row (root's children, can use recursive builder function for this too but just seeing how it looks / works this way)
                                let nodeAtIndex = arr[i]
                                let offsetX = NodeHelper.offsetXForIndex(i)
                                let offsetY = NodeHelper.offsetYForIndex(2)
                                NodeUI(char: nodeAtIndex.key).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: offsetX, y: offsetY).overlay(alignment: .center) {
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
                                
                                //MARK: Recur until end of trie (shows nodes but need to adjust coordinates)
                                
                                if !nodeAtIndex.val.children.isEmpty {
                                    NodeRow(node: nodeAtIndex.val, x: NodeHelper.offsetXForIndex(i), y: offsetY, depth: 3).frame(width: childWidth, height: 60).offset(x: offsetChildRow(i, childWidth: childWidth))
                                } else {
                                    EmptyView()
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
    
    //MARK: TODO imp. get w / h of tree and size nodes accordingly (i.e. if bigger tree make nodes smaller and fit into view)

    //"some" just means it conforms to View protocol, it could be VStack / HStack / Text etc. with whatever children but we know View is the opaque type, no need to be any more specific and expose type info
    
//    fileprivate func bezierPathBetweenViews(_ viewOne: some View, viewTwo: some View, geometry: GeometryProxy) -> Path {
//        //TODO imp.
          //https://stackoverflow.com/questions/68792805/swiftui-drawing-curved-paths-between-views
//    }
}

//MARK: Helper UI, TODO move to own file
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

//MARK: Recur children all the way down view until end of trie, organize into rows (depth)
struct NodeRow: View {
    
    @State var node : Node
    @State var x : CGFloat
    @State var y : CGFloat
    @State var depth : CGFloat
    
    private func parentNodes(_ nodes: [IdentifiableDictionary]) -> [IdentifiableDictionary] {
        var returnArray : [IdentifiableDictionary] = []
        for nodeDict in nodes {
            if !nodeDict.val.children.isEmpty { returnArray.append(nodeDict) }
        }
        return returnArray
    }
    
    var body: some View {
       // GeometryReader { geometry in
            //let geoSize = geometry.size
            HStack {
                let arr = NodeHelper.getIdentifiableArrayFromKeys(node)
                let parents = parentNodes(arr)
                ForEach(0..<arr.count, id: \.self) { index in //Main children
                    let nodeAtIndex = arr[index]
                    let offsetX = NodeHelper.offsetXForIndex(Int(x)) //use parent for test
                    let offsetY = NodeHelper.offsetYForIndex(Int(depth))
                    NodeUI(char: nodeAtIndex.key).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: NodeHelper.offsetXForIndex(index), y: offsetY).overlay(alignment: .center) {
                        //won't add path to last node
                        if index < (arr.count - 1) {
                            let startPointChild = CGPoint(x: x, y: y)
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
                
                //Recur each child
                ForEach(0..<parents.count, id: \.self) { index in //Their children
                    let parentAtIndex = arr[index]
                    let childArray = NodeHelper.getIdentifiableArrayFromKeys(parentAtIndex.val)
                    ForEach(0..<childArray.count, id: \.self) { childIndex in
                        let childAtIndex = childArray[childIndex]
             //           let offsetX = NodeHelper.offsetXForIndex(Int(x)) //Use parent X for test
                        let offsetY = NodeHelper.offsetYForIndex(Int(depth + 1))
                        NodeUI(char: childAtIndex.key).frame(width: 40, height: 40, alignment: .center).cornerRadius(20).offset(x: NodeHelper.offsetXForIndex(childIndex), y: offsetY)
                    }
                }
            }
       // }
    }
}

//MARK: Helper struct (not UI related)
struct IdentifiableDictionary : Identifiable {
    var id = ""
    var key : String
    var val : Node
}

struct NodeHelper {
    //Will want to set x / y separately since one may be altered by index but not the other
    static func offsetYForIndex(_ layer: Int) -> CGFloat {
        return CGFloat(layer) * 60
    }
    
    static func offsetXForIndex(_ i: Int) -> CGFloat {
        return CGFloat(i) * 60
    }
    
    //Slowly draw tree one node after another
    //Add as extension to "View" or return some View to be able to use within "body" scope.
    static func executeAfterDelay(_ timeInterval: Double, action: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + timeInterval
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            action()
        }
    }

    //If tree grows this is not efficient, make sure original map is identifiable to not iterate twice

    //For a small tree example / workaround this is okay though
    static func getIdentifiableArrayFromKeys(_ node: Node) -> [IdentifiableDictionary] {
        var returnArray : [IdentifiableDictionary] = []
        let allKeys = node.children.keys
        for str in allKeys {
            let val = node.children[str]!
            let dict = IdentifiableDictionary(key: str, val: val)
            returnArray.append(dict)
        }
        return returnArray
    }
}


extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
