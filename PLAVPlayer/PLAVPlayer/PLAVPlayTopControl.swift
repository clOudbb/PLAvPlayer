//
//  PLAVPlayTopControl.swift
//  PLAVPlayer
//
//  Created by 张征鸿 on 2017/5/3.
//  Copyright © 2017年 张征鸿. All rights reserved.
//

import UIKit
public final class PLAVPlayTopControl: UIView {
    
    public lazy var clarityButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("标清", for: .normal)
        button.backgroundColor = UIColor.orange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    public lazy var backButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(plImage(imageStyle: .backBtn), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = kPLRGBA(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.addSubview(clarityButton)
        self.addSubview(backButton)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        clarityButton.snp.makeConstraints { (make) in
            make.right.equalTo(-5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 40, height: 25))
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

