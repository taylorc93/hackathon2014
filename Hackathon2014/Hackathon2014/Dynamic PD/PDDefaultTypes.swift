//
//  PDBasicTypes.swift
//  Hackathon2014
//
//  Created by Chris Penny on 11/9/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

import Foundation


// Glue

let DEFAULT_GRID_X = 1
let DEFAULT_GRID_Y = 1

let pd_bang = PDObject(
    
    name: "bang",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [PDControl],
    outlets: [PDControl]
)

let pd_float = PDObject(
    
    name: "float",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [PDControl, PDControl],
    outlets: [PDControl]
)

let pd_symbol = PDObject(
    
    name: "symbol",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [PDControl, PDControl],
    outlets: [PDControl]
)

let pd_int = PDObject(
    
    name: "int",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [PDControl, PDControl],
    outlets: [PDControl]
)

let pd_send = PDObject(
    
    name: "send",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [PDControl, PDControl],
    outlets: []
)

let pd_receive = PDObject(
    
    name: "receive",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [],
    outlets: [PDControl]
)

let pd_select = PDObject(
    
    name: "select",
    arguments: "",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets:  [PDControl, PDControl],
    outlets: [PDControl, PDControl]
)

let pd_trigger = PDMutableObject(
    
    name: "trigger",
    arguments: "b b f",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets: [PDControl],
    outlets: [PDControl, PDControl, PDControl],
    validArguments: ["a", "b", "f", "s", "l", "p"],
    mode: 0
)

let pd_route = PDMutableObject(
    
    name: "route",
    arguments: "note wave reverb",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets: [PDControl],
    outlets: [PDControl, PDControl, PDControl],
    validArguments: [],
    mode: 0
)

let pd_pack = PDMutableObject(
    
    name: "pack",
    arguments: "0 0",
    x: DEFAULT_GRID_X,
    y: DEFAULT_GRID_Y,
    inlets: [PDControl, PDControl],
    outlets: [PDControl],
    validArguments: [],
    mode: 1
)

