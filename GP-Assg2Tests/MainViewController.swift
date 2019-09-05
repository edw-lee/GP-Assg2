//
//  ViewController.swift
//  GraphicsProgramming-Assignment2
//
//  Created by Mac Cheese on 31/08/2019.
//  Copyright © 2019 Mac Cheese. All rights reserved.
//

import GLKit

enum UpdateState {
    case UPDATE
    case STOP
}

class MainViewController: GLKViewController {
    var glkView:GLKView!
    
    let point_size:GLfloat = 0.05
    let point_padding:GLfloat = 0.1
    let point_color:Color = Color(0.3, 0.5, 0.1, 1.0)
    let point_lineWidth:GLfloat = 5.0
    
    var points:[CGPoint] = []
    var point_squares:[Square] = []
    var selected_point_idx:Int = -1
    var new_point:CGPoint!
    
    let line_width:GLfloat = 5.0
    var line:Line!
    
    let t_step:Double = 0.025
    let bezier_color:Color = Color(1.0, 0, 0, 1.0)
    var bezier_curve:BezierCurve!
    
    var updateState:UpdateState = .UPDATE
    
    let half_screenX = UIScreen.main.bounds.maxX/2
    let half_screenY = UIScreen.main.bounds.maxY/2
    
    var isBezierOn = false
    var isGuideOn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGLcontext()
        
        let longPressGestureRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        glkView.addGestureRecognizer(longPressGestureRecognizer)
        glClearColor(1, 1, 1, 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isGuideOn) {
            self.performSegue(withIdentifier: "openGuide", sender: self)
            isGuideOn = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        if(updateState == .UPDATE) {
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            
            for i in 0..<point_squares.count {
                if (i == selected_point_idx) {
                    point_squares[i].drawFill()
                }
                else {
                    point_squares[i].drawLine()
                }
            }
            
            if(line != nil) {
                line.draw()
            }
            
            if(bezier_curve != nil && isBezierOn) {
                bezier_curve.draw()
            }
            
            updateState = .STOP
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touch_location = touch.location(in: glkView)
        let normalized_x = (touch_location.x - half_screenX)/half_screenX
        let normalized_y = (half_screenY - touch_location.y)/half_screenY
        new_point = CGPoint(x: normalized_x, y: normalized_y)
        
        checkForSelected(new_point)
        
        updateState = .UPDATE
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (selected_point_idx < 0) {
            addNewPoint()
            selected_point_idx = points.count - 1
        }
        
        let touch = touches.first!
        let touch_location = touch.location(in: glkView)
        let normalized_x = (touch_location.x - half_screenX)/half_screenX
        let normalized_y = (half_screenY - touch_location.y)/half_screenY
        let point = CGPoint(x: normalized_x, y: normalized_y)
        
        movePoint(point)
        updateLineAtPoint(point)
        updateCurveAtPoint(point)
        
        updateState = .UPDATE
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(selected_point_idx < 0) {
            addNewPoint()
        }
        
        selected_point_idx = -1
        updateState = .UPDATE
    }
    
    @objc func handleLongPress(gestureRecognizer:UILongPressGestureRecognizer){
        if(gestureRecognizer.state == .began) {
            let sb = UIStoryboard(name: "MainStoryBoard", bundle: nil)
            let optionsMenu = sb.instantiateViewController(withIdentifier: "OptionsMenu") as! OptionsViewController
            optionsMenu.mainViewController = self
            self.present(optionsMenu, animated: true)
        }
    }
    
    private func checkForSelected(_ point:CGPoint){
        var rect:CGRect
        let rect_size:CGFloat = CGFloat(point_size + point_padding)
        for i in 0..<points.count {
            rect = CGRect(x: CGFloat(points[i].x) - rect_size/2, y: CGFloat(points[i].y) - rect_size/2, width: rect_size, height: rect_size)
            if(rect.contains(point)) {
                selected_point_idx = i
                return
            }
        }
        
        selected_point_idx = -1
    }
    
    func clearAll(){
        points.removeAll()
        point_squares.removeAll()
        
        line = nil
        bezier_curve = nil
        isBezierOn = false
        
        updateState = .UPDATE
    }
    
    func toggleBezier(){
        isBezierOn = !isBezierOn
        
        updateState = .UPDATE
    }
    
    func deletePoint(){
        guard selected_point_idx >= 0 else {
            return
        }
        
        points.remove(at: selected_point_idx)
        point_squares.remove(at: selected_point_idx)
        line.removeVertex(selected_point_idx)
        bezier_curve.removePoint(selected_point_idx)
        selected_point_idx = -1
        
        updateState = .UPDATE
    }
    
    private func addNewPoint(){
        points.append(new_point)
        
        let square = Square(new_point, point_size, point_lineWidth, point_color)
        point_squares.append(square)
        
        addPointToLine()
        addPointToCurve()
    }
    
    private func movePoint(_ point:CGPoint) {
        points[selected_point_idx].x = point.x
        points[selected_point_idx].y = point.y
        
        point_squares[selected_point_idx].updatePosition(GLfloat(point.x), GLfloat(point.y))
    }
    
    private func addPointToLine() {
        if(line == nil) {
            if(points.count == 2) {
                line = Line(points, line_width, point_color)
            }
        }
        else {
            line.addVertex(new_point)
        }
    }
    
    private func updateLineAtPoint(_ point:CGPoint){
        if(line != nil) {
            line.updateVertex(selected_point_idx, point)
        }
    }
    
    private func addPointToCurve(){
        if(bezier_curve == nil){
            if(points.count == 3) {
                bezier_curve = BezierCurve(points, bezier_color, t_step, line_width)
            }
        }
        else {
            bezier_curve.addPoint(new_point)
        }
    }
    
    private func updateCurveAtPoint(_ point:CGPoint) {
        if(bezier_curve != nil) {
            bezier_curve.updatePoint(selected_point_idx, point)
        }
    }
}

extension MainViewController {
    
    func setupGLcontext() {
        glkView = (self.view as! GLKView)
        glkView.context = EAGLContext(api: .openGLES2)!
        EAGLContext.setCurrent(glkView.context)
    }
    
}
