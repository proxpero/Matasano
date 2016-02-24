//
//  Crypto.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

public enum Encryption {
    case RepeatingKeyXOR(key: String?)
    case AES_128_ECB(key: String?)
}

extension String {
    
    func encrypt(encryption: Encryption) -> [UInt8] {
        
        func encryptWithRepeatingXOR(key: String?) -> [UInt8] {
            var k = RepeatingKey(key ?? "")
            return self.asciiToBytes.map { $0^k.next() }
        }
        
        func encryptWithAES_128_ECB(userKey: String?) -> [UInt8] {
            
            // Fixes a linker error caused by an OpenSSL bug with x64 static libraries
            // http://stackoverflow.com/a/28947978/277905
            OPENSSL_cleanse(nil, 0)
            
            var bytes = asciiToBytes
            
            var aesKey = AES_KEY()
            AES_set_encrypt_key(userKey ?? "", 128, &aesKey)
            var result = Array<UInt8>(count: bytes.count, repeatedValue: 0)
            
            for index in bytes.startIndex.stride(to: bytes.endIndex, by: 16) {
                AES_ecb_encrypt(&bytes + index, &result[index], &aesKey, AES_ENCRYPT)
            }
            
            return result
        }
        
        switch encryption {
            case let .RepeatingKeyXOR(key: key):
                return encryptWithRepeatingXOR(key)
            case let .AES_128_ECB(key: key):
                return encryptWithAES_128_ECB(key)
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
                decoded.append(block.decryptXORdHexBytes())
            }
            
            return decoded.transpose().flatMap { $0 }.asciiRepresentation
        }
        
        func decryptWithAES_128_ECB(key: String?) -> String {
            guard let userKey = key else { fatalError("decrypting AES_128_ECB without key is not supported. \(__FUNCTION__)") }
            
            // Fixes a linker error caused by an OpenSSL bug with x64 static libraries
            // http://stackoverflow.com/a/28947978/277905
            OPENSSL_cleanse(nil, 0)
            
            var bytes = Array<UInt8>(self)
            while bytes.count % 16 != 0 {
                bytes.append(0)
            }
            
            var aesKey = AES_KEY()
            AES_set_decrypt_key(userKey, 128, &aesKey)
            var result = Array<UInt8>(count: self.count, repeatedValue: 0)
            
            for index in bytes.startIndex.stride(to: bytes.endIndex, by: 16) {
                AES_ecb_encrypt(&bytes + index, &result[index], &aesKey, AES_DECRYPT)
            }
            
            return result.asciiRepresentation
        }
        
        switch encryption {
        case let .RepeatingKeyXOR(key: key):
            return decryptWithRepeatingXOR(key)
        case let .AES_128_ECB(key: key):
            return decryptWithAES_128_ECB(key)
        }
    }
    
}

func testCrypto() {
    
    print("Begin \(__FUNCTION__)")
    
    let hobbes = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."
    let key    = "Calvin"
    
    func testRepeatingKeyXOR() {

        let encrypted = hobbes.encrypt(Encryption.RepeatingKeyXOR(key: key)).base64Representation
        let decrypted = encrypted.base64ToBytes.decrypt(Encryption.RepeatingKeyXOR(key: key))
        
        assert(decrypted == hobbes)
        
        let decryptedWithoutKey = encrypted.base64ToBytes.decrypt(Encryption.RepeatingKeyXOR(key: nil))
        assert(decryptedWithoutKey == hobbes)
        
        print("\(__FUNCTION__) passed.")
        
    }
    
    func testAES_128_ECB() {
        
        let encrypted = hobbes.encrypt(Encryption.AES_128_ECB(key: key))
        print(encrypted)
        let decrypted = encrypted.decrypt(Encryption.AES_128_ECB(key: key))
        
        print(encrypted)
        print(decrypted)
        
        assert(decrypted == hobbes)
        
    }
    
    testRepeatingKeyXOR()
//    testAES_128_ECB()
    
    print("\(__FUNCTION__) passed.")
    
}

func testOpenSSL() {
    
}