//
//  ViewController.swift
//  GPUImage2
//
//  Created by ZDerain on 08/04/2020.
//  Copyright (c) 2020 ZDerain. All rights reserved.
//

import UIKit
import GPUImage2

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let originalUIImage = UIImage(named: "IMG_3705.jpeg") else { return }

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

}

