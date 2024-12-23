//
//  DataLoader.swift
//  MapMe
//
//  Created by Crypto on 12/13/24.
//

import Foundation
import CoreLocation

class DataLoader {

    enum DataLoaderError: Error {
        case fileNotFound(String)
        case invalidFormat(String)
    }
    
    // Load file into Data
    private func loadFile(name: String, extension ext: String) throws -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw DataLoaderError.fileNotFound("Could not find \(name).\(ext) in bundle.")
        }
        return try Data(contentsOf: url)
    }
    
    func loadNodes(from fileName: String) throws -> [GraphManager.Node] {
        let data = try loadFile(name: fileName, extension: "geojson")
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard
            let jsonDict = jsonObject as? [String: Any],
            let features = jsonDict["features"] as? [[String: Any]]
        else {
            throw DataLoaderError.invalidFormat("Nodes file does not contain 'features'.")
        }
        
        var nodes: [GraphManager.Node] = []
        
        for feature in features {
            guard
                let properties = feature["properties"] as? [String: Any],
                let geometry = feature["geometry"] as? [String: Any],
                let coords = geometry["coordinates"] as? [Double],
                coords.count == 2,
                let idValue = properties["id"]
            else {
                // Skip if missing required fields
                continue
            }

            // Convert ID to string consistently
            let nodeID = String(describing: idValue)
            
            let nodeType = properties["type"] as? String
            let nodeName = properties["name"] as? String
            
            let coordinate = CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
            
            //print("Node ID: \(nodeID), Name: \(nodeName ?? "nil"), Type: \(nodeType ?? "nil")")
            
            let node = GraphManager.Node(id: nodeID, coordinate: coordinate, type: nodeType, name: nodeName)
            
            nodes.append(node)
        }
        
        return nodes
    }
    
    func loadEdges(from fileName: String) throws -> [GraphManager.Edge] {
        let data = try loadFile(name: fileName, extension: "geojson")
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard
            let jsonDict = jsonObject as? [String: Any],
            let features = jsonDict["features"] as? [[String: Any]]
        else {
            throw DataLoaderError.invalidFormat("Edges file does not contain 'features'.")
        }
        
        var edges: [GraphManager.Edge] = []
        
        for feature in features {
            guard
                let properties = feature["properties"] as? [String: Any],
                let geometry = feature["geometry"] as? [String: Any],
                let fromID = properties["from"] as? String,
                let toID = properties["to"] as? String,
                let length = properties["length"] as? Double
            else {
                // Skip if missing required fields
                continue
            }
            
            // Geometry for edges is a MultiLineString:
            //   "geometry": { "type": "MultiLineString", "coordinates": [ [ [lon, lat], [lon, lat], ... ] ] }
            //
            // This means `coordinates` is an array of arrays of arrays: [[[Double]]]
            
            guard
                let multiLineCoords = geometry["coordinates"] as? [[[Double]]],
                let lineString = multiLineCoords.first // In this case, we assume one line per feature
            else {
                continue
            }
            
            var lineCoordinates: [CLLocationCoordinate2D] = []
            for coordPair in lineString {
                if coordPair.count == 2 {
                    let coord = CLLocationCoordinate2D(latitude: coordPair[1], longitude: coordPair[0])
                    lineCoordinates.append(coord)
                }
            }
            
            let edge = GraphManager.Edge(from: fromID, to: toID, length: length, coordinates: lineCoordinates)
            edges.append(edge)
        }
        
        return edges
    }
}

