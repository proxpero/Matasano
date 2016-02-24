//
//  Tests.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/12/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation

func testLibrary() {

    print("Begin \(__FUNCTION__).")
    testConversions()
    testTranspose()
    testXorInfixes()
    testPlainTextScoring()
    testRepeatingKey()
    testHammingDistance()
    testBlockify()
    testCrypto()
    print("\(__FUNCTION__) passed.\n")
}

func testSets() {
    
    func testSet1() {
        
        // MARK: Challenge 1
        //
        
        func testChallenge1() {
            
            let input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
            let output = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
            assert(input.hexToBase64 == output)
            
            print("\(__FUNCTION__) passed.")
            
        }
        
        
        // MARK: Challenge 2
        // Fixed XOR
        // Write a function that takes two equal-length buffers and produces their XOR combination.
        
        func testChallenge2() {
            
            let b1 = "1c0111001f010100061a024b53535009181c".hexToBytes
            let b2 = "686974207468652062756c6c277320657965".hexToBytes
            let r  = "746865206b696420646f6e277420706c6179".hexToBytes
            
            assert(b1 ^ b2 == r)
            
            print("\(__FUNCTION__) passed.")
            
        }
        
        
        // MARK: Challenge 3
        // Single-byte XOR cipher
        // The hex encoded string: 1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736
        // has been XOR'd against a single character. Find the key, decrypt the message.
        
        func testChallenge3() {
            
            let challengeCipher = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736".hexToBytes
            let decryptedChallenge = challengeCipher.decryptXORdHexBytes()
            let challengeKey = UInt8((0x00...0xff).filter { decryptedChallenge^UInt8($0) == challengeCipher }.first!)
            
            print("\(__FUNCTION__) passed with result:\n\n\(decryptedChallenge.asciiRepresentation), key: \(challengeKey)")
            
        }
        
        
        // MARK: Challenge 4
        // Detect single-character XOR
        // One of the 60-character strings in this file has been encrypted by single-character XOR.
        // Find it.
        
        func testChallenge4() {

            let haystack: [[UInt8]] = String(filename: "4.txt").componentsSeparatedByString("\n").map { $0.hexToBytes }
            
            var best = [UInt8]()
            var highScore = 0.0
            var candidates: [[UInt8]] = []
            
            for c in haystack {
                for key in 0x00...0xff {
                    candidates.append(c.map { $0^UInt8(key) })
                }
            }
            
            for candidate in candidates {
                let score = candidate.plainTextScore
                if score > highScore {
                    highScore = score
                    best      = candidate
                }
            }
            
            print("\(__FUNCTION__) passed with result:\n\n\(best.asciiRepresentation)")
        }
        
        
        // MARK: Challenge 5
        // Implement repeating-key XOR
        
        func testChallenge5() {
            
            let verses = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
            let p2     = "ICE"
            let result = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
            
            var k2 = RepeatingKey(p2)
            let encrypted = verses.asciiToBytes.map { $0^k2.next() }
            
            assert(encrypted == result.hexToBytes)
            
            var k3 = RepeatingKey(p2)
            let decrypted = encrypted.map { $0^k3.next() }
            
            assert(decrypted.asciiRepresentation == verses)
            
            let e = verses.encrypt(Encryption.RepeatingKeyXOR(key: p2))
            assert(e == result.hexToBytes)
            
            print("\(__FUNCTION__) passed.")
            
        }
        
        
        // MARK: Challenge 6
        // [There's a file here.](http://cryptopals.com/static/challenge-data/6.txt)
        // It's been base64'd after being encrypted with repeating-key XOR.
        
        func testChallenge6() {

            let ciphertext = String(filename: "6.txt").componentsSeparatedByString("\n").reduce("") { $0 + $1 }
            let result = ciphertext.base64ToBytes.decrypt(Encryption.RepeatingKeyXOR(key: nil))
            print("\(__FUNCTION__) passed with result:\n\n\(result)")
            
        }
        
        
        // MARK: Challenge 7
        // The Base64-encoded content in `7.txt` has been encrypted via AES-128 in ECB mode under the key
        // `YELLOW SUBMARINE`. Decrypt it.
        
        func testChallenge7() {
            
            let ciphertext = String(filename: "7.txt").componentsSeparatedByString("\n").reduce("") { $0 + $1 }
            let result = ciphertext.base64ToBytes.decrypt(Encryption.AES_128_ECB(key: "YELLOW SUBMARINE"))
            print("\(__FUNCTION__) passed with result:\n\n\(result)")
            
        }
        
        // MARK: Challenge 8
        // In `8.txt` are a bunch of hex-encoded ciphertexts. One of them has been encrypted with ECB.
        // Detect it. Remember that the problem with ECB is that it is stateless and deterministic; 
        // the same 16 byte plaintext block will always produce the same 16 byte ciphertext.
        
        func testChallenge8() {
            
            let ciphertext = String(filename: "8.txt").componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            let blocks = ciphertext.map { $0.hexToBytes.blockify(16) }
            
            var result: String? = nil
            
            for block in blocks {
                if block.isAESEncrypted {
                    result = block.flatMap { $0 }.hexRepresentation
                }
            }
        
            assert(result != nil)
            print("\(__FUNCTION__) passed with result:\n\(result!)")
            
        }
        
        testChallenge1()
        testChallenge2()
        testChallenge3()
        testChallenge4()
        testChallenge5()
        testChallenge6()
        testChallenge7()
        testChallenge8()
    }

    testSet1()
    
    print("\(__FUNCTION__) passed.")
    
}







