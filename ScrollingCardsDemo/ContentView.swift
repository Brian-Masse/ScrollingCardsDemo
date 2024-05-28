//
//  ContentView.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/26/24.
//

import SwiftUI
import UIUniversals

struct ContentView: View {

    let card = Card(title: "The MOMA series",
                    description: "We all benefit from better craftsmanship. Products that are thoughtfully conceptualized, ideated upon, and ultimately sculpted by artists are more reliable, functional, and enjoyable to use. ",
                    date: Date.now,
                    name: "Brian Masse")
    
    var body: some View {
        ZStack {
            Image("Ventura")
                .resizable()
                .saturation(0.7)
                .ignoresSafeArea()
                .scaleEffect(1.5)
                .blur(radius: 50)
                
            
            StyledScrollView(cards: [ card, card, card, card, card, card, card ])
                .padding(.horizontal,7)
        }
    }
}

#Preview {
    ContentView()
}

