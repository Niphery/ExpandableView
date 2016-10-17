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
        case minimized, medium, fullSized
    }
    enum States {
        case moving, ending, none
    }
    
    private(set) var originalHeight: CGFloat?
    private(set) var currentheight: CGFloat = 0
    
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
    private var minDif: CGFloat {
        return (mediumSize - miniSize) / 2
    }
    private var fullDif: CGFloat {
        return (fullSize - mediumSize) / 2
    }
    private var currentState = BehaviorSubject<States>(value: .none)
    var currentPosition = BehaviorSubject<Position>(value: .minimized)

    let disposeBag = DisposeBag()
    let animationTimer = 0.5
    let animations: UIViewAnimationOptions = [.curveEaseInOut]
    

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
        createActions()
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let distance = gestureRecognizer.translation(in: self)
//        print("Distance x:\(distance.x) y:\(distance.y)")
        print("CurrentHeigth: ", currentheight, " Original Height: ", originalHeight)
        
        switch gestureRecognizer.state {
        case .began:
            originalHeight = frame.height
        case .changed:
            self.currentheight = distance.y * -1 + originalHeight!
            currentState.onNext(.moving)
        case .ended:
            currentState.onNext(.ending)
            
        default:
            print("Default triggered Gesture")
        }
    }
    
    func scaleView(position: Position) {
        switch position {
        case .minimized:
            showMinimized()
        case .medium:
            showNotification()
        case .fullSized:
            showFullScreen()
        }

    }
    
    func showMinimized() {
        UIView.animate(withDuration: animationTimer, delay: 0, options: animations, animations: {
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(self.miniSize)
            })
            self.superview?.layoutIfNeeded()
            }, completion: nil)
    }
    func showNotification() {
        UIView.animate(withDuration: animationTimer, delay: 0, options: animations, animations: {
            print("Notification is Displaying")
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(self.mediumSize)
            })
            self.superview?.layoutIfNeeded()
            
            }, completion: { (completed) in
                if completed {
                    print("Notification is gonna go")
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                        print("Notification leaving", timer)
                        self.currentPosition.onNext(.minimized)
                        self.showMinimized()
                    })
//                    Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.showMinimized), userInfo: nil, repeats: false)
                }
        })
    }
    func showFullScreen() {
        UIView.animate(withDuration: animationTimer, delay: 0, options: animations, animations: {
            
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(self.fullSize)
            })
            self.superview?.layoutIfNeeded()
            
            }, completion: nil)
    }

    
    func resetViewPositionAndTransformation() {
        UIView.animate(withDuration: animationTimer, delay: 0, options: [.curveEaseInOut], animations: {
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(self.miniSize)
            })
             self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    func createUI() {
        // TODO: Add UI Element
    }
    func createConstraint() {
        // TODO: Add Constraints
    }
    func createActions() {
        //On Release, adjust view to key Value
//        self.currentPosition.subscribe(onNext: { (position) in
//            print(position)
////            self.scaleView(position: position)
//            switch position {
//            case .minimized:
//                self.showMinimized()
//            case .medium:
//                self.showNotification()
//            case .fullSized:
//                self.showFullScreen()
//            }
//        }).addDisposableTo(disposeBag)
    
        
        //When moved, change size + Color
        self.currentState.subscribe(onNext: { (state) in
            if self.currentheight <= self.miniSize + 50 {
                self.backgroundColor = .yellow
            } else if (self.mediumSize - 50) <= self.currentheight  && self.currentheight <= (self.mediumSize + 50) {
                self.backgroundColor = .orange
            } else if (self.fullSize - 50) <= self.currentheight {
                self.backgroundColor = .red
            }
            
            switch state {
            case .moving:
                self.snp.updateConstraints({ (make) in
                    make.height.equalTo(self.currentheight)
                })
            case .ending:
                
                if self.currentheight <= self.miniSize + self.minDif {
                    self.scaleView(position: .minimized)
//                    self.currentPosition.onNext(.minimized)
                } else if (self.mediumSize - self.minDif) <= self.currentheight  && self.currentheight <= (self.mediumSize + self.fullDif) {
                    self.scaleView(position: .medium)
//                    self.currentPosition.onNext(.medium)
                } else if (self.fullSize - self.fullDif) <= self.currentheight {
                    self.scaleView(position: .fullSized)
//                    self.currentPosition.onNext(.fullSized)
                } else {
                    print("RESETING VALUE")
                    self.resetViewPositionAndTransformation()
                }
            default:
                break
            }
            
            }).addDisposableTo(disposeBag)
        
        
        
    }

    
}
