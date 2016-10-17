//
//  MoveableView.swift
//  extandableView-test
//
//  Created by Robin Somlette on 16-Oct-2016.
//  Copyright © 2016 Robin Somlette. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class MoveableView: UIView {
    
    
    enum Position {
        case minimazed, medium, fullSized
    }
    
    private(set) var originalHeight: CGFloat?
    private(set) var currentheight: CGFloat?
    
    private var miniSize: CGFloat {
        if let sup = superview {
            return sup.frame.height / 4
        } else {
            return 150
        }
    }
    private var mediumSize: CGFloat {
        if let sup = superview {
            return sup.frame.height / 2.2
        } else {
            return 300
        }
    }
    private var fullSize: CGFloat {
        if let sup = superview {
            return sup.frame.height / 1.5
        } else {
            return 450
        }
    }
    
    var currentPosition = BehaviorSubject<Position>(value: .minimazed)
    let disposeBag = DisposeBag()

    init() {
        super.init(frame: CGRect.zero)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        backgroundColor = .yellow
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragged)))
        createUI()
        createConstraint()
//        createActions()
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let distance = gestureRecognizer.translation(in: self)
//        print("Distance x:\(distance.x) y:\(distance.y)")
        print("CurrentHeigth: ", currentheight, " Original Height: ", originalHeight)
        
        switch gestureRecognizer.state {
        case .began:
            self.originalHeight = frame.height
        case .changed:
                currentheight = distance.y * -1 + originalHeight!
                
                if currentheight! <= miniSize + 50 {
                    backgroundColor = .yellow
                } else if (mediumSize - 50) <= currentheight!  && currentheight! <= (mediumSize + 50) {
                    backgroundColor = .orange
                } else if (fullSize - 50) <= currentheight! {
                    backgroundColor = .red
                }
                
                
                self.snp.updateConstraints({ (make) in
                    make.height.equalTo(currentheight!)
                })
        case .ended:
            if currentheight! <= miniSize + 50 {
                scaleView(position: .minimazed)
//                self.currentPosition.onNext(.minimazed)
            } else if (mediumSize - 50) <= currentheight!  && currentheight! <= (mediumSize + 50) {
                scaleView(position: .medium)
//                self.currentPosition.onNext(.medium)
            } else if (fullSize - 50) <= currentheight! {
                scaleView(position: .fullSized)
//                self.currentPosition.onNext(.fullSized)
                
                
                
            } else {
                print("RESETING VALUE")
                resetViewPositionAndTransformation()
            }
            
        default:
            print("Default triggered Gesture")
        }
    }
    
    func scaleView(position: Position) {
        let animations: UIViewAnimationOptions = [.curveEaseInOut]
        switch position {
        case .minimazed:
            UIView.animate(withDuration: 0.7, delay: 0, options: animations, animations: {
                    self.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.miniSize)
                    })
                    self.superview?.layoutIfNeeded()
                }, completion: nil)
        case .medium:
            UIView.animate(withDuration: 0.7, delay: 0, options: animations, animations: {
                    print("Notification is Displaying")
                    self.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.mediumSize)
                    })
                    self.superview?.layoutIfNeeded()

                }, completion: { (completed) in
                    if completed {
                        print("Notification is going away")
                        self.currentPosition.onNext(.minimazed)
                    }
            })
        case .fullSized:
            UIView.animate(withDuration: 0.7, delay: 0, options: animations, animations: {

                    self.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.fullSize)
                    })
                    self.superview?.layoutIfNeeded()

                }, completion: nil)
        }

    }

    
    func resetViewPositionAndTransformation() {
        UIView.animate(withDuration: 5, delay: 0, options: [.curveEaseInOut], animations: {
                self.snp.updateConstraints({ (make) in
                    make.height.equalTo(self.miniSize)
                })
            }, completion: nil)
    }
    
    func createUI() {
        // TODO: Add UI Element
    }
    func createConstraint() {
        // TODO: Add Constraints
    }
    func createActions() {
        self.currentPosition.subscribe(onNext: { (position) in
            print(position)
            self.scaleView(position: position)
            }).addDisposableTo(disposeBag)
    }

    
}
