//
//  XOR.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation

/// Produces the xor combination of `lhs` and `rhs`
/// - Precondition: the lengths of two arrays must be equal
func ^ (lhs: [UInt8], rhs: [UInt8]) -> [UInt8] {
    guard lhs.count == rhs.count else { fatalError() }
    var result: [UInt8] = []
    for (index, byte) in lhs.enumerate() {
        result.append(byte ^ rhs[index])
    }
    return result
}

/// Successively perform bitwise xor on each element in
/// `lhs` using `rhs`.
func ^ (lhs: [UInt8], rhs: UInt8) -> [UInt8] {
    var result: [UInt8] = []
    for byte in lhs {
        result.append(byte^rhs)
    }
    return result
}

func testXorInfixes() {
    
    let b1 = "1c0111001f010100061a024b53535009181c".hexToBytes
    let b2 = "686974207468652062756c6c277320657965".hexToBytes
    let r  = "746865206b696420646f6e277420706c6179".hexToBytes
    
    assert(b1 ^ b2 == r)
    
    let key = UInt8(0xb)
    let encoded = b1^key
    let decoded = encoded^key
    
    assert(b1 == decoded)
    
    print("\(__FUNCTION__) passed.")
    
}

