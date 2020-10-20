//
//  Graph.swift
//  
//
//  Created by Steven Obua on 20/10/2020.
//

import Foundation

public struct Graph<Vertex : Hashable> : GrowableDirectedGraph {

    public struct Iterator : IteratorProtocol {
        
        public typealias Element = Vertex
        
        internal var internalIterator : Dictionary<Vertex, Set<Vertex>>.Keys.Iterator
        
        internal init(internalIterator : Dictionary<Vertex, Set<Vertex>>.Keys.Iterator) {
            self.internalIterator = internalIterator
        }
        
        public mutating func next() -> Vertex? {
            return internalIterator.next()
        }
    
    }
    
    private var _successors : [Vertex : Set<Vertex>]
    
    public func successors(of vertex: Vertex) -> Set<Vertex> {
        guard let succs = _successors[vertex] else { return [] }
        return succs
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(internalIterator: _successors.keys.makeIterator())
    }
    
    public init() {
        _successors = [:]
    }
    
    public var count : Int {
        return _successors.count
    }
    
    public mutating func insert<S>(_ vertices: S) -> Bool where S : Sequence, Self.Element == S.Element {
        var changed = false
        for v in vertices {
            if _successors[v] == nil {
                _successors[v] = []
                changed = true
            }
        }
        return changed
    }
    
    public mutating func connect<S>(from: Vertex, to: S) -> Bool where S : Sequence, Self.Element == S.Element {
        var changed = insert(to + [from])
        var succs = _successors[from]!
        let oldCount = succs.count
        succs.formUnion(to)
        if oldCount != succs.count { changed = true }
        _successors[from] = succs
        return changed
    }
    
}
