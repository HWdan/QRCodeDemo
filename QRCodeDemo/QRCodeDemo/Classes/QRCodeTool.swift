//
//  QRCodeTool.swift
//  QRCodeDemo
//
//  Created by 黄文泰 on 2018/4/10.
//  Copyright © 2018年 黄文泰. All rights reserved.
//

import UIKit
import AVFoundation

typealias ScanResultBlock = ([String]) -> ()

class QRCodeTool: NSObject {
    //单例
    static let shareInstance = QRCodeTool()
    
    private var scanResultBlock: ScanResultBlock?
    
    //懒加载输入设备
    lazy var input: AVCaptureDeviceInput? = {
        //设置输入设备,获取摄像头设备
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        //把摄像头设备当做输入设备
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device!)
            return input
        } catch {
            print(error)
            return nil
        }
    }()
    //懒加载输出设备
    lazy var output: AVCaptureMetadataOutput = {
        //设置输出设备
        let output = AVCaptureMetadataOutput()
        //设置代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }()
    
    lazy var session: AVCaptureSession = {
        //创建会话，连接输入和输出
        let session = AVCaptureSession()
        return session
    }()
    
    lazy var layer:AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer
    }()
    
    
    /// 生成二维码
    ///
    /// - Parameters:
    ///   - inpuStr: 内容
    ///   - centerImage: 二维码中心图片
    /// - Returns: UIImage
    class func generationQRCode(inpuStr: String, centerImage: UIImage?) -> UIImage {
        
        let stringData = inpuStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
        //创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter?.outputImage
        
        // 创建一个颜色滤镜,黑白色
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        // 返回高清的二维码image
        var resultImage = UIImage(ciImage: (colorFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: 5, y: 5))))
        if centerImage != nil {
            resultImage = getNewImage(sourceImage: resultImage, centerImage: centerImage!)
        }
        return resultImage
    }
    
    /// 识别图片中的二维码
    ///
    /// - Parameters:
    ///   - image: 要识别的图片
    ///   - isDrawQRCodeFrame: 是否描边框
    /// - Returns: （内容数组，描绘好边框二维码图片）
    class func detectorQRCodeImage(image: UIImage, isDrawQRCodeFrame: Bool) -> (resultStrs: [String]?, resultImage: UIImage) {
        //获取需要识别的图片
        let imageCI = CIImage(image: image)
        
        //开始识别,创建一个二维码探测器
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        //直接探测二维码特征
        let features = dector?.features(in: imageCI!)
        //存储处理好的图片
        var resultImage = image
        var result = [String]()
        for feature in features! {
            let grFeature = feature as! CIQRCodeFeature
            result.append(grFeature.messageString!)
            if isDrawQRCodeFrame {
                resultImage = drawFrame(image: resultImage, feature: grFeature)
            }
        }
        return (result, resultImage)
    }
    
    
    /// 扫描二维码
    ///
    /// - Returns: 扫描结果
    func scanQRCode(inView: UIView, resultBlock:@escaping ((_ resultStrs: [String]) -> ())) {
        //记录闭包
        self.scanResultBlock = resultBlock
        
        if session.canAddInput(input!) && session.canAddOutput(output) {
            session.addInput(input!)
            session.addOutput(output)
        } else {
            return
        }
        //设置二维码可以识别的类型
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        //设置扫描区

        //添加视频预览图层
        if inView.layer.sublayers == nil {
            layer.frame = inView.layer.bounds
            inView.layer.insertSublayer(layer, at: 0)
        } else {
            let subLayers = inView.layer.sublayers!
            if !subLayers.contains(layer){
                layer.frame = inView.layer.bounds
                inView.layer.insertSublayer(layer, at: 0)
            }
        }
        //启动会话(设备开始采集数据)
        session.startRunning()
    }
    
    /// 设置扫描区域
    ///
    /// - Parameter orignRect: 扫描区域的frame
    func setRectOfInterest(orignRect: CGRect) -> () {
        let bounds = UIScreen.main.bounds
        let x: CGFloat = orignRect.origin.x / bounds.size.width
        let y: CGFloat = orignRect.origin.y / bounds.size.height
        let width: CGFloat = orignRect.size.width / bounds.size.width
        let height: CGFloat = orignRect.size.height / bounds.size.height
                output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
    }
    
}

extension QRCodeTool {
    
    class private func getNewImage(sourceImage: UIImage, centerImage: UIImage) -> UIImage {
        let size = sourceImage.size
        //开启图形上下文
        UIGraphicsBeginImageContext(size)
        //绘制大图片
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let width: CGFloat = 40
        let height: CGFloat = 40
        let x: CGFloat = (size.width - width) * 0.5
        let y: CGFloat = (size.height - height) * 0.5
        //绘制小图片
        centerImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        return resultImage!
    }
//
    class private func drawFrame(image:UIImage, feature: CIQRCodeFeature) -> UIImage {
        let size = image.size
        //开启图形上下文
        UIGraphicsBeginImageContext(size)
        //绘制大图片
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        //转换坐标系（上下颠倒）
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        
        //绘制路径
        let bounds = feature.bounds
        let path = UIBezierPath(rect: bounds)
        UIColor.red.setStroke()
        path.lineWidth = 6
        path.stroke()
        //取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
}

extension QRCodeTool: AVCaptureMetadataOutputObjectsDelegate {
    //扫描到结果之后调用
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var resultStrs = [String]()
        for obj in metadataObjects {
            if obj.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                let resultObj = layer.transformedMetadataObject(for: obj)
                let qrCodeObj = resultObj as! AVMetadataMachineReadableCodeObject
                resultStrs.append(qrCodeObj.stringValue!)
            }
        }
        if scanResultBlock != nil {
            scanResultBlock!(resultStrs)
        }
    }
}


