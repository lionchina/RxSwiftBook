//
//  ViewController.swift
//  RxExample
//
//  Created by 陈秀鹏 on 2017/7/29.
//  Copyright © 2017年 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var textfieldUser: UITextField!
    @IBOutlet weak var labelUser: UILabel!
    let disposeBag = DisposeBag()
    let userViewModel = UserViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ = textfieldUser.rx.text
            .orEmpty
            .bind(to: userViewModel.username)
        _ = userViewModel.greetingUser
            .bind(to: labelUser.rx.text)
    }
}

