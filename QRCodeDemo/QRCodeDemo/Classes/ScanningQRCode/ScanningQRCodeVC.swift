//
//  ScanningQRCodeVC.swift
//  QRCodeDemo
//
//  Created by 黄文泰 on 2018/3/30.
//  Copyright © 2018年 黄文泰. All rights reserved.
//

import UIKit
import AVFoundation

class ScanningQRCodeVC: UIViewController {
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var scanBackView: UIView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanAnimation()
        startScan()
    }
    
    func startScan() -> () {
        QRCodeTool.shareInstance.setRectOfInterest(orignRect: scanBackView.frame)
        QRCodeTool.shareInstance.scanQRCode(inView: view) { (resultStrs) in
            print(resultStrs)
        }
    }

}

extension ScanningQRCodeVC {
    //扫描动画
    func startScanAnimation() -> () {
        toBottom.constant = scanBackView.frame.size.height
        view.layoutIfNeeded()
        toBottom.constant = -scanBackView.frame.size.height
        UIView.animate(withDuration: 2) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        }
    }
}

