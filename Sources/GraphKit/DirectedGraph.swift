//
//  DirectedGraph.swift
//  
//
//  Created by Steven Obua on 20/10/2020.
//

import Foundation

public protocol DirectedGraph : Sequence where Element == Vertex {

    associatedtype Vertex : Hashable

    func successors(of vertex : Vertex) -> Set<Vertex>
    
    var count : Int { get }
    
}

public extension DirectedGraph {
    
    func closure(_ kernel : [Vertex]) -> Set<Vertex> {
        var hull = Set(kernel)
        var processing = kernel
        while !processing.isEmpty {
            for successor in successors(of: processing.removeLast()) {
                if hull.insert(successor).inserted {
                    processing.append(successor)
                }
            }
        }
        return hull
    }

    func reachable(_ kernel : [Vertex]) -> Set<Vertex> {
        var hull : Set<Vertex> = []
        var processing = kernel
        while !processing.isEmpty {
            for successor in successors(of: processing.removeLast()) {
                if hull.insert(successor).inserted {
                    processing.append(successor)
                }
            }
        }
        return hull
    }
    
    func reachable(from : Vertex) -> Set<Vertex> {
        return reachable([from])
    }
    
    func tracePathWhileUnique(from: Vertex) -> [Vertex] {
        var alreadyVisited : Set<Vertex> = Set()
        var path = [from]
        while true {
            let current = path.last!
            let succs = successors(of: current)
            switch succs.count {
            case 0: return path
            case 1:
                let successor = succs.first!
                guard alreadyVisited.insert(successor).inserted else { return path }
                path.append(successor)
            default: return path
            }
        }
    }
    
    func roots() -> Set<Vertex> {
        var roots = Set(self)
        for v in self {
            for w in successors(of: v) {
                let _ = roots.remove(w)
            }
        }
        return roots
    }
    
    func topologicalSort() -> [Vertex]? {
        guard cyclicVertices().count == 0 else { return nil }
        
        var visited : Set<Vertex> = []
        var discovered : [Vertex] = []
        
        func dfs(from : Vertex) {
            guard visited.insert(from).inserted else { return }
            discovered.append(from)
            for vertex in successors(of: from) {
                dfs(from: vertex)
            }
        }
        
        for vertex in roots() {
            dfs(from: vertex)
        }

        return discovered
    }
    
}
