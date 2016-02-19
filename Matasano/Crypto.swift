//
//  Crypto.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

public enum Encryption {
    case RepeatingKeyXOR(key: String?)
}

extension String {
    
    func encrypt(encryption: Encryption) -> [UInt8] {
        
        func encryptWithRepeatingXOR(key: String?) -> [UInt8] {
            var k = RepeatingKey(key ?? "")
            return self.asciiToBytes.map { $0^k.next() }
        }
        
        switch encryption {
            case let .RepeatingKeyXOR(key: theKey):
                return encryptWithRepeatingXOR(theKey)
        }
    }

}

extension CollectionType
    where
        Generator.Element == UInt8,
        Index == Int,
        SubSequence.Generator.Element == UInt8
{    
    func decrypt(encryption: Encryption) -> String {
        
        func decryptWithRepeatingXOR(key: String?) -> String {
            guard key == nil else {
                var k = RepeatingKey(key!)
                return self.map { $0^k.next() }.asciiRepresentation
            }
            
            let keysize = self.probableKeysize()
            var decoded = [[UInt8]]()
            
            for block in self.blockify(keysize).transpose() {
                decoded.append(block.decryptHexBytes())
            }
            
            return decoded.transpose().flatMap { $0 }.asciiRepresentation
        }
        
        switch encryption {
        case let .RepeatingKeyXOR(key: theKey):
            return decryptWithRepeatingXOR(theKey)
        }
    }
    
}

func testCrypto() {
    
    let hobbes = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."
    let encrytped = hobbes.encrypt(Encryption.RepeatingKeyXOR(key: "Calvin")).base64Representation
    let decrypted = encrytped.base64ToBytes.decrypt(Encryption.RepeatingKeyXOR(key: "Calvin"))
    
    assert(decrypted == hobbes)
    
    let decryptedWithoutKey = encrytped.base64ToBytes.decrypt(Encryption.RepeatingKeyXOR(key: nil))
    assert(decryptedWithoutKey == hobbes)
    
    print("\(__FUNCTION__) passed")
    
}
