//
//  SignupViewModel.swift
//  RxGithubSignup
//
//  Created by MaxChen on 06/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import RxCocoa
import RxSwift

class SignupViewModel {
    let validatedUsername: Observable<ValidationResult>
    let validatedPassword: Observable<ValidationResult>
    let validatedPasswordRepeat: Observable<ValidationResult>
    
    let signupEnabled: Observable<Bool>
    let signedIn: Observable<Bool>
    let signingIn: Observable<Bool>
    
    init(input: (username: Observable<String>, password: Observable<String>, passwordRepeat: Observable<String>, loginTaps: Observable<Void>), dependency: (API: GitHubAPI, validationService: GitHubValidationService, wireframe: Wireframe)) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        validatedUsername = input.username
            .flatMapLatest { username in
                return validationService.validateUsername(username).observeOn(MainScheduler.instance).catchErrorJustReturn(.failed(message: "Error contacting server"))
            }.shareReplay(1)
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }.shareReplay(1)
        
        validatedPasswordRepeat = Observable.combineLatest(input.password, input.passwordRepeat, resultSelector: validationService.validatePasswordRepeat).shareReplay(1)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) { ($0, $1) }
        
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                return API.signup(username, password: password)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(false)
                    .trackActivity(signingIn)
            }
            .flatMapLatest { loggedIn -> Observable<Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
                return wireframe.promptFor(message, cancelAction: "OK", actions: [])
                    .map { _ in
                        loggedIn
                    }
            }.shareReplay(1)
        
        signupEnabled = Observable.combineLatest(validatedUsername, validatedPassword, validatedPasswordRepeat, signingIn.asObservable()) { username, password, passwordRepeat, signingIn in
                username.isValid && password.isValid && passwordRepeat.isValid && !signingIn
            }.distinctUntilChanged()
            .shareReplay(1)
    }
}
