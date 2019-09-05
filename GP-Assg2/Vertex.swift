//
//  Vertex.swift
//  GraphicsProgramming-Assignment2
//
//  Created by Mac Cheese on 01/09/2019.
//  Copyright © 2019 Mac Cheese. All rights reserved.
//

import Foundation
import GLKit

enum VertexAttributes : GLuint {
    case position = 0
    case color = 1
}

struct Vertex {
    var x : GLfloat = 0.0
    var y : GLfloat = 0.0
    var z : GLfloat = 0.0
    
    var color = Color();
    
    init(_ x : GLfloat, _ y : GLfloat, _ z : GLfloat, _ r : GLfloat, _ g : GLfloat, _ b : GLfloat, _ a : GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        
        self.color = Color(r, g, b, a);
    }
    
    init(_ x : GLfloat, _ y : GLfloat, _ z : GLfloat, _ color:Color) {
        self.x = x
        self.y = y
        self.z = z
        
        self.color = color;
    }
    
    init(_ x : GLfloat, _ y : GLfloat, _ z : GLfloat) {
        self.x = x
        self.y = y
        self.z = z
    }
}
