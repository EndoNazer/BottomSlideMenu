//
//  File.swift
//  BottomSlideMenu
//
//  Created by Даниил on 24/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

import Foundation
import UIKit

class BottomSlideMenuViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var handleArea: UIView!
    
    var bottomSlideMenu = BottomSlideMenu(currentPosition: .bottom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupAndAddVisualEffectView(){
        bottomSlideMenu.visualEffectView = UIVisualEffectView()
        bottomSlideMenu.visualEffectView.frame = self.view.frame
        self.view.addSubview(bottomSlideMenu.visualEffectView)
    }
    
    func tuningBottomSlideMenuViewController(){
        bottomSlideMenu.handleAreaHeight = 0.07 * self.view.frame.height
        bottomSlideMenu.height = self.view.frame.height * 0.5
        self.view.frame = CGRect(x: 0, y: self.view.frame.height - bottomSlideMenu.handleAreaHeight, width: self.view.bounds.width, height: bottomSlideMenu.height)
        self.view.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
