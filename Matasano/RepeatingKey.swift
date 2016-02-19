//
//  RepeatingKey.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

struct RepeatingKey {
    let key: String
    private let keys: [UInt8]
    private var index: Int = 0
    
    init(_ key: String) {
        self.key = key
        keys = key.asciiToBytes
    }
    
    mutating func next() -> UInt8 {
        defer {
            index += 1
            if index == self.keys.count { index = 0 }
        }
        return keys[index]
    }
}

func testRepeatingKey() {
    
    let p1 = "Hello"
    var k1 = RepeatingKey(p1)
    
    var keys: [UInt8] = []
    for _ in (1...16) {
        keys.append(k1.next())
    }
    
    assert(keys.map { String(UnicodeScalar($0)) } == ["H", "e", "l", "l", "o", "H", "e", "l", "l", "o", "H", "e", "l", "l", "o", "H"])
    
    let verses = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
    let p2     = "ICE"
    let result = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
    
    var k2 = RepeatingKey(p2)
    let encrypted = verses.asciiToBytes.map { $0^k2.next() }
    
    assert(encrypted == result.hexToBytes)
    
    var k3 = RepeatingKey(p2)
    let decrypted = encrypted.map { $0^k3.next() }
    
    assert(decrypted.asciiRepresentation == verses)
    
    print("\(__FUNCTION__) passed.")
    
}

