//
//  TextFieldContainer.swift
//  Autocomplete
//
//  Created by Ethan Hess on 3/6/23.
//

//import Foundation //For accessing NSObject + subclasses (heirarchy controller)
import SwiftUI

enum InputMode: Int {
    case add
    case search
}

struct TextFieldContainer: View {
    
    @State private var inputMode : InputMode = .add
    @State private var searchText : String = ""
    @State private var trie : Trie?
    
    //@Binding var resultStrings : [String] //Share results w / parent then update trie
    
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        VStack {
            let placeholder = inputMode == .search ? "Search Trie" : "Add Word"
            TextField(
                placeholder,
                text: $searchText
            ).background(.white).textFieldStyle(RoundedBorderTextFieldStyle()).onSubmit {
                inputMode == .search ? searchTrie(str: searchText) : addToTrie(str: searchText)
            }
            
            //TODO, make more obvious which is selected (Background or something)
            HStack {
                Spacer()
                Button {
                    inputMode = .search
                } label: {
                    Text("Search").foregroundColor(.white)
                }
                Spacer()
                Button {
                    inputMode = .add
                } label: {
                    Text("Add").foregroundColor(.white)
                }
                Spacer()
            }
        }
        .padding().onAppear( perform: {
            setUpTrie()
            pickerStyle()
        })
    }
    
    fileprivate func pickerStyle() {
        //MARK: Picker is backed by UIKit class, this approach works
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
    
    private func setUpTrie() {
        let rootNode = Node(value: "")
        let autocompleteTrie = Trie(root: rootNode)
        
        let words = ["hello", "dog", "hell", "cat", "a", "hel", "help", "helps", "helping"]
        for word in words {
            autocompleteTrie.insert(word: word)
        }
        
        self.trie = autocompleteTrie
        
        print("RESULT TEST \(autocompleteTrie.suggest("hel"))")
        print("CHILDREN \(autocompleteTrie.root.children)")
    }
    
    private func searchTrie(str: String) {
        guard let theTrie = self.trie else { return }
        let suggestions = theTrie.suggest(str)
        //resultStrings = suggestions
        
        viewModel.results = suggestions
    }
    
    //TODO Check if doesn't exist first
    private func addToTrie(str: String) {
        guard let theTrie = self.trie else { return }
        theTrie.insert(word: str)
        
        viewModel.trie = theTrie
    }
}

//MARK: Move these to their own file, but for now it helps to visualize setup

typealias ChildMap = [String : Node] //Character -> Node

struct Node {
    var value : String
    var isEnd : Bool
    var children : ChildMap
    
    init(value: String, isEnd: Bool = false, children: ChildMap = [:]) {
        self.value = value
        self.isEnd = isEnd
        self.children = children
    }
}

//Will conform to Equatable to observe changes
class Trie: Equatable {
    static func == (lhs: Trie, rhs: Trie) -> Bool {
        return lhs.allWords == rhs.allWords
    }
    
    //Trie, a type of tree good for locating specific keys (like a character for autocomplete)
    var root : Node //Top of the three
    private var allWords : [String] = [] //to compare tries
    
    init(root: Node) {
        self.root = root
    }
    
    //MARK: Insert + Search
    func insert(word: String) {
        var current = self.root
        for char in strToCharArray(word) {
            let charString = charToString(char)
            if (current.children[charString] == nil) {
                current.children[charString] = Node(value: charString)
                print("CUR CHILDREN \(current.children)")
            }
            current = current.children[charString]!
        }
        allWords.append(word)
        current.isEnd = true
    }
    
    func search(word: String) -> Bool {
        var current = self.root
        for char in strToCharArray(word) {
            let charString = charToString(char)
            if (current.children[charString] == nil) {
                return false
            }
            current = current.children[charString]!
        }
        return current.isEnd
    }
    
    //MARK: Helper functions
    func strToCharArray(_ str: String) -> Array<Character> {
        return Array(str)
    }
    
    func charToString(_ char: Character) -> String {
        return String(char)
    }
    
    //MARK: Suggestion handler
    func suggestionHelper(_ root: Node, list: inout [String], current: String) {
        if root.isEnd { list.append(current) } //last char / end of word so add to results
        if root.children.isEmpty { return }
        
        let allKeys = root.children.keys //keys are chars / letters
        
        //Make new root and recur
        for childMap in allKeys {
            let newRoot = root.children[childMap]!
            let newCurrent = current.appending(childMap)
            suggestionHelper(newRoot, list: &list, current: newCurrent)
        }
    }
    
    func suggest(_ prefix: String) -> [String] {
        var current = ""
        var list : [String] = []
        var theRoot = self.root //Assume exists, mandatory init param (start at top here and traverse tree)
        let prefixArray = strToCharArray(prefix)
        
        for i in 0..<prefixArray.count {
            //Check child map (node children dict of char strings that point to child nodes)
            let curChar = charToString(prefixArray[i])
            if theRoot.children[curChar] == nil { return [] } //char is not in child map
            theRoot = theRoot.children[curChar]!
            current += curChar
        }
        
        suggestionHelper(theRoot, list: &list, current: current)
        return list
    }
}
