//
//  AlgorithmChoiceScroll.swift
//  Autocomplete
//
//  Created by Ethan Hess on 5/15/23.
//

import Foundation
import SwiftUI

struct AlgorithmChoiceScroll: View {
    
    @State private var scrollPosition : CGFloat = 0
    @State private var scrollOffset = CGPoint()
    @State private var selectedIndex = 0
    
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        HStack {
            GeometryReader { geo in
                let width = geo.size.width
                //let height = geo.size.height
                OffsetObservingScrollView(offset: $scrollOffset) {
                    HStack {
                        LazyHStack {
                            let upperBounds = Int(algorithmTypeArray().count)
                            ForEach(0..<upperBounds, id: \.self) { index in
                                let text = algorithmTypeArray()[index]
                                Spacer()
                                let textHeight = heightFromScrollOffset(scrollOffset.x, index: index, scrollWidth: width)
                                let colors = retrunColorsFromIndex(index)
                                Text(text).frame(width: width / 2, height: textHeight).padding().background(
                                LinearGradient(
                                    colors: colors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                    //TODO update duration
                                ).opacity(0.6).cornerRadius(10).animation(.easeInOut, value: textHeight)
                                    
                            ).onTapGesture { //Text
                                selectedIndex = index
                                //TODO pass to VM and display correct algorithm diagram
                                viewModel.selectedIndex = selectedIndex
                                print("selected index \(selectedIndex)")
                            }
//                                .clipShape(Capsule())
//                                Spacer()
                            }
                        }.background(
                            LinearGradient(
                                colors: [.blue, .white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }
        }.onChange(of: scrollOffset) { val in
            print("Scroll offset H \(val)")
        }
    }
    
    private func retrunColorsFromIndex(_ index: Int) -> [Color] {
        return index == selectedIndex ? [.green, .white] : [.blue, .white]
    }
    
    private func heightFromScrollOffset(_ curOffsetX: CGFloat, index: Int, scrollWidth: CGFloat) -> CGFloat {
        let rangeAtIndex = indexOffsetRangeMap(index, scrollWidth: scrollWidth)
        //TODO smoothly shrink as "Text" element moves off screen
        
        let finalHeight = rangeAtIndex.contains(curOffsetX) ? heightForSubrangeAtX(curOffsetX, curRange: rangeAtIndex) : 50
        return finalHeight
    }
    
    //Just a test, needs tweaks
    private func heightForSubrangeAtX(_ curOffsetX: CGFloat, curRange: Range<CGFloat>) -> CGFloat {
        let upperBounds = curRange.upperBound //The end of the scroll (in range)
        let operand = upperBounds - curOffsetX
        let height = (operand / 5) + 50
        print("height sr \(height)")
        return height
    }
    
    //Get the index's range where it'll be enlarged (showing on screen)
    //Fixed arr length here but may want to create new map dynamically when we add to array or if user can add to array
    private func indexOffsetRangeMap(_ index: Int, scrollWidth: CGFloat) -> Range<CGFloat> {
        let table = [0: Range(uncheckedBounds: (lower: 0, upper: scrollWidth / 2)),
                     1: Range(uncheckedBounds: (lower: scrollWidth / 2, upper: scrollWidth)),
                     2: Range(uncheckedBounds: (lower: scrollWidth, upper: scrollWidth * 1.5)),
                     3: Range(uncheckedBounds: (lower: scrollWidth * 1.5, upper: scrollWidth * 2)),
                     4: Range(uncheckedBounds: (lower: scrollWidth * 2, upper: scrollWidth * 2.5)),
                     5: Range(uncheckedBounds: (lower: scrollWidth * 3, upper: scrollWidth * 3.5))
        ]
        
        guard let theRange = table[index] else {
            return Range(uncheckedBounds: (lower: 0.0, upper: 1.0))
        }
        return theRange
    }
    
    //TODO add more
    private func algorithmTypeArray() -> [String] {
        return ["Autocomplete", "Matrix", "Stack", "String", "Array", "B Tree"] //B Tree = several nodes
    }
}


//Insanely enough, there is no built in way to track scroll position and perform updates

//Tutorial credit
//https://www.swiftbysundell.com/articles/observing-swiftui-scrollview-content-offset/


//MARK: Move after test
struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            // No-op
        }
    }
}

struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.horizontal]
    var showsIndicators = true
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content

    // The name of our coordinate space doesn't have to be
    // stable between view updates (it just needs to be
    // consistent within this view), so we'll simply use a
    // plain UUID for it:
    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
                        x: -newOffset.x,
                        y: -newOffset.y
                    )
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}
