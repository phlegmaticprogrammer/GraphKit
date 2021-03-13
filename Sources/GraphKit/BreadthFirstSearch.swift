//
//  BreadthFirstSearch.swift
//  
//
//  Created by Steven Obua on 13/03/2021.
//

import Foundation

public struct BreadthFirstSearchNode<Vertex : Hashable> : Hashable {
    public var vertex : Vertex
    public var distance : Int
    public var parent : Vertex?
        
    public static func forest(_ nodes : [BreadthFirstSearchNode<Vertex>]) -> Graph<Vertex> {
        var g = Graph<Vertex>()
        for node in nodes {
            if let parent = node.parent {
                g.connect(from: parent, to: node.vertex)
            } else {
                g.insert([node.vertex])
            }
        }
        return g
    }
    
}

public extension DirectedGraph {
    
    // the result is in ascending order with respect to the distance attribute
    func breadthFirstSearch<S : Sequence>(roots : S) -> [BreadthFirstSearchNode<Vertex>] where S.Element == Vertex {
        var discovered : Set<Vertex> = []
        var queue : [BreadthFirstSearchNode<Vertex>] = []
        var position : Int = 0
                
        for root in roots {
            if discovered.insert(root).inserted {
                let node = BreadthFirstSearchNode<Vertex>(vertex: root, distance: 0, parent: nil)
                queue.append(node)
            }
        }
        
        while position < queue.count {
            let current = queue[position]
            position += 1
            let distance = current.distance + 1
            let parent = current.vertex
            for vertex in successors(of: parent) {
                if discovered.insert(vertex).inserted {
                    let node = BreadthFirstSearchNode<Vertex>(vertex: vertex, distance: distance, parent: parent)
                    queue.append(node)
                }
            }
        }
        
        return queue
    }
    
    func distances<S : Sequence>(from : S) -> [Vertex : Int] where S.Element == Vertex {
        let nodes = breadthFirstSearch(roots: from)
        var result : [Vertex : Int] = [:]
        for node in nodes {
            result[node.vertex] = node.distance
        }
        return result
    }

}

