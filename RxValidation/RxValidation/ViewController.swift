//
//  ViewController.swift
//  RxValidation
//
//  Created by MaxChen on 04/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let minimalUsernameLength = 5
let minimalPasswordLength = 5

class ViewController: UIViewController {

    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var labelUsernameValid: UILabel!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var labelPasswordValid: UILabel!
    @IBOutlet weak var buttonSubmit: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        labelUsernameValid.text = "Username has to be at least \(minimalUsernameLength) charcters"
        labelPasswordValid.text = "Password has to be at least \(minimalPasswordLength) charcters"
        
        let usernameValid = textfieldUsername.rx.text.orEmpty
            .map { $0.characters.count >= minimalUsernameLength }
            .shareReplay(1)
        
        let passwordValid = textfieldPassword.rx.text.orEmpty
            .map { $0.characters.count >= minimalPasswordLength }
            .shareReplay(1)
        
        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .shareReplay(1)
        
        usernameValid.bind(to: textfieldPassword.rx.isEnabled)
            .disposed(by: disposeBag)
        
        usernameValid.bind(to: labelUsernameValid.rx.isHidden)
            .disposed(by: disposeBag)
        
        passwordValid.bind(to: labelPasswordValid.rx.isHidden)
            .disposed(by: disposeBag)
        
        everythingValid.subscribe(onNext: { [weak self] valid in
            self?.buttonSubmit.isEnabled = valid
            self?.buttonSubmit.backgroundColor = valid ? UIColor.green : UIColor.red
        }).disposed(by: disposeBag)
        
        buttonSubmit.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAlert() })
            .disposed(by: disposeBag)
    }

    func showAlert() {
        let alert = UIAlertController(title: "RxValidation", message: "You clicked the button.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

