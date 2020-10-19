//
//  Heap.swift
//  
//
//  Created by Steven Obua on 18/10/2020.
//

import Foundation

public struct Heap<T, H : Hashable> {
  
    /** The array that stores the heap's nodes. */
    private var nodes = [T]()
    
    private var handles : [H : Int] = [:]

    /**
    * Determines how to compare two nodes in the heap.
    * Use '>' for a max-heap or '<' for a min-heap,
    * or provide a comparing method if the heap is made
    * of custom elements, for example tuples.
    */
    private var orderCriteria: (T, T) -> Bool

    private var handleOf: (T) -> H
    
    /**
    * Creates an empty heap.
    * The sort function determines whether this is a min-heap or max-heap.
    * For comparable data types, > makes a max-heap, < makes a min-heap.
    */
    public init(sort: @escaping (T, T) -> Bool, handle : @escaping (T) -> H) {
        self.orderCriteria = sort
        self.handleOf = handle
    }

    /**
    * Creates a heap from an array. The order of the array does not matter;
    * the elements are inserted into the heap in the order determined by the
    * sort function. For comparable data types, '>' makes a max-heap,
    * '<' makes a min-heap.
    */
    public init(array: [T], sort: @escaping (T, T) -> Bool, handle : @escaping (T) -> H) {
        self.orderCriteria = sort
        self.handleOf = handle
        configureHeap(from: array)
    }

    /**
    * Configures the max-heap or min-heap from an array, in a bottom-up manner.
    * Performance: This runs pretty much in O(n).
    */
    private mutating func configureHeap(from array: [T]) {
        nodes = array
        for (i, node) in array.enumerated() {
            handles[handleOf(node)] = i
        }
        for i in stride(from: (nodes.count/2-1), through: 0, by: -1) {
          shiftDown(i)
        }
    }

    public var isEmpty: Bool {
        return nodes.isEmpty
    }

    public var count: Int {
        return nodes.count
    }

    /**
    * Returns the index of the parent of the element at index i.
    * The element at index 0 is the root of the tree and has no parent.
    */
    private func parentIndex(ofIndex i: Int) -> Int {
        return (i - 1) / 2
    }

    /**
    * Returns the index of the left child of the element at index i.
    * Note that this index can be greater than the heap size, in which case
    * there is no left child.
    */
    private func leftChildIndex(ofIndex i: Int) -> Int {
        return 2*i + 1
    }

    /**
    * Returns the index of the right child of the element at index i.
    * Note that this index can be greater than the heap size, in which case
    * there is no right child.
    */
    private func rightChildIndex(ofIndex i: Int) -> Int {
        return 2*i + 2
    }

    /**
    * Returns the maximum value in the heap (for a max-heap) or the minimum
    * value (for a min-heap).
    */
    public func peek() -> T? {
        return nodes.first
    }

    /**
    * Adds a new value to the heap. This reorders the heap so that the max-heap
    * or min-heap property still holds. Performance: O(log n).
    */
    public mutating func insert(_ value: T) {
        let h = handleOf(value)
        guard handles.updateValue(nodes.count, forKey: h) == nil else {
            fatalError("Heap already contains an element with handle \(h).")
        }
        nodes.append(value)
        shiftUp(nodes.count - 1)
    }

    /**
    * Adds a sequence of values to the heap. This reorders the heap so that
    * the max-heap or min-heap property still holds. Performance: O(|S| log n).
    */
    public mutating func insert<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        for value in sequence {
          insert(value)
        }
    }

    /**
    * Allows you to change an element. This reorders the heap so that
    * the max-heap or min-heap property still holds.
    */
    private mutating func replace(index i: Int, value: T) -> T {
        let previous = remove(at: i)
        insert(value)
        return previous
    }
    
    @discardableResult public mutating func replace(_ value : T) -> T? {
        if let index = handles[handleOf(value)] {
            return replace(index: index, value : value)
        } else {
            insert(value)
            return nil
        }
    }

    /**
    * Removes the root node from the heap. For a max-heap, this is the maximum
    * value; for a min-heap it is the minimum value. Performance: O(log n).
    */
    @discardableResult public mutating func remove() -> T? {
        guard !nodes.isEmpty else { return nil }
        if nodes.count == 1 {
            handles = [:]
            return nodes.removeLast()
        } else {
            // Use the last node to replace the first one, then fix the heap by
            // shifting this new first node into its proper position.
            let value = nodes[0]
            handles[handleOf(value)] = nil
            nodes[0] = nodes.removeLast()
            handles[handleOf(nodes[0])] = 0
            shiftDown(0)
            return value
        }
    }
    
    private mutating func swap(_ i : Int, _ j : Int) {
        let h_i = handleOf(nodes[i])
        let h_j = handleOf(nodes[j])
        handles[h_i] = j
        handles[h_j] = i
        nodes.swapAt(i, j)
    }

    /**
    * Removes an arbitrary node from the heap. Performance: O(log n).
    * Note that you need to know the node's index.
    */
    private mutating func remove(at index: Int) -> T {
        let size = nodes.count - 1
        if index != size {
            swap(index, size)
            shiftDown(from: index, until: size)
            shiftUp(index)
        }
        let n = nodes.removeLast()
        handles[handleOf(n)] = nil
        return n
    }

    /**
    * Takes a child node and looks at its parents; if a parent is not larger
    * (max-heap) or not smaller (min-heap) than the child, we exchange them.
    */
    private mutating func shiftUp(_ index: Int) {
        var childIndex = index
        let child = nodes[childIndex]
        var parentIndex = self.parentIndex(ofIndex: childIndex)

        while childIndex > 0 && orderCriteria(child, nodes[parentIndex]) {
            let parent = nodes[parentIndex]
            nodes[childIndex] = parent
            handles[handleOf(parent)] = childIndex
            childIndex = parentIndex
            parentIndex = self.parentIndex(ofIndex: childIndex)
        }

        nodes[childIndex] = child
        handles[handleOf(child)] = childIndex
    }

    /**
    * Looks at a parent node and makes sure it is still larger (max-heap) or
    * smaller (min-heap) than its childeren.
    */
    private mutating func shiftDown(from index: Int, until endIndex: Int) {
        let leftChildIndex = self.leftChildIndex(ofIndex: index)
        let rightChildIndex = leftChildIndex + 1

        // Figure out which comes first if we order them by the sort function:
        // the parent, the left child, or the right child. If the parent comes
        // first, we're done. If not, that element is out-of-place and we make
        // it "float down" the tree until the heap property is restored.
        var first = index
        if leftChildIndex < endIndex && orderCriteria(nodes[leftChildIndex], nodes[first]) {
          first = leftChildIndex
        }
        if rightChildIndex < endIndex && orderCriteria(nodes[rightChildIndex], nodes[first]) {
          first = rightChildIndex
        }
        if first == index { return }

        swap(index, first)
        shiftDown(from: first, until: endIndex)
    }

    private mutating func shiftDown(_ index: Int) {
        shiftDown(from: index, until: nodes.count)
    }

}

