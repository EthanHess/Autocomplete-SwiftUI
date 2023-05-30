//
//  MatrixContainer.swift
//  Autocomplete
//
//  Created by Ethan Hess on 5/30/23.
//

import Foundation
import SwiftUI

struct MatrixContainer: View {
    var body: some View {
        VStack {
            let vals = MatrixStore.values
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                Grid {
                    ForEach(vals) { subarray in
                        HStack {
                            ForEach(0..<subarray.items.count, id: \.self) { index in
                                Text("\(subarray.items[index])").frame(width: width / 3, height: width / 3).background(Color.random).cornerRadius(10)
                            }
                        }.frame(width: width, height: width / 3)
                    }
                }.frame(width: width, height: width)
            }
        }
    }
    
    //No auxiliary, just swap indices
    private func rotateMatrix(_ matrix: [Subarray]) -> [[Int]] {
        //TODO imp.
        return [[1,2,3]]
    }
}

struct MatrixStore {
    static var values : [Subarray] {
        let arrayOne = Subarray(id: 0, items: [1, 2, 3])
        let arrayTwo =  Subarray(id: 1, items: [4, 5, 6])
        let arrayThree = Subarray(id: 2, items: [7, 8, 9])
        let finalArray = [arrayOne, arrayTwo, arrayThree]
        assert(finalArray[0].items.count == finalArray.count) //perfect square
        return finalArray
    }
}

struct Subarray : Identifiable {
    let id : Int
    let items : [Int]
}
