//
//  PlainTextScore.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

/// The frequencies of letters in English text, from (http://norvig.com/mayzner.html). The key is the ascii code, the value is the frequency.
let frequencies: Dictionary<UInt8, Double> = [
     32:  17.0, // [space]
    101: 12.49,	// e
    116:  9.28,	// t
     97:  8.04,	// a
    111:  7.64,	// o
    105:  7.57,	// i
    110:  7.23,	// n
    115:  6.51,	// s
    114:  6.28,	// r
    104:  5.05,	// h
    108:  4.07,	// l
    100:  3.82,	// d
     99:  3.34,	// c
    117:  2.73,	// u
    109:  2.51,	// m
    102:  2.40,	// f
    112:  2.14,	// p
    103:  1.87,	// g
    119:  1.68,	// w
    121:  1.66,	// y
     98:  1.48,	// b
    118:  1.05,	// v
    107:  0.54,	// k
    120:  0.23,	// x
    106:  0.16,	// j
    113:  0.12,	// q
    122:  0.09,	// z
     44:  0.05, // ,
     46:  0.05, // .
     63:  0.05, // ?
]

extension CollectionType where Generator.Element == UInt8, Index == Int
{
    var plainTextScore: Double {
        var score = 0.0
        for code in self
        {
            let s: Double
            if let f = frequencies[code] { s = f * 100 }
            else                         { s = -500    }
            score += s
        }
        return score
    }
}

func testPlainTextScoring() {
    
    let plaintext = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."
    let encodingKey = UInt8(0xee)
    let cipher = plaintext.asciiToBytes^encodingKey
    
    let decrypted = cipher.decryptXORdHexBytes()
    let key = UInt8((0x00...0xff).filter { decrypted^UInt8($0) == cipher }.first!)
    
    assert(encodingKey == key)
    assert(decrypted.asciiRepresentation == plaintext)
    
    print("\(#function) passed.")
    
}