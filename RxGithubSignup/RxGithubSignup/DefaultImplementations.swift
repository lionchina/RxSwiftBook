//
//  DefaultImplementations.swift
//  RxGithubSignup
//
//  Created by MaxChen on 06/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import RxSwift
import Foundation

class GitHubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI
    static let sharedValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)
    init(API: GitHubAPI) {
        self.API = API
    }
    
    let minPasswordCount = 5
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.characters.count == 0 {
            return .just(.empty)
        }
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        let loadingValue = ValidationResult.validating
        return API.usernameAvailable(username)
            .map { available in
                if available {
                    return .ok(message: "Username available")
                } else {
                    return .failed(message: "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        return .ok(message: "Password acceptable")
    }
    
    func validatePasswordRepeat(_ password: String, passwordRepeat: String) -> ValidationResult {
        if passwordRepeat.characters.count == 0 {
            return .empty
        }
        if passwordRepeat == password {
            return .ok(message: "Password repeated")
        } else {
            return .failed(message: "Password different")
        }
    }
}

class GitHubDefaultAPI: GitHubAPI {
    let urlSession: URLSession
    static let sharedAPI = GitHubDefaultAPI(urlSession: URLSession.shared)
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return self.urlSession.rx.response(request: request)
            .map { (response, _) in
                return response.statusCode == 404
            }
            .catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : true
        return Observable.just(signupResult).delay(1.0, scheduler: MainScheduler.instance)
    }
}

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
