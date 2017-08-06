//
//  ViewController.swift
//  RxGithubSignup
//
//  Created by MaxChen on 06/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var labelUsernameValidation: UILabel!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var labelPasswordValidation: UILabel!
    @IBOutlet weak var textfieldPasswordRepeat: UITextField!
    @IBOutlet weak var labelPasswordRepeatValidation: UILabel!
    @IBOutlet weak var buttonSignup: UIButton!
    @IBOutlet weak var indicatorSignup: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let viewModel = SignupViewModel(input: (username: textfieldUsername.rx.text.orEmpty.asObservable(), password: textfieldPassword.rx.text.orEmpty.asObservable(), passwordRepeat: textfieldPasswordRepeat.rx.text.orEmpty.asObservable(), loginTaps: buttonSignup.rx.tap.asObservable()), dependency: (API: GitHubDefaultAPI.sharedAPI, validationService: GitHubDefaultValidationService.sharedValidationService, wireframe: DefaultWireframe.shared))
        
        viewModel.signupEnabled
            .subscribe(onNext: { [weak self] valid in
                self?.buttonSignup.isEnabled = valid
                self?.buttonSignup.alpha = valid ? 1.0 : 0.5
            }).disposed(by: disposeBag)
        
        viewModel.validatedUsername
            .bind(to: labelUsernameValidation.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .bind(to: labelPasswordValidation.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPasswordRepeat
            .bind(to: labelPasswordRepeatValidation.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .subscribe(onNext: { [weak self] isSigning in
                self?.indicatorSignup.isHidden = !isSigning
                if isSigning {
                    self?.indicatorSignup.startAnimating()
                } else {
                    self?.indicatorSignup.stopAnimating()
                }
                
            })
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
}

