//
//  main.swift
//  Cryptopals
//
//  Created by Todd Olsen on 2/11/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation

testLibrary()
testSets()

private let content: [String] = {
    let bundle = NSBundle.mainBundle()
    let url = bundle.URLForResource("7", withExtension: "txt")!
    let content = try! String(contentsOfURL: url)
    return content.componentsSeparatedByString("\n")
}()

private let ciphertext  = content.flatMap { $0.base64ToBytes }
private let keysize     = ciphertext.probableKeysize()

private var decoded = [[UInt8]]()
for block in ciphertext.blockify(keysize).transpose() {
    decoded.append(block.decryptHexBytes())
}

private let result = decoded.transpose().flatMap { $0 }
