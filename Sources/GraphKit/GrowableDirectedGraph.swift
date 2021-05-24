//
//  GrowableDirectedGraph.swift
//  
//
//  Created by Steven Obua on 20/10/2020.
//

import Foundation

public protocol GrowableDirectedGraph : DirectedGraph {
    
    init()
    
    @discardableResult
    mutating func insert<S : Sequence>(_ vertices : S) -> Bool where S.Element == Vertex
    
    @discardableResult
    mutating func connect<S : Sequence>(from : Vertex, to : S) -> Bool where S.Element == Vertex
    
}

public extension GrowableDirectedGraph {
    
    init<G : DirectedGraph>(_ other : G) where G.Vertex == Vertex {
        self.init()
        insert(other)
        for v in other {
            connect(from: v, to: other.successors(of: v))
        }
    }
    
    @discardableResult
    mutating func connect(from : Vertex, to : Vertex) -> Bool {
        return connect(from : from, to : [to])
    }

    @discardableResult
    mutating func connect(_ vertex1 : Vertex, _ vertex2 : Vertex) -> Bool {
        let a = connect(from: vertex1, to: vertex2)
        let b = connect(from: vertex2, to: vertex1)
        return a || b
    }

    @discardableResult
    mutating func symmetricClosure() -> Bool {
        var changed = false
        for i in self {
            for j in successors(of: i) {
                if connect(from: j, to: i) { changed = true }
            }
        }
        return changed
    }
    
    func weaklyConnectedComponents() -> [Set<Vertex>] {
        var graph = self
        graph.symmetricClosure()
        var visited : Set<Vertex> = []
        var components : [Set<Vertex>] = []
        for vertex in graph {
            guard !visited.contains(vertex) else { continue }
            let component = graph.closure([vertex])
            visited.formUnion(component)
            components.append(component)
        }
        return components
    }
    
    func reversedEdges() -> Self {
        var reversed = Self()
        reversed.insert(self)
        for from in self {
            for to in successors(of: from) {
                reversed.connect(from: to, to: from)
            }
        }
        return reversed
    }
    
    @discardableResult
    mutating func transitiveHull() -> Bool {
        func step() -> Bool {
            var changed = false
            for v in self {
                let succs = successors(of: v)
                for succ in succs {
                    if connect(from: v, to: successors(of: succ)) {
                        changed = true
                    }
                }
            }
            return changed
        }
        var changed = false
        while step() {
            changed = true
        }
        return changed
    }
    
}


