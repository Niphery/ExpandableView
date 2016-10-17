//
//  ViewController.swift
//  extandableView-test
//
//  Created by Robin Somlette on 16-Oct-2016.
//  Copyright © 2016 Robin Somlette. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private(set) var movableView = MoveableView()
    private(set) var button = UIButton()
    
    let disposeBag = DisposeBag()

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
        view.addSubview(button)
        view.addSubview(movableView)
        
        button.setTitle("Send Notification", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        initConstraint()
        initActions()
    }
    
    func initConstraint() {
        movableView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
    }
    
    func initActions() {
        button.rx.tap.subscribe { (event) in
            self.movableView.currentPosition.onNext(.medium)
        }.addDisposableTo(disposeBag)
    }
    
}
