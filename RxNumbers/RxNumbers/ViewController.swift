//
//  ViewController.swift
//  RxNumbers
//
//  Created by MaxChen on 02/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var textfieldNumber1: UITextField!
    @IBOutlet weak var textfieldNumber2: UITextField!
    @IBOutlet weak var textfieldNumber3: UITextField!
    @IBOutlet weak var textfieldResult: UITextField!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Observable.combineLatest(textfieldNumber1.rx.text.orEmpty,
            textfieldNumber2.rx.text.orEmpty,
            textfieldNumber3.rx.text.orEmpty) { number1, number2, number3 -> Int in
                return (Int(number1) ?? 0) + (Int(number2) ?? 0) + (Int(number3) ?? 0)
            }
            .map { $0.description }
            .bind(to: textfieldResult.rx.text)
            .addDisposableTo(disposeBag)
    }

}

