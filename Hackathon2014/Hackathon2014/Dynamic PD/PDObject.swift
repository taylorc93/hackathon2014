//
//  PDObject.swift
//  Hackathon2014
//
//  Created by Chris Penny on 11/9/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

import Foundation

let PDControl = 0
let PDSignal = 1

// Base Class for PD Objects:  Holds name, arguments, (x,y) coordinates, inlets, outlets
class PDObject {
    var name: String
    var x: Int
    var y: Int
    var args: String
    
    var inlets:  Array<Int>
    var outlets: Array<Int>
    
    var id: Int
    
    init(name: String, arguments: String, x: Int, y: Int, inlets: Array<Int>, outlets:  Array<Int>) {
        self.name        = name
        self.x           = x
        self.y           = y
        self.inlets      = inlets
        self.outlets     = outlets
        self.args        = arguments
        self.id          = 0
    }
    
    convenience init() {
        self.init(name: "f 0", arguments: "", x: 0, y: 0,inlets: [PDControl], outlets: [PDControl])
    }
}

// Mutable PD Class - This is for objects that change the number of inputs or outputs based on the argument.
//
// [trigger] is a good example:  
//                              [trigger b f a l] 
//                                  - Create a [trigger] object with 4 outlets.
class PDMutableObject:  PDObject {
    
    var validArgs:  Array<String> = []
    var parameters: Array<String> = []
    var isValid: Bool = true
    var mutableMode: Int = 0
    // 0 => Outlets change with args, 1 => Inlets change with args, 2 => both
    
    init(name: String, arguments: String, x: Int, y: Int, inlets: Array<Int>, outlets: Array<Int>, validArguments: Array<String>, mode: Int) {
        super.init(name: name, arguments: arguments, x: x, y: y, inlets: inlets, outlets: outlets)
        
        self.mutableMode = mode
        self.validArgs = validArguments
        self.setArgs(arguments)
    }
    
    convenience init() {
        self.init(
            name: "route ",
            arguments: "0 ",
            x: 1, y: 1,
            inlets: [PDControl], outlets: [PDControl, PDControl],
            validArguments: Array<String>(),
            mode: 0
        )
    }
    
    func setArgs(arguments: String) {
        
        self.args = arguments
        self.parameters = arguments.componentsSeparatedByString(" ")
        self.isValid = true
        
        for type in arguments {
            if contains(validArgs, String(type)) || validArgs.isEmpty {
                parameters.append(String(type))
            } else {
                self.isValid = false
                parameters.append("-")
            }
        }
        
        if self.mutableMode % 2 == 0 {
            self.outlets = Array(count:  parameters.count, repeatedValue:  PDControl)
        }
        if self.mutableMode > 0 {
            self.inlets = Array(count:  parameters.count, repeatedValue:  PDControl)
        }
    }
}
