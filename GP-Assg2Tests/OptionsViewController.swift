//
//  PopUpViewController.swift
//  GraphicsProgramming-Assignment2
//
//  Created by Mac Cheese on 04/09/2019.
//  Copyright © 2019 Mac Cheese. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    
    @IBOutlet weak var optionsView: UIView?
    var mainViewController:MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        optionsView?.layer.cornerRadius = 5.0
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func clearAll(_ sender: Any) {
        mainViewController?.clearAll()
    }
    
    @IBAction func toggleBezier(_ sender: Any) {
        mainViewController?.toggleBezier()
    }
    
    @IBAction func deletePoint(_ sender: Any) {
        mainViewController?.deletePoint()
    }
    @IBAction func quit(_ sender: Any) {
        exit(0)
    }
}
