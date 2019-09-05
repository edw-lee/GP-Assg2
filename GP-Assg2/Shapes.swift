//
//  Square.swift
//  GraphicsProgramming-Assignment2
//
//  Created by Mac Cheese on 02/09/2019.
//  Copyright © 2019 Mac Cheese. All rights reserved.
//

import Foundation
import GLKit

class Square : Shape {
    var vertexBuffer:GLuint = 0
    var indexBuffer:GLuint = 0
    var fill_vao:GLuint = 0
    var line_vao:GLuint = 0
    
    var vertices:[Vertex]!
    var fill_indices:[GLubyte]!
    var line_indices:[GLubyte]!
    
    let screenRect:CGRect = UIScreen.main.bounds
    var size:GLfloat
    var sizeHeight:GLfloat
    var color:Color
    var line_width:GLfloat

    init(_ position:CGPoint, _ size:GLfloat, _ line_width:GLfloat, _ color:Color) {
        self.size = size > 1.0 ? 1.0 : size
        self.color = color
        self.line_width = line_width
        
        let screenRatio = GLfloat(screenRect.maxX/screenRect.maxY)
        sizeHeight = screenRatio * size
        let x = GLfloat(position.x), y = GLfloat(position.y)

        vertices = [
            Vertex(x + size, y - sizeHeight, 0, color),
            Vertex(x + size, y + sizeHeight, 0, color),
            Vertex(x - size, y + sizeHeight, 0, color),
            Vertex(x - size, y - sizeHeight, 0, color)
        ]
        
        fill_indices = [
            0, 1, 2,
            2, 3, 0
        ]
        
        line_indices = [
            0, 1, 2, 3
        ]
        
        super.init()
        updateBuffers()
    }
    
    func updatePosition(_ x:GLfloat,_ y:GLfloat){
        vertices = [
            Vertex(x + size, y - sizeHeight, 0, color),
            Vertex(x + size, y + sizeHeight, 0, color),
            Vertex(x - size, y + sizeHeight, 0, color),
            Vertex(x - size, y - sizeHeight, 0, color)
        ]
        updateBuffers()
    }
    
    private func updateBuffers(){
        setupVertexBuffer(&fill_vao, &vertexBuffer, &indexBuffer, vertices, fill_indices)
        setupVertexBuffer(&line_vao, &vertexBuffer, &indexBuffer, vertices, line_indices)
    }
    
    func drawFill() {
        glBindVertexArrayOES(fill_vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(fill_indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func drawLine() {
        glLineWidth(line_width)
        
        glBindVertexArrayOES(line_vao)
        glDrawElements(GLenum(GL_LINE_LOOP), GLsizei(vertices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
}

class Line : Shape{
    var vertexBuffer:GLuint = 0
    var vao:GLuint = 0
    
    var vertices:[Vertex] = []
    var color:Color!
    var line_width:GLfloat
    
    init(_ points:[CGPoint], _ line_width:GLfloat, _ color:Color){
        self.color = color
        self.line_width = line_width
        
        for point in points {
            vertices.append(Vertex(GLfloat(point.x), GLfloat(point.y), 0, color))
        }
        
        super.init()
        
        updateBuffers()
    }
    
    func addVertex(_ point:CGPoint){
        vertices.append(Vertex(GLfloat(point.x), GLfloat(point.y), 0, color))
        updateBuffers()
    }
    
    func removeVertex(_ index:Int) {
        vertices.remove(at: index)
        updateBuffers()
    }
    
    func updateVertex(_ index:Int, _ point:CGPoint) {
        vertices[index].x = GLfloat(point.x)
        vertices[index].y = GLfloat(point.y)
        updateBuffers()
    }
    
    private func updateBuffers(){
        setupVertexBuffer(&vao, &vertexBuffer, vertices)
    }
    
    func draw() {
        glLineWidth(line_width)
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_LINE_STRIP), GLsizei(vertices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
}

class Shape {
    static var shader:BaseEffect! = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
    
    init(){
        Shape.shader.prepareToDraw()
    }
    
    func setupVertexBuffer(_ vao:inout GLuint, _ vertexBuffer:inout GLuint, _ vertices:[Vertex]) {
        var indexBuffer:GLuint = 0
        var indices:[GLubyte] = []
        for i in 0..<vertices.count {
            indices.append(GLubyte(i))
        }
        
        setupVertexBuffer(&vao, &vertexBuffer, &indexBuffer, vertices, indices)
    }
    
    func setupVertexBuffer(_ vao:inout GLuint, _ vertexBuffer:inout GLuint, _ indexBuffer:inout GLuint, _ vertices:[Vertex], _ indices:[GLubyte]) {
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count * MemoryLayout<Vertex>.size, vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(GLsizei(1), &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLubyte>.size, indices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        glVertexAttribPointer(VertexAttributes.position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(VertexAttributes.color.rawValue, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}
