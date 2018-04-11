//
//  GenerationQRCodeVC.swift
//  QRCodeDemo
//
//  Created by 黄文泰 on 2018/3/30.
//  Copyright © 2018年 黄文泰. All rights reserved.
//

import UIKit
import CoreImage

class GenerationQRCodeVC: UIViewController {
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var inputTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        let str = inputTextView.text ?? ""
        let centerImage = UIImage(named: "erha")
        let image = QRCodeTool.generationQRCode(inpuStr: str, centerImage: centerImage)
        qrCodeImageView.image = image
        
    }

}
