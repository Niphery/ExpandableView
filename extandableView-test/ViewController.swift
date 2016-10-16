//
//  ViewController.swift
//  extandableView-test
//
//  Created by Robin Somlette on 16-Oct-2016.
//  Copyright © 2016 Robin Somlette. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private(set) var movableView = MoveableView()
//    var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(detectPan))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        view.addSubview(movableView)
        initConstraint()
    }
    
    func initConstraint() {
        movableView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
    }
    
    func initActions() {

    }
    
}
