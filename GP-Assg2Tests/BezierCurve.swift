//
//  BezierCurve.swift
//  GraphicsProgramming-Assignment2
//
//  Created by Mac Cheese on 03/09/2019.
//  Copyright © 2019 Mac Cheese. All rights reserved.
//

import Foundation
import GLKit

class BezierCurve : Shape{
    var points:[CGPoint]
    
    var vertexBuffer:GLuint = 0
    var vao:GLuint = 0
    
    var vertices:[Vertex] = []
    
    var bezier_color:Color
    var t_step:Double
    var line_width:GLfloat
    
    init(_ points:[CGPoint],_ bezier_color:Color,_ t_step:Double,_ line_width:GLfloat) {
        self.bezier_color = bezier_color
        self.t_step = t_step
        self.points = points
        self.line_width = line_width
        
        super.init()
        calculateCasteljauVertices()
        updateBuffers()
    }
    
    func addPoint(_ point:CGPoint) {
        points.append(point)
        calculateCasteljauVertices()
        updateBuffers()
    }
    
    func removePoint(_ index:Int) {
        points.remove(at: index)
        calculateCasteljauVertices()
        updateBuffers()
    }
    
    func updatePoint(_ index:Int, _ point:CGPoint) {
        points[index].x = point.x
        points[index].y = point.y
        calculateCasteljauVertices()
        updateBuffers()
    }
    
    func draw() {
        glLineWidth(line_width)
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_LINE_STRIP), GLsizei(vertices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func calculateCasteljauVertices(){
        vertices.removeAll()
        
        var tmp:Vertex
        for t in stride(from: 0, through: 1, by: t_step) {
            tmp = getCasteljauVertex(points.count - 1, 0, GLfloat(t))
            vertices.append(tmp)
        }
    }
    
    func getCasteljauVertex(_ r:Int,_ i:Int,_ t:GLfloat) -> Vertex {
        if(r == 0) {
            return Vertex(GLfloat(points[i].x), GLfloat(points[i].y), 0, bezier_color)
        }
        
        let v1:Vertex = getCasteljauVertex((r - 1), i, t)
        let v2:Vertex = getCasteljauVertex((r - 1), (i + 1), t)
        
        let px = (1 - t) * v1.x + t * v2.x
        let py = (1 - t) * v1.y + t * v2.y
        return Vertex(px, py, 0, bezier_color)
    }
    
    private func updateBuffers(){
        setupVertexBuffer(&vao, &vertexBuffer, vertices)
    }
}
