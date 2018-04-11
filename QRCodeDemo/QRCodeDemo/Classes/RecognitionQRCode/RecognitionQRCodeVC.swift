//
//  RecognitionQRCodeVC.swift
//  QRCodeDemo
//
//  Created by 黄文泰 on 2018/3/30.
//  Copyright © 2018年 黄文泰. All rights reserved.
//

import UIKit

class RecognitionQRCodeVC: UIViewController {
    @IBOutlet weak var sourceImageView: UIImageView!
    
    @IBAction func recognitionQRCode() {
        //获取需要识别的图片
        let image = sourceImageView.image
        let result = QRCodeTool.detectorQRCodeImage(image: image!, isDrawQRCodeFrame: true)
        //获取返回结果的字符串
        let strs = result.resultStrs
        //获取返回结果的描边图片
        sourceImageView.image = result.resultImage
        //弹出结果
        let alertVC = UIAlertController(title: "识别结果", message: strs?.description, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "关闭", style: UIAlertActionStyle.default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
        
        
    }
    
    
}
