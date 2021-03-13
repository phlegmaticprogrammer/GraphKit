//
//  DepthFirstSearch.swift
//  
//
//  Created by Steven Obua on 16/02/2021.
//

import Foundation

public struct DepthFirstSearchNode<Vertex : Hashable> : Hashable {
    public var vertex : Vertex
    public var discovered : Int
    public var finished : Int
    public var parent : Vertex?
        
    public static func forest(_ nodes : [DepthFirstSearchNode<Vertex>]) -> Graph<Vertex> {
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
    
    // the result is in ascending order with respect to the finished attribute
    func depthFirstSearch<S : Sequence>(vertices : S) -> [DepthFirstSearchNode<Vertex>] where S.Element == Vertex {
        var visited : Set<Vertex> = []
        var finished : [DepthFirstSearchNode<Vertex>] = []
        var time = 0
        
        func dfs(parent: Vertex?, from : Vertex) {
            guard !visited.contains(from) else { return }
            visited.insert(from)
            time += 1
            let discovered = time
            for vertex in successors(of: from) {
                dfs(parent: from, from: vertex)
            }
            time += 1
            let node = DepthFirstSearchNode<Vertex>(vertex: from, discovered: discovered, finished: time, parent: parent)
            finished.append(node)
        }
        
        for vertex in vertices {
            dfs(parent: nil, from: vertex)
        }

        return finished
    }
    
    func depthFirstSearch() -> [DepthFirstSearchNode<Vertex>]  {
        return depthFirstSearch(vertices: self)
    }

    func stronglyConnectedComponents() -> [Set<Vertex>] {
        let forwardDFS = depthFirstSearch()
        let sortedVertices = (forwardDFS.map { $0.vertex }).reversed()
        let transposed = Graph(self).reversedEdges()
        let transposedDFS = transposed.depthFirstSearch(vertices: sortedVertices)
        let forest = DepthFirstSearchNode<Vertex>.forest(transposedDFS)
        return forest.weaklyConnectedComponents()
    }
    
    func hasSelfCycle(_ vertex : Vertex) -> Bool {
        return successors(of: vertex).contains(vertex)
    }
    
    func cyclicVertices() -> Set<Vertex> {
        var cyclic : Set<Vertex> = []
        for component in stronglyConnectedComponents() {
            if component.count > 1 || hasSelfCycle(component.first!) {
                cyclic.formUnion(component)
            }
        }
        return cyclic
    }
}
