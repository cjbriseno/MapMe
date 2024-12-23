//
//  BannerView.swift
//  MapMe
//
//  Created by Crypto on 12/23/24.
//

import SwiftUI
import MapboxMaps

struct BannerView: View {
    @Binding var currentStepIndex: Int
    
    var instructions: [String]
    var coordinates: [CLLocationCoordinate2D]
    //var mapboxMap: MapboxMap?
    var onPuckLocationUpdate: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        ZStack {
            if instructions.indices.contains(currentStepIndex) {
                Text(instructions[currentStepIndex])
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding()
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                handleSwipe(value: value)
                            }
                    )
            } else {
                Text("No Instructions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding()
            }
        }
    }
    
    private func handleSwipe(value: DragGesture.Value) {
        let horizontalDrag = value.translation.width
        
        if horizontalDrag > 50 {
            // Swipe right: Go to the previous step
            currentStepIndex = max(currentStepIndex - 1, 0)
        } else if horizontalDrag < -50 {
            // Swipe left: Go to the next step
            currentStepIndex = min(currentStepIndex + 1, instructions.count - 1)
        }
        
        // update puck location
        if coordinates.indices.contains(currentStepIndex) {
            onPuckLocationUpdate(coordinates[currentStepIndex])
        }
    }
}

