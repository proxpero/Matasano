//
//  Conversions.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation

private let base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".characters.map { String($0) }

extension String {
    
    /// returns an Unicode code point
    public var unicodeScalarCodePoint: UInt32 {
        let scalars = self.unicodeScalars
        return scalars[scalars.startIndex].value
    }
    
    /// converts a string of ascii text and
    /// returns an array of bytes
    /// - precondition: `self` is ascii text (0..<128)
    public var asciiToBytes: [UInt8] {
        return unicodeScalars.map { UInt8(ascii: $0) }
    }

    /// returns an array of bytes
    /// - precondition: `self` is hexadecimal text
    public var hexToBytes: [UInt8] {
        var items = lowercaseString.characters.map { String($0) }
        var bytes = [UInt8]()
        for i in items.startIndex.stride(to: items.endIndex, by: 2) {
            guard let byte = UInt8(items[i] + (i+1==items.endIndex ? "" : items[i+1]), radix: 16) else { fatalError() }
            bytes.append(byte)
        }
        return bytes
    }
    
    /// returns an array of bytes
    /// - precondition: `self` is base-64 text
    public var base64ToBytes: [UInt8] {
        return characters.map { String($0) }.filter { $0 != "=" }.map { UInt8(base64Chars.indexOf($0)!) }.sixbitArrayToBytes
    }
    
    public var asciiToBase64: String {
        return self.asciiToBytes.base64Representation
    }
    
    public var base64ToAscii: String {
        return self.base64ToBytes.asciiRepresentation
    }
    
    public var hexToBase64: String {
        return self.hexToBytes.base64Representation
    }
    
    public var base64ToHex: String {
        return self.hexToBytes.hexRepresentation
    }
    
}

extension CollectionType where Generator.Element == UInt8, Index == Int {
    
    /// return the ascii representation of `self`
    /// complexity: O(N)
    public var asciiRepresentation: String {
        guard let result = String(bytes: self, encoding: NSUTF8StringEncoding) else { fatalError() }
        return result
    }
    
    /// returns the hexidecimal representation of `self`
    /// complexity: O(N)
    public var hexRepresentation: String
    {
        var output = ""
        for byte in self {
            output += String(byte, radix: 16)
        }
        return output
    }
    
    /// returns the base64 representation of `self`
    /// complexity: O(N)
    public var base64Representation: String
    {
        var output = ""
        for sixbitInt in (self.bytesToSixbitArray.map { Int($0) }) {
            output += base64Chars[sixbitInt]
        }
        while output.characters.count % 4 != 0 { output += "=" }
        return output
    }

    ///
    private var bytesToSixbitArray: [UInt8] {
        
        var sixes = [UInt8]()

        for i in startIndex.stride(to: endIndex, by: 3) {
            
            sixes.append(self[i] >> 2)
            
            // if there are two missing characters, pad the result with '=='
            guard i+1 < endIndex else {
                sixes.appendContentsOf([(self[i] << 6) >> 2])
                return sixes
            }
            
            sixes.append((self[i] << 6) >> 2 | self[i+1] >> 4)

            // if there is one missing character, pad the result with '='
            guard i+2 < endIndex else {
                sixes.append((self[i+1] << 4) >> 2)
                return sixes
            }
            
            sixes.append((self[i+1] << 4) >> 2 | self[i+2] >> 6)
            sixes.append((self[i+2] << 2) >> 2)
        }
        
        return sixes
    }

    private var sixbitArrayToBytes: [UInt8] {
        var bytes: [UInt8] = []

        for i in startIndex.stride(to: endIndex, by: 4) {
            
            bytes.append(self[i+0]<<2 | self[i+1]>>4)
            
            guard i+2 < endIndex else {
//                bytes.append(self[i+1]<<4)
                return bytes
            }
            
            bytes.append(self[i+1]<<4 | self[i+2]>>2)
    
            guard i+3 < endIndex else {
//                bytes.append(self[i+2]<<6)
                return bytes
            }
            
            bytes.append(self[i+2]<<6 | self[i+3]>>0)
        }
        
        return bytes
    }
    
}

// MARK: TESTS
func testConversions() {
 
    let hobbes  = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."
    
    func testUnicodeScalarCodePoint()
    {
        assert(" ".unicodeScalarCodePoint == UInt32(32))    // lower bound
        assert("0".unicodeScalarCodePoint == UInt32(48))
        assert("C".unicodeScalarCodePoint == UInt32(67))
        assert("a".unicodeScalarCodePoint == UInt32(97))
        assert("t".unicodeScalarCodePoint == UInt32(116))
        assert("~".unicodeScalarCodePoint == UInt32(126))   // upper bound
        
        print("\(__FUNCTION__) passed.")
    }
    
    func testAsciiConversions()
    {
        let bytes   = [UInt8(77), UInt8(97), UInt8(110)]
        let text    = "Man"
        
        assert(text.asciiToBytes == bytes)
        assert(bytes.asciiRepresentation == text)
        assert(hobbes.asciiToBytes.asciiRepresentation == hobbes)
        
        print("\(__FUNCTION__) passed.")
    }
    
    func testHexConversions()
    {
        let text    = "deadbeef"
        assert(text.hexToBytes.hexRepresentation == text)
        
        let t1      = "f79"
        assert(t1.hexToBytes.hexRepresentation == t1)
        
        print("\(__FUNCTION__) passed.")
    }
    
    func testBase64Conversions()
    {
        let sixes: [UInt8] = [19, 22, 5, 46]
        let eights: [UInt8] = [77, 97, 110]
        
        assert(sixes.sixbitArrayToBytes == eights)
        assert(eights.bytesToSixbitArray == sixes)

        let t1 = "Man"
        let e1 = "TWFu"
        
        assert(t1.asciiToBytes.base64Representation == e1)
        assert(e1.base64ToBytes.asciiRepresentation == t1)
        assert(t1.asciiToBase64 == e1)
        assert(e1.base64ToAscii == t1)
        assert(t1.asciiToBytes == e1.base64ToBytes)
        
        let t2 = "any carnal pleasure."
        let e2 = "YW55IGNhcm5hbCBwbGVhc3VyZS4="
        
        assert(t2.asciiToBytes.base64Representation == e2)
        assert(e2.base64ToBytes.asciiRepresentation == t2)
        assert(t2.asciiToBase64 == e2)
        assert(e2.base64ToAscii == t2)
        assert(t2.asciiToBytes == e2.base64ToBytes)

        let t3 = "any carnal pleasure"
        let e3 = "YW55IGNhcm5hbCBwbGVhc3VyZQ=="
        
        assert(t3.asciiToBytes.base64Representation == e3)
        assert(e3.base64ToBytes.asciiRepresentation == t3)
        assert(t3.asciiToBase64 == e3)
        assert(e3.base64ToAscii == t3)
        assert(t3.asciiToBytes == e3.base64ToBytes)
        
        let t4 = "any carnal pleasur"
        let e4 = "YW55IGNhcm5hbCBwbGVhc3Vy"
        
        assert(t4.asciiToBytes.base64Representation == e4)
        assert(e4.base64ToBytes.asciiRepresentation == t4)
        assert(t4.asciiToBase64 == e4)
        assert(e4.base64ToAscii == t4)
        assert(t4.asciiToBytes == e4.base64ToBytes)
        
        let t5 = "any carnal pleasu"
        let e5 = "YW55IGNhcm5hbCBwbGVhc3U="
        
        assert(t5.asciiToBytes.base64Representation == e5)
        assert(e5.base64ToBytes.asciiRepresentation == t5)
        assert(t5.asciiToBase64 == e5)
        assert(e5.base64ToAscii == t5)
        assert(t5.asciiToBytes == e5.base64ToBytes)
        
        let t6 = "any carnal pleas"
        let e6 = "YW55IGNhcm5hbCBwbGVhcw=="
        
        assert(t6.asciiToBytes.base64Representation == e6)
        assert(e6.base64ToBytes.asciiRepresentation == t6)
        assert(t6.asciiToBase64 == e6)
        assert(e6.base64ToAscii == t6)
        assert(t6.asciiToBytes == e6.base64ToBytes)
        
        let t7 = "pleasure."
        let e7 = "cGxlYXN1cmUu"

        assert(t7.asciiToBytes.base64Representation == e7)
        assert(e7.base64ToBytes.asciiRepresentation == t7)
        assert(t7.asciiToBase64 == e7)
        assert(e7.base64ToAscii == t7)
        assert(t7.asciiToBytes == e7.base64ToBytes)
        
        let t8 = "leasure."
        let e8 = "bGVhc3VyZS4="
        
        assert(t8.asciiToBytes.base64Representation == e8)
        assert(e8.base64ToBytes.asciiRepresentation == t8)
        assert(t8.asciiToBase64 == e8)
        assert(e8.base64ToAscii == t8)
        assert(t8.asciiToBytes == e8.base64ToBytes)
        
        let t9 = "easure."
        let e9 = "ZWFzdXJlLg=="
        
        assert(t9.asciiToBytes.base64Representation == e9)
        assert(e9.base64ToBytes.asciiRepresentation == t9)
        assert(t9.asciiToBase64 == e9)
        assert(e9.base64ToAscii == t9)
        assert(t9.asciiToBytes == e9.base64ToBytes)
        
        let t10 = "asure."
        let e10 = "YXN1cmUu"
        
        assert(t10.asciiToBytes.base64Representation == e10)
        assert(e10.base64ToBytes.asciiRepresentation == t10)
        assert(t10.asciiToBase64 == e10)
        assert(e10.base64ToAscii == t10)
        assert(t10.asciiToBytes == e10.base64ToBytes)
        
        let t11 = "sure."
        let e11 = "c3VyZS4="

        assert(t11.asciiToBytes.base64Representation == e11)
        assert(e11.base64ToBytes.asciiRepresentation == t11)
        assert(t11.asciiToBase64 == e11)
        assert(e11.base64ToAscii == t11)
        assert(t11.asciiToBytes == e11.base64ToBytes)

        let encoded = "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="

        assert(hobbes.asciiToBytes.base64Representation == encoded)
        assert(hobbes.asciiToBase64 == encoded)

        let input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
        let output = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
        
        assert(input.hexToBytes.base64Representation == output)
        assert(input.hexToBase64 == output)
        
        print("\(__FUNCTION__) passed.")
    }

    testUnicodeScalarCodePoint()
    testAsciiConversions()
    testHexConversions()
    testBase64Conversions()
    
    print("\(__FUNCTION__) passed.")
    
}

