//
//  CardView.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/26/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct Card: Identifiable {
    let title: String
    let description: String
    let date: Date
    let name: String
    
    func formatDate() -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var id: String {
        title + description + date.formatted() + name
    }
}

struct CardView: View {
//    MARK: Constants
    struct LocalConstants {
        static let height: CGFloat = 275
        static let smallHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 15
        static let horizontalPadding: CGFloat = 10
        
        static let spacing: CGFloat = 10
    }
    
    let card: Card
    let totalCards: Int
    let height: CGFloat
    let index: Int
    
    @Binding var scrollPosition: CGFloat
    
    @State var showingFullCard = true
    
    @State var scaleModifier: CGFloat = 0
    @State var scale: CGFloat = 1
    @State var alpha: CGFloat = 1
    
//    MARK: Struct Methods
    private func makeScale() {
        let startingPosition = (LocalConstants.height + LocalConstants.spacing) * (CGFloat(index))
        let invertedDistance = -(startingPosition - abs( correctedScrollPosition))
        
        if checkOutOfScrollViewBounds(for: self.index) {
            let input = (1/3500) * invertedDistance
            let scale = 1 / (input + 1)
            self.scale = scale
            withAnimation { self.alpha = scale * 0.85 }
        } else {
            let input: Double = Double(invertedDistance) + 170
            let bellCurve: Double = powl( 2, -pow((1/90) * input, 2) )
            
            let dampener: Double = (1/20)
            
            let scale = max(dampener * bellCurve + 1, 1)
            self.scale = scale
            withAnimation { self.alpha = scale * 1 }
        }
    }
    
    private var correctedScrollPosition: CGFloat {
        let numberOfCardsOnScreen: Double = floor(height / LocalConstants.height) + 0.5
        let maxScroll = (LocalConstants.height + LocalConstants.spacing) * (Double(totalCards) - numberOfCardsOnScreen)

        return max(scrollPosition, -maxScroll)
    }
    
    private func checkHalfContentToggle() {
        let startingPosition = (LocalConstants.height + LocalConstants.spacing) * (CGFloat(index) + 0.4)
        if abs( correctedScrollPosition) > (startingPosition) {
            withAnimation { if showingFullCard { showingFullCard = false }}
        } else {
            withAnimation { if !showingFullCard { showingFullCard = true }}
        }
    }
    
    private func checkOutOfScrollViewBounds(for index: Int) -> Bool {
        let startingPosition = (LocalConstants.height + LocalConstants.spacing) * (CGFloat(index))
        return abs( correctedScrollPosition) > (startingPosition)
    }
    
//    finds the amount the current card is ahead in scrolling based off of
//    how much all the previous cards have shrunk
//    and returns and offset to counteract it
    private func compensateForCardScaling() -> CGFloat {
        var compensationFactor: CGFloat = 0;
        for i in 0..<self.index {
            let lossDueToScaling = LocalConstants.height - makeHeight(from: i)
            compensationFactor += lossDueToScaling
        }
        return compensationFactor
    }
    
    private func makeHeight(from index: Int) -> CGFloat {
        let startingPosition = (LocalConstants.height + LocalConstants.spacing) * (CGFloat(index))
        
        let selfOutOfView = checkOutOfScrollViewBounds(for: index)
        let nextOutOfView = checkOutOfScrollViewBounds(for: index + 1)
        
        if selfOutOfView && !nextOutOfView {
            return max(LocalConstants.height - (abs(correctedScrollPosition) - startingPosition ), LocalConstants.smallHeight)
        } else {
            return LocalConstants.height
        }
    }
    
    private func makeOffset() -> CGFloat {
        let compensationFactor = compensateForCardScaling()
        
        let selfOutOfView = checkOutOfScrollViewBounds(for: self.index)
        let nextOutOfView = checkOutOfScrollViewBounds(for: self.index + 1)
        
        
        if selfOutOfView && !nextOutOfView {
            return -scrollPosition - ( (LocalConstants.height + LocalConstants.spacing) * CGFloat(index)) + compensationFactor
        } else {
            return compensationFactor
        }
        
    }
    
//    MARK: Content
    @ViewBuilder
    private func makeHeader() -> some View {
        HStack {
            StyledText(card.title,
                       size: 20,
                       bold: true)
            
            Spacer()
            
            Image(systemName: "circle.slash")
        }
    }
    
    @ViewBuilder
    private func makeBody() -> some View {
        VStack(alignment: .leading) {
            StyledText( "Description", size: 15 )
            
            StyledText( card.description, size: 10 )
                .padding(.trailing, 50)
                .padding(.bottom)
            
            StyledText( "Time", size: 15 )
            StyledText( card.formatDate(), size: 12 )
        }
    }
    
    @ViewBuilder
    private func makeFooter() -> some View {
        HStack {
            Image(systemName: "questionmark.app.dashed")
            
            Spacer()
            
            StyledText( card.name, size: 12 )
        }
    }

    @ViewBuilder
    private func makeContent() -> some View {
        VStack(alignment: .leading) {
            makeHeader()
            
            if showingFullCard {
                Image(systemName: "arrow.right")
                
                Spacer()
                
                Divider()
                
                makeBody()
                    .minimumScaleFactor(0.5)
                
                makeFooter()
                    .minimumScaleFactor(0.5)
            }
        }
        .foregroundStyle(.white)
    }
    
//    MARK: BODY
    var body: some View {
     
        ZStack {
            Rectangle()
                .foregroundStyle(.black)
            
            makeContent()
                .padding( showingFullCard ? 25 : 15)
        }
        .opacity(alpha)
        .clipShape(RoundedRectangle(cornerRadius: LocalConstants.cornerRadius))
        .padding(.horizontal, LocalConstants.horizontalPadding)
        
        .shadow(color: .black.opacity(0.3), radius: 0.5, x: 1, y: 1)
        .shadow(color: .white.opacity(0.2), radius: 0.5, x: -1, y: -1)
        
        .frame(height: makeHeight(from: index))
        .scaleEffect( scale + scaleModifier )
        
        .animation( .easeInOut(duration: 0.2), value: scaleModifier)
        .onTapGesture {
            scaleModifier = 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { scaleModifier = 0 }
        }
    
        .offset(y: makeOffset())
        .onChange(of: correctedScrollPosition) {
            makeScale()

            checkHalfContentToggle()
        }
    }
    
}
