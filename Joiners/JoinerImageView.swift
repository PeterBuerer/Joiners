//
//  JoinerImageView.swift
//  Joiners
//
//  Created by Peter Buerer on 11/4/16.
//  Copyright © 2016 Peter Buerer. All rights reserved.
//

import UIKit

class JoinerImageView: UIImageView {
    var horizontalConstraint = NSLayoutConstraint()
    var verticalConstraint = NSLayoutConstraint()
    var selected = false {
        didSet {
            if selected {
                showBorder()
            }
            else {
                hideBorder()
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(topBorder)
        addSubview(bottomBorder)
        addSubview(leftBorder)
        addSubview(rightBorder)
        
        let views = [ "top": topBorder, "bottom": bottomBorder, "left": leftBorder, "right": rightBorder ]
        let metrics = [ "width": 2.0 ]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[top(==width)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[top]|", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==width)]|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottom]|", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[left(==width)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[left]|", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[right]|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==width)]|", options: [], metrics: metrics, views: views))
        
        hideBorder()
    }
   
    // MARK:- Actions
    
    func showBorder() {
        topBorder.isHidden = false
        bottomBorder.isHidden = false
        leftBorder.isHidden = false
        rightBorder.isHidden = false
    }
    
    func hideBorder() {
        topBorder.isHidden = true
        bottomBorder.isHidden = true
        leftBorder.isHidden = true
        rightBorder.isHidden = true
    }
    
    // MARK:- Views
    
    lazy var topBorder: UIView = {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .green
        return border
    }()
    
    lazy var bottomBorder: UIView = {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .green
        return border
    }()
    
    lazy var leftBorder: UIView = {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .green
        return border
    }()
    
    lazy var rightBorder: UIView = {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .green
        return border
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
