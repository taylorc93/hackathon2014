//
//  PDPatch.swift
//  Hackathon2014
//
//  Created by Chris Penny on 11/9/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

import Foundation

struct PDConnection {
    var inObject : PDObject
    var inlet : Int
    var outObject : PDObject
    var outlet : Int
    
    init(inObject: PDObject, inlet: Int, outObject: PDObject, outlet: Int) {
        self.inObject = inObject
        self.inlet = inlet
        self.outObject = outObject
        self.outlet = outlet
    }
}

class PDPatch {
    
    var objects : Array<PDObject>
    var connections : Array<PDConnection>
 
    init() {
        self.objects = Array<PDObject>()
        self.connections = Array<PDConnection>()
    }
    
    func addConnection(connection: PDConnection) {
        
    }
    
    func removeConnection(connection: PDConnection) {
        
    }
}