//
//  ProbableKeySize.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

extension CollectionType
    where
    Generator.Element == UInt8,
    Index == Int,
    SubSequence.Generator.Element == UInt8
{
    /// returns the probable keysize
    func probableKeysize() -> Int {
        
        var smallestDistance    = Double.infinity
        var probableKeysize     = 0
        
        for keysize in (2...40) {
            guard self.count > 2*keysize else { break }
            
            var acc: [Int] = []
            for i in startIndex.stride(to: endIndex, by: 2*keysize) {
                guard 2*(i+keysize) < endIndex else { break }
                let first   = Array(self[i..<(i+keysize)])
                let second  = Array(self[(i+keysize)..<2*(i+keysize)])
                acc.append(hammingDistance(first, second)/keysize)
            }
            
            let avg = Double(acc.reduce(0) { $0 + $1 })/Double(acc.count)
            if avg < smallestDistance {
                smallestDistance = avg
                probableKeysize  = keysize
            }
        }
        return probableKeysize
    }
}
