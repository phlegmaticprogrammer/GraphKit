//
//  Graph.swift
//  
//
//  Created by Steven Obua on 18/10/2020.
//

import Foundation

/**
  Implements a directed graph.
 */
public struct Graph<T> {
    
    public typealias NodeIndex = Int
    
    private struct Node {
        var element : T
        var successors : Set<NodeIndex>
    }
    
    private var nodes : [Node]
    
    public init() {
        nodes = []
    }
    
    private init(nodes : [Node]) {
        self.nodes = nodes
    }
        
    public mutating func add(_ element : T) -> NodeIndex {
        let node = Node(element: element, successors: [])
        let index = nodes.count
        nodes.append(node)
        return index
    }
    
    public mutating func connect(from : NodeIndex, to : NodeIndex) {
        nodes[from].successors.insert(to)
    }
    
    public mutating func connect(_ node1 : NodeIndex, _ node2 : NodeIndex) {
        connect(from: node1, to: node2)
        connect(from: node2, to: node1)
    }
        
    public func successors(of node : NodeIndex) -> Set<NodeIndex> {
        return nodes[node].successors
    }
    
    public subscript(_ node : NodeIndex) -> T {
        return nodes[node].element
    }
        
    public func nodeIndices() -> [NodeIndex] {
        return Array(0 ..< nodes.count)
    }
    
    public var nodeCount : Int {
        return nodes.count
    }
        
    public func averageAndMaxNumberOfNeighbours() -> (average: Float, max: Int) {
        var m : Int = 0
        var sum : Int = 0
        for node in nodes {
            let count = node.successors.count
            sum += count
            m = max(m, count)
        }
        if sum == 0 {
            return (average: 0, max: 0)
        } else {
            return (average: Float(sum)/Float(nodes.count), max: m)
        }
    }
        
    public func breadthFirstSearchTree(start : Set<NodeIndex>) -> (graph: Graph<(depth : Int, node : NodeIndex)>, relabel : [NodeIndex?]) {
        var state : [(depth: Int, parent: NodeIndex)?] = Array(repeating: nil, count: nodes.count)
        for s in start { state[s] = (0, s) }
        var current : Set<NodeIndex> = start
        var currentDepth = 1
        var next : Set<NodeIndex> = []
        while !current.isEmpty {
            for node in current {
                for successor in successors(of: node) {
                    if state[successor] == nil {
                        state[successor] = (depth: currentDepth, parent: node)
                        next.insert(successor)
                    }
                }
            }
            currentDepth += 1
            current = next
            next = []
        }
        var relabel : [NodeIndex?] = Array(repeating: nil, count: nodes.count)
        var tree = Graph<(depth : Int, node : NodeIndex)>()
        for (index, s) in state.enumerated() {
            guard let s = s else { continue }
            let newNodeIndex = tree.add((depth: s.depth, node: index))
            relabel[index] = newNodeIndex
        }
        for (index, s) in state.enumerated() {
            guard let s = s else { continue }
            let from = relabel[index]!
            let to = relabel[s.parent]!
            if from != to {
                tree.connect(from: from, to: to)
            }
        }
        return (graph: tree, relabel: relabel)
    }
    
    public func shortestPathTree(start : [NodeIndex], distance : (NodeIndex, NodeIndex) -> Float) -> (graph: Graph<(distance : Float, node : NodeIndex)>, relabel : [NodeIndex?]) {
        var state : [(distance: Float, parent: NodeIndex)?] = Array(repeating: nil, count: nodes.count)
        for s in start {
            state[s] = (distance: 0, parent: s)
        }
        typealias Value = (distance: Float, node: NodeIndex)
        let initialHeap : [Value] = start.map { n in (distance: 0, node: n) }
        func sort(x : Value, y : Value) -> Bool {
            return x.distance < y.distance
        }
        func handleOf(x : Value) -> NodeIndex {
            return x.node
        }
        var unscanned : Heap<Value, NodeIndex> = Heap(array: initialHeap, sort: sort, handle: handleOf)
        while let m = unscanned.remove() {
            for s in successors(of: m.node) {
                let delta = distance(m.node, s)
                if delta < Float.infinity && (state[s] == nil || m.distance + delta < state[s]!.distance) {
                    state[s] = (distance: m.distance + delta, parent: m.node)
                    unscanned.replace((distance: m.distance + delta, node: s))
                }
            }
        }
        var relabel : [NodeIndex?] = Array(repeating: nil, count: nodes.count)
        var tree = Graph<(distance : Float, node : NodeIndex)>()
        for (index, s) in state.enumerated() {
            guard let s = s else { continue }
            let newNodeIndex = tree.add((distance: s.distance, node: index))
            relabel[index] = newNodeIndex
        }
        for (index, s) in state.enumerated() {
            guard let s = s else { continue }
            let from = relabel[index]!
            let to = relabel[s.parent]!
            if from != to {
                tree.connect(from: from, to: to)
            }
        }
        return (graph: tree, relabel: relabel)
    }
    
    public func findShortestPath(from : NodeIndex, to : NodeIndex, maxDepth : Int? = nil) -> [NodeIndex]? {
        let bfs = breadthFirstSearchTree(start: [from])
        guard let target = bfs.relabel[to] else { return nil }
        let tree = bfs.graph
        if let maxDepth = maxDepth {
            guard tree[target].depth <= maxDepth else { return nil }
        }
        let path = tree.tracePathWhileUnique(from: target)
        return path.reversed().map { treeNodeIndex in tree[treeNodeIndex].node }
    }
    
    public func findShortestPath(from : NodeIndex, to : NodeIndex, distance : (NodeIndex, NodeIndex) -> Float, maxDistance : Float? = nil) -> [NodeIndex]? {
        let tree = shortestPathTree(start: [from], distance: distance)
        guard let target = tree.relabel[to] else { return nil }
        if let maxDistance = maxDistance {
            guard tree.graph[target].distance <= maxDistance else { return nil }
        }
        let path = tree.graph.tracePathWhileUnique(from: target)
        return path.reversed().map { treeNodeIndex in tree.graph[treeNodeIndex].node }
    }
    
    public func findFarthest(from : NodeIndex) -> NodeIndex {
        let bfsTree = breadthFirstSearchTree(start: [from]).graph
        let maxDepth = (bfsTree.findMax { s in s.depth })!
        return bfsTree[maxDepth.node].node
    }
    
    public func findFarthestPathReversed(from : NodeIndex) -> [NodeIndex] {
        let bfsTree = breadthFirstSearchTree(start: [from]).graph
        let maxDepth = (bfsTree.findMax { s in s.depth })!
        let path = bfsTree.tracePathWhileUnique(from: maxDepth.node)
        let originalPath = path.map { index in bfsTree[index].node }
        return originalPath
    }
    
    public func approximateDiameter(nodeInComponent : NodeIndex) -> [NodeIndex] {
        return findFarthestPathReversed(from: findFarthest(from: nodeInComponent))
    }
        
    public func findApproximateLoop(startingNode : NodeIndex, distance dist : (NodeIndex, NodeIndex) -> Float) -> (success: [NodeIndex]?, failure: [NodeIndex]?) {
        let tree = shortestPathTree(start: [startingNode], distance: dist).graph
        let maxDist = tree.findMax { s in s.distance }!
        var path = tree.tracePathWhileUnique(from: maxDist.node).map { n in tree[n].node }
        let allowance = path.count / 20
        path.removeFirst(allowance)
        path.removeLast(allowance)
        let halfLoop1 = path.map { n in tree[n].node }
        let radius = allowance
        path.removeFirst(2*radius)
        path.removeLast(2*radius)
        let bfs = breadthFirstSearchTree(start: Set(path.map { n in tree[n].node }))
        var nodesToAvoid : Set<NodeIndex> = []
        for i in bfs.graph.nodeIndices() {
            let e = bfs.graph[i]
            if e.depth <= radius {
                nodesToAvoid.insert(e.node)
            }
        }
        func dist2(x : NodeIndex, y : NodeIndex) -> Float {
            if nodesToAvoid.contains(x) || nodesToAvoid.contains(y) { return Float.infinity } else { return dist(x, y) }
        }
        if let halfLoop2 = findShortestPath(from: halfLoop1.last!, to: halfLoop1.first!, distance: dist2) {
            var loop = halfLoop1
            loop.removeFirst()
            loop.removeLast()
            loop.append(contentsOf: halfLoop2)
            return (loop.reversed(), nil)
        } else {
            return (nil, halfLoop1.reversed())
        }
    }
    
    public func findApproximateLoop(distance : (NodeIndex, NodeIndex) -> Float) -> (success: [NodeIndex]?, failure: [NodeIndex]?) {
        if nodeCount < 2 { return (nil, nil) }
        return findApproximateLoop(startingNode: 0, distance: distance)
    }

    public func filter(keepNodes : [NodeIndex]) -> (graph: Graph, relabel : [NodeIndex?]) {
        var relabel : [NodeIndex?] = Array(repeating: nil, count: nodes.count)
        func relabelSuccessors(_ successors : Set<NodeIndex>) -> Set<NodeIndex> {
            var relabeled : Set<NodeIndex> = []
            for successor in successors {
                if let relabeledSuccessor = relabel[successor] {
                    relabeled.insert(relabeledSuccessor)
                }
            }
            return relabeled
        }
        var newNodes : [Node] = []
        for oldNodeIndex in keepNodes {
            let oldNode = nodes[oldNodeIndex]
            let newNodeIndex = newNodes.count
            let newNode = Node(element: oldNode.element, successors: [])
            newNodes.append(newNode)
            relabel[oldNodeIndex] = newNodeIndex
        }
        for oldNodeIndex in keepNodes {
            guard let newNodeIndex = relabel[oldNodeIndex] else { continue }
            newNodes[newNodeIndex].successors = relabelSuccessors(nodes[oldNodeIndex].successors)
        }
        return (graph: Graph(nodes: newNodes), relabel: relabel)
    }
    
    public func filter(removeNodes : [NodeIndex]) -> (graph: Graph, relabel : [NodeIndex?]) {
        let keepNodes = Set(nodeIndices()).subtracting(removeNodes)
        return filter(keepNodes: Array(keepNodes))
    }
        
    public func findMax<Value : Comparable>(valueOf : (T) -> Value) -> (node : NodeIndex, value : Value)? {
        var maxValue : Value? = nil
        var maxNode : NodeIndex? = nil
        for (nodeIndex, node) in nodes.enumerated() {
            let value = valueOf(node.element)
            if let currentMaxValue = maxValue {
                if value > currentMaxValue {
                    maxValue = value
                    maxNode = nodeIndex
                }
            } else {
                maxValue = value
                maxNode = nodeIndex
            }
        }
        return maxNode != nil ? (node: maxNode!, value: maxValue!) : nil
    }

    public func findMin<Value : Comparable>(valueOf : (T) -> Value) -> (node : NodeIndex, value : Value)? {
        var minValue : Value? = nil
        var minNode : NodeIndex? = nil
        for (nodeIndex, node) in nodes.enumerated() {
            let value = valueOf(node.element)
            if let currentMinValue = minValue {
                if value < currentMinValue {
                    minValue = value
                    minNode = nodeIndex
                }
            } else {
                minValue = value
                minNode = nodeIndex
            }
        }
        return minNode != nil ? (node: minNode!, value: minValue!) : nil
    }
    
    public func tracePathWhileUnique(from: NodeIndex) -> [NodeIndex] {
        var alreadyVisited : Set<NodeIndex> = Set()
        var path = [from]
        while true {
            let current = path.last!
            let node = nodes[current]
            switch node.successors.count {
            case 0: return path
            case 1:
                let successor = node.successors.first!
                guard alreadyVisited.insert(successor).inserted else { return path }
                path.append(successor)
            default: return path
            }
        }
    }
    
    public func reverseEdges() -> Graph {
        var reversed = Graph(nodes: nodes.map {node in Node(element: node.element, successors: [])})
        for (from, node) in nodes.enumerated() {
            for to in node.successors {
                reversed.connect(from: to, to: from)
            }
        }
        return reversed
    }
    
    public func closure(_ kernel : [NodeIndex]) -> Set<NodeIndex> {
        var hull = Set(kernel)
        var processing = kernel
        while !processing.isEmpty {
            for successor in nodes[processing.removeLast()].successors {
                if hull.insert(successor).inserted {
                    processing.append(successor)
                }
            }
        }
        return hull
    }

    public func reachable(_ kernel : [NodeIndex]) -> Set<NodeIndex> {
        var hull : Set<NodeIndex> = []
        var processing = kernel
        while !processing.isEmpty {
            for successor in nodes[processing.removeLast()].successors {
                if hull.insert(successor).inserted {
                    processing.append(successor)
                }
            }
        }
        return hull
    }

    public func symmetricClosure() -> Graph<T> {
        var sym = self
        for i in nodeIndices() {
            for j in successors(of: i) {
                sym.connect(from: j, to: i)
            }
        }
        return sym
    }
    
    public func weaklyConnectedComponents() -> [Set<NodeIndex>] {
        let graph = symmetricClosure()
        let nCount = nodeCount
        var visited : [Bool] = Array(repeating: false, count: nCount)
        var components : [Set<NodeIndex>] = []
        for node in 0 ..< nCount {
            guard !visited[node] else { continue }
            let component = graph.closure([node])
            for v in component { visited[v] = true }
            components.append(component)
        }
        return components
    }

}

extension Graph where T : Hashable {
        
    public func indexOf(_ elem : T) -> NodeIndex? {
        var i = 0
        while i < nodes.count {
            if nodes[i].element == elem { return i }
            i += 1
        }
        return nil
    }
    
    public mutating func ensureVertex(_ elem : T) -> NodeIndex {
        if let index = indexOf(elem) {
            return index
        } else {
            return add(elem)
        }
    }
    
    public mutating func connect(from : T, to : T) {
        let fromIndex = ensureVertex(from)
        let toIndex = ensureVertex(to)
        connect(from: fromIndex, to: toIndex)
    }
    
    public mutating func connect(_ node1 : T, _ node2 : T) {
        let fromIndex = ensureVertex(node1)
        let toIndex = ensureVertex(node2)
        connect(fromIndex, toIndex)
    }
        
    public subscript(_ elements : Set<NodeIndex>) -> Set<T> {
        Set(elements.map { i in self[i] })
    }
        
}
