//
//  StyledScrollView.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/26/24.
//

import Foundation
import SwiftUI
//import UIUniversals

//MARK: RoundedMask
struct RoundedMask: Shape {
    
    let padding: CGFloat = CardView.LocalConstants.horizontalPadding
    let radius: CGFloat = 25
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let bottomRight = CGPoint(x: rect.maxX - padding - radius,
                                      y: rect.maxY - padding - radius)
            let bottomLeft  = CGPoint(x: rect.minX + padding + radius,
                                      y: rect.maxY - padding - radius)
            
            path.move(to:  bottomLeft )
            
            path.addArc(center: bottomLeft, radius: radius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: -180),
                        clockwise: false)
            
            path.move(to: bottomRight )
            path.addArc(center: bottomRight, radius: radius,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 90),
                        clockwise: false)
            
            path.move(to: CGPoint(x: 0, y: rect.maxY - padding - radius))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - padding - radius))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + padding + radius))
            path.addLine(to: CGPoint(x: 0, y: rect.minY + padding + radius))
            
            path.move(to: CGPoint(x: rect.minX + radius + padding, y: rect.maxY - padding))
            path.addLine(to: CGPoint(x: rect.maxX - radius - padding, y: rect.maxY - padding))
            path.addLine(to: CGPoint(x: rect.maxX - radius - padding, y: padding + radius))
            path.addLine(to: CGPoint(x: rect.minX + radius + padding, y: padding + radius))
            
            path.move(to: CGPoint(x: rect.minX, y: 0))
            path.addLine(to: CGPoint(x: rect.minX, y: padding + radius))
            path.addLine(to: CGPoint(x: rect.maxX, y: padding + radius))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        }
    }
}

struct StyledScrollView: View {
    
    let cards: [Card]
    
    let coordinateSpaceName = "scroll"
    
    @State var scrollPosition: CGPoint = .zero
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        VStack(spacing: CardView.LocalConstants.spacing) {
                            ForEach( cards.indices, id: \.self ) { i in
                                let card = cards[i]
                                
                                CardView(card: card,
                                         totalCards: cards.count,
                                         height: geo.size.height,
                                         index: i,
                                         scrollPosition: $scrollPosition.y)
                            }
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: 300)
                        }
                    }
                    .background(GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named(coordinateSpaceName)).origin)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        self.scrollPosition = value
                    }
                }
                .coordinateSpace(name: coordinateSpaceName)
                
                .clipShape( RoundedMask() )
            }
        }
    }
}

//MARK: PreferenceKey
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

#Preview {
    let card = Card(title: "The MOMA series",
                    description: "We all benefit from better craftsmanship. Products that are thoughtfully conceptualized, ideated upon, and ultimately sculpted by artists are more reliable, functional, and enjoyable to use. ",
                    date: Date.now,
                    name: "Brian Masse")
    
    return StyledScrollView(cards: [ card, card, card, card, card, card, card ])
}
