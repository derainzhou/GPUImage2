//
//  ViewController.swift
//  GPUImage2_Example_macOS
//
//  Created by DerainZhou on 2025/4/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Cocoa
import GPUImage2

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let originalUIImage = NSImage(named: "IMG_3705.jpeg") else { return }

        let filter = BrightnessAdjustment()
        let pictureInput = PictureInput(image: originalUIImage)
        pictureInput.addTarget(filter)

        let pictureOutput = PictureOutput()
        filter.addTarget(pictureOutput)

        // 设置回调
        pictureOutput.imageAvailableCallback = { processedUIImage in
            print("图片处理完成回调触发！处理后的图像: \(processedUIImage)")
        }

        pictureInput.processImage(synchronously: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

