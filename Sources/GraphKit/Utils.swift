//
//  Utils.swift
//  
//
//  Created by Steven Obua on 21/10/2020.
//

import Foundation

public func collect<S : Sequence, T : Sequence>(_ seq : S, _ family : (S.Element) -> T) -> Set<T.Element> {
    var result : Set<T.Element> = []
    for s in seq {
        result.formUnion(family(s))
    }
    return result
}
