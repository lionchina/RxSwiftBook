//
//  ViewController.swift
//  RxImagePicker
//
//  Created by MaxChen on 03/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var imageviewSelect: UIImageView!
    @IBOutlet weak var buttonCamera: UIButton!
    @IBOutlet weak var buttonGallery: UIButton!
    @IBOutlet weak var buttonCrop: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        buttonCamera.rx.tap
            .flatMapLatest {
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                .flatMap {
                        $0.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }.map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
        }.bind(to: imageviewSelect.rx.image)
        .disposed(by: disposeBag)
        
        buttonGallery.rx.tap.flatMapLatest { [weak self] _ in
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
                }
                .flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
            }
                .take(1)
            }
            .map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
        }.bind(to: imageviewSelect.rx.image)
        .disposed(by: disposeBag)
        
        buttonCrop.rx.tap.flatMapLatest { [weak self] _ in
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                }.flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
                }.take(1)
            }.map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
        }.bind(to: imageviewSelect.rx.image)
        .disposed(by: disposeBag)
    }

}

