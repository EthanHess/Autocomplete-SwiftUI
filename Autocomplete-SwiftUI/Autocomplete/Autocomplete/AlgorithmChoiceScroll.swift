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
    
    var body: some View {
        HStack {
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                OffsetObservingScrollView(offset: $scrollOffset) {
                    HStack {
                        LazyHStack {
                            let upperBounds = Int(algorithmTypeArray().count)
                            ForEach(0..<upperBounds, id: \.self) { index in
                                let text = algorithmTypeArray()[index]
                                Spacer()
                                Text(text).frame(width: width / 2, height: 100).padding().background(
                                LinearGradient(
                                    colors: [.blue, .white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ).opacity(0.6)
                            ).clipShape(Capsule())
                                Spacer()
                            }
                        }
                    }
                }
            }
        }.onChange(of: scrollOffset) { val in
            print("Scroll offset H \(val)")
        }
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
