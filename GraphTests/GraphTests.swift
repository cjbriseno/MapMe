//
//  GraphTests.swift
//  GraphTests
//
//  Created by Crypto on 12/13/24.
//

import XCTest
@testable import MapMe

class GraphTests: XCTestCase {

    func testGraphLoading() throws {
        let graphManager = GraphManager()

        // Test if nodes are loaded
        XCTAssertFalse(graphManager.nodes.isEmpty, "Nodes should not be empty.")
        
        // Check a known node ID
        XCTAssertNotNil(graphManager.nodes["110"], "Node with ID 110 should be present.")
        
        // Test if edges are loaded
        XCTAssertFalse(graphManager.edges.isEmpty, "Edges should not be empty.")
        
        // Check adjacency for a known node
        guard let neighbors = graphManager.adjacencyList["110"] else {
            XCTFail("Node 110 should have neighbors.")
            return
        }
        
        XCTAssertFalse(neighbors.isEmpty, "Node 110 should have at least one neighbor.")
        
        // Optionally verify a specific edge connection if you know it should exist
        let has1108Neighbor = neighbors.contains { $0.node == "1108" }
        XCTAssertTrue(has1108Neighbor, "Node 110 should be connected to 1108 according to the test data.")
    }
}
