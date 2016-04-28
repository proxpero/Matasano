//
//  Extensions.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/11/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Swift
import Foundation

extension String {
    init(filename: String, encoding: UInt = NSUTF8StringEncoding) {
        let content = try! NSString(contentsOfFile: filename, encoding: encoding)
        self = content as String
    }
}

extension CollectionType
    where
        Generator.Element == UInt8,
        Index == Int
{
    /// xors `self` with each key from 0 to 255,
    /// and tests each result whether it resembles
    /// English. Returns the best candidate.
    ///
    /// Complexity: O(n^2)
    func decryptXORdHexBytes() -> [UInt8] {
        
        var bestScore = -Double.infinity
        var best: [UInt8] = []
        
        for candidate in singleKeyXorCandidates() {
            let score = candidate.plainTextScore
            if score > bestScore {
                bestScore = score
                best      = candidate
            }
        }
        
        return best
    }
    
    private func singleKeyXorCandidates() -> [[UInt8]] {
        
        var candidates: [[UInt8]] = []
        for key in 0x00...0xff {
            candidates.append(self.map { $0^UInt8(key) })
        }
        return candidates
    }

}

extension MutableCollectionType where Generator.Element == UInt8 {
    
    func padToBlockLength(length: Int? = nil) -> Array<Generator.Element> {
        
        var result = Array<Generator.Element>(self)
        let final: Int
        if length == nil {
            // if no length specified, then get the closest multiple of 16 above length.
            final = (result.count/16 + 1) * 16
        } else {
            final = length!
        }
        
        let pad = final - result.count
        for _ in 1...pad {
            result.append(UInt8(pad))
        }
        return result
    }
}

extension CollectionType
    where
        Generator.Element == Array<UInt8>
{
    /// Where `self` is a collection of 16-byte blocks,
    /// returns `true` iff any 16 byte block is repeated.
    var isAESEncrypted: Bool {

        var candidate = Array<Array<UInt8>>(self)
        while candidate.startIndex != candidate.endIndex {
            let b = candidate.removeFirst()
            if (candidate.filter { $0 == b }).count > 1 {
                return true
            }
        }
        return false
    }
}


extension CollectionType
    where
        Generator.Element: CollectionType,
        Index == Int,
        Generator.Element.Index == Int
{
    typealias T = Generator.Element.Generator.Element
    
    /// [Transposes](https://en.wikipedia.org/wiki/Transpose) an array of arrays.
    func transpose() -> [[T]] {
        if self.isEmpty { return [[T]]() }
        
        let count = self[startIndex].count
        var blocks = Array<[T]>(count: count, repeatedValue: [T]())
        
        for outer in self {
            for (index, inner) in outer.enumerate() {
                blocks[index].append(inner)
            }
        }
        
        return blocks
    }

}


func testTranspose() {
    
    let a1 = [[1, 2, 3, 4, 5],  [11, 12, 13, 14, 15], [21, 22, 23, 24, 25]]
    let a3 = [[1, 11, 21], [2, 12, 22], [3, 13, 23], [4, 14, 24], [5, 15, 25]]
    let a2 = a1.transpose()
    
    assert(a2 == a3)
    assert(a3.transpose() == a1)
    assert(a1.transpose().transpose() == a1)
    
    print("\(#function) passed.")
}


extension CollectionType
    where
        Index == Int,
        SubSequence.Generator.Element == Generator.Element
{
    func blockify(length: Int) -> [[Generator.Element]] {
        var blocks: [[Generator.Element]] = []
        
        for i in startIndex.stride(to: endIndex, by: length) {
            let end = i+length < endIndex ? i+length : endIndex
            blocks.append(Array(self[i..<end]))
        }
        return blocks
    }
    
    
    
    
}


extension UnicodeScalar: ForwardIndexType {
    
    public func successor() -> UnicodeScalar {
        return UnicodeScalar(value + 1)
    }
    
}


func testBlockify() {
    
    let a1 = Array<Int>(1...16)
    let result = Array<[Int]>(arrayLiteral: [1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16])
    let a2 = a1.blockify(4)
    
    assert(a2 == result)
    
    let b1 = ("A"..."L").map { String($0) }
    let b2 = [["A", "B", "C"], ["D", "E", "F"], ["G", "H", "I"], ["J", "K", "L"]]
    let b3 = [["A", "B", "C", "D", "E"], ["F", "G", "H", "I", "J"], ["K", "L"]]
    
    assert(b1.blockify(3) == b2)
    assert(b1.blockify(5) == b3)
    
    print("\(#function) passed.")
    
}

