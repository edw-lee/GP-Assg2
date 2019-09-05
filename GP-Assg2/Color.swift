//
//  Color.swift
//  GraphicsProgramming-Assignment2
//
//  Created by Mac Cheese on 02/09/2019.
//  Copyright © 2019 Mac Cheese. All rights reserved.
//

import Foundation
import GLKit

struct Color{
    var r : GLfloat = 0.0
    var g : GLfloat = 0.0
    var b : GLfloat = 0.0
    var a : GLfloat = 1.0
    
    init(_ r:GLfloat, _ g:GLfloat, _ b:GLfloat, _ a:GLfloat){
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(){ }
}
