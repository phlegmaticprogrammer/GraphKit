//
//  Pair.swift
//  
//
//  Created by Steven Obua on 21/10/2020.
//

import Foundation

public struct Pair<First, Second> {
    
    public var first : First
    
    public var second : Second

    public init(_ first : First, _ second : Second) {
        self.first = first
        self.second = second
    }

}

extension Pair : Equatable where First : Equatable, Second : Equatable {}

extension Pair : Hashable where First : Hashable, Second : Hashable {}

extension Pair : Codable where First : Codable, Second : Codable {}
