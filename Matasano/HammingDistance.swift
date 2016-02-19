//
//  HammingDistance.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

let masks: [UInt8] = [0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000, 0b01000000, 0b10000000]
func hammingDistance(x: UInt8, _ y: UInt8) -> Int {
    // The hamming distance equals the number of ones in the
    // binary representation of the xor of the two bytes.
    // This implementation uncovers successive, corresponding
    // bits in `x` and `y` and xor's the two bits. If the 
    // result is larger than one, it is added to an array.
    // The count of the array is the hamming distance.
    return masks.map { $0&x ^ $0&y }.filter { $0 > 0 }.count
}

func hammingDistance(x: [UInt8], _ y: [UInt8]) -> Int {
    var distance = 0
    for (index, byte) in x.enumerate() {
        distance += hammingDistance(byte, y[index])
    }
    return distance
}

func hammingDistance(x: String, _ y: String) -> Int {
    return hammingDistance(x.asciiToBytes, y.asciiToBytes)
}

func testHammingDistance() {

    assert(hammingDistance(UInt8(0b1011101), UInt8(0b1001001)) == 2)
    let b1: [UInt8] = [0b1011101, 0b1001001]
    let b2: [UInt8] = [0b1001001, 0b1011101]
    assert(hammingDistance(b1, b2) == 4)
    assert(hammingDistance("this is a test", "wokka wokka!!!") == 37)
    
    print("\(__FUNCTION__) passed.")
}
