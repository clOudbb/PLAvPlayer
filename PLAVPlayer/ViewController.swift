//
//  ViewController.swift
//  PLAVPlayer
//
//  Created by 张征鸿 on 2017/5/3.
//  Copyright © 2017年 张征鸿. All rights reserved.
//

import UIKit

let requestUrl = "http://baobab.wdjcdn.com/14562919706254.mp4"
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let plView = PLAVPlayView.shareInstance
        plView.frame = CGRect.init(x: 0, y: 50, width: kPLScreenWidth, height: 200)
        plView.playUrl = requestUrl
        self.view.addSubview(plView)
//        plView.snp.makeConstraints { (make) in
//            make.top.equalTo(50)
//            make.left.right.equalTo(0)
//            make.height.equalTo(200)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

