//
//  Pathfinding.swift
//  MapMe
//
//  Created by Crypto on 12/13/24.
//

import Foundation

// for dijktras, uses binary heap to pop smallest element
struct PriorityQueue<Element> {
    private var elements: [Element]
    private let areSorted: (Element, Element) -> Bool
    
    init(sort: @escaping (Element, Element) -> Bool) {
        self.elements = []
        self.areSorted = sort
    }
    
    var isEmpty: Bool { elements.isEmpty }
    
    mutating func push(_ value: Element) {
        elements.append(value)
        elements.sort(by: areSorted)
    }
    
    mutating func pop() -> Element? {
        return isEmpty ? nil : elements.removeFirst()
    }
    
    func peek() -> Element? {
        return elements.first
    }
}

class Pathfinding {
    // find shortest path using dijktras from start to end. return tuble with shortest distance
    func dijkstra(graph: [String: [(node: String, weight: Double)]],
                  start: String,
                  goal: String) -> (distance: Double, path: [String])? {
        
        // Distance to each node from the start
        var distances: [String: Double] = [:]
        // Initialize distances to infinity except the start node
        for node in graph.keys {
            distances[node] = Double.infinity
        }
        distances[start] = 0
        
        // Previous node dictionary to reconstruct path
        var previous: [String: String?] = [:]
        for node in graph.keys {
            previous[node] = nil
        }
        
        // Priority queue for managing nodes to explore
        // We'll store tuples of (distance, node)
        var pq = PriorityQueue<(Double, String)>(sort: { $0.0 < $1.0 })
        pq.push((0, start))
        
        // While there are nodes to process
        while let (currentDist, currentNode) = pq.pop() {
            // If we reached the goal, stop
            if currentNode == goal {
                return (currentDist, reconstructPath(previous: previous, start: start, goal: goal))
            }
            
            // If the current distance is greater than the recorded shortest distance, skip
            if currentDist > distances[currentNode]! {
                continue
            }
            
            // Explore neighbors
            guard let neighbors = graph[currentNode] else { continue }
            for (neighbor, weight) in neighbors {
                let newDist = currentDist + weight
                // If we found a shorter path to the neighbor, update and push to queue
                if newDist < distances[neighbor]! {
                    distances[neighbor] = newDist
                    previous[neighbor] = currentNode
                    pq.push((newDist, neighbor))
                }
            }
        }
        
        // If we exit the loop without finding the goal, there is no path
        return nil
    }
    
    private func reconstructPath(previous: [String: String?], start: String, goal: String) -> [String] {
        var path: [String] = []
        var currentNode: String? = goal
        while currentNode != nil {
            path.append(currentNode!)
            currentNode = previous[currentNode!] ?? nil
        }
        return path.reversed()
    }
}
