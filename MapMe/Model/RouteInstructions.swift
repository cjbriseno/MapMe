//
//  RouteInstructions.swift
//  MapMe
//
//  Created by Crypto on 12/16/24.
//

import Foundation
import CoreLocation

class RouteInstructions {
    // step-by-step instructions
    func generateInstructions(for path: [GraphManager.Node]) -> [String] {
        guard path.count > 1 else {
            return ["You are at your destination."]
        }
        
        var instructions: [String] = []
        
        // Compute segments: (A→B), (B→C), ...
        // Each segment has a distance and a bearing.
        var segments: [(start: GraphManager.Node, end: GraphManager.Node, distance: Double, bearing: Double)] = []
        
        for i in 0..<(path.count - 1) {
            let startNode = path[i]
            let endNode = path[i+1]
            
            let segmentDistance = distanceBetweenCoordinates(from: startNode.coordinate, to: endNode.coordinate)
            let segmentBearing = bearingBetweenCoordinates(from: startNode.coordinate, to: endNode.coordinate)
            
            segments.append((start: startNode, end: endNode, distance: segmentDistance, bearing: segmentBearing))
        }
        
        // The first instruction is usually something like "Head [Direction]" or "Go straight"
        // from the starting point.
        if let firstSegment = segments.first {
            let directionDescription = directionDescription(forBearing: firstSegment.bearing)
            instructions.append("Head \(directionDescription) for \(formatDistance(firstSegment.distance))")
        }
        
        // Intermediate segments: Check turns
        for i in 1..<segments.count {
            let previousSegment = segments[i-1]
            let currentSegment = segments[i]
            
            // Determine turn angle
            let turnAngle = angleDifference(from: previousSegment.bearing, to: currentSegment.bearing)
            
            // If angle difference is small, continue straight
            // If angle difference is significant, turn left/right
            if turnAngle > 30 {
                // Turn right
                instructions.append("Turn right and continue for \(formatDistance(currentSegment.distance))")
            } else if turnAngle < -30 {
                // Turn left
                instructions.append("Turn left and continue for \(formatDistance(currentSegment.distance))")
            } else {
                // Go straight
                instructions.append("Continue straight for \(formatDistance(currentSegment.distance))")
            }
        }
        
        // Final instruction: Arrive at destination
        if let lastNode = path.last, let secondToLastSegment = segments.last {
            instructions.append("You have arrived at \(lastNode.name ?? "your destination")")
        }
        
        return instructions
    }
    
    private func distanceBetweenCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLoc.distance(from: toLoc) // meters
    }
    
    private func bearingBetweenCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLat = from.latitude.toRadians
        let fromLon = from.longitude.toRadians
        let toLat = to.latitude.toRadians
        let toLon = to.longitude.toRadians
        
        let y = sin(toLon - fromLon) * cos(toLat)
        let x = cos(fromLat)*sin(toLat) - sin(fromLat)*cos(toLat)*cos(toLon - fromLon)
        let bearing = atan2(y, x).toDegrees
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    private func angleDifference(from: Double, to: Double) -> Double {
        // Compute smallest difference between two bearings
        let diff = to - from
        let modDiff = (diff + 180).truncatingRemainder(dividingBy: 360) - 180
        return modDiff
    }
    
    private func directionDescription(forBearing bearing: Double) -> String {
        // Simplistic direction description
        // You might refine this to say "north", "north-east", etc.
        switch bearing {
        case 0..<45, 315..<360:
            return "north"
        case 45..<135:
            return "east"
        case 135..<225:
            return "south"
        case 225..<315:
            return "west"
        default:
            return "straight"
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        // Convert meters to a rounded value.
        // For longer distances, you might say in meters or choose feet.
        let rounded = round(distance)
        return "\(Int(rounded)) meters"
    }
}

extension Double {
    var toRadians: Double { self * .pi / 180 }
    var toDegrees: Double { self * 180 / .pi }
}
