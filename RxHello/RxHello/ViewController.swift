//
//  ViewController.swift
//  RxExample
//
//  Created by MaxChen on 2017/7/29.
//  Copyright © 2017年 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var textfieldUser: UITextField!
    @IBOutlet weak var labelUser: UILabel!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textfieldUser.rx.text
            .map { "Hello, " + ($0 ?? "") }
            .bind(to: labelUser.rx.text)
            .addDisposableTo(disposeBag)
    }
}

