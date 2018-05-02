# QRCodeDemo
 使用swift封装二维码生成、识别图片中的二维码、扫描二维码功能

使用：
1.导入 QRCodeTool.swift 文件

生成二维码：
```
 let str = inputTextView.text ?? ""
 let centerImage = UIImage(named: "erha")
 let image = QRCodeTool.generationQRCode(inpuStr: str, centerImage: centerImage)
```

识别图片二维码：
```
 //获取需要识别的图片
let image = sourceImageView.image
let result = QRCodeTool.detectorQRCodeImage(image: image!, isDrawQRCodeFrame: true)
//获取返回结果的字符串
let strs = result.resultStrs
//获取返回结果的描边图片
sourceImageView.image = result.resultImage
```

扫描二维码：
```
 QRCodeTool.shareInstance.setRectOfInterest(orignRect: scanBackView.frame)
 QRCodeTool.shareInstance.scanQRCode(inView: view) { (resultStrs) in
      print(resultStrs)
 }
```
