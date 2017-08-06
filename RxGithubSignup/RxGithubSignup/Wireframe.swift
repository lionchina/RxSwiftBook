//
//  Wireframe.swift
//  RxGithubSignup
//
//  Created by MaxChen on 06/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import RxSwift
import UIKit

enum RetryResult {
    case retry
    case cancel
    
    var description: String {
        switch self {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        }
    }
}

protocol Wireframe {
    func open(url: URL)
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}

class DefaultWireframe: Wireframe {
    static let shared = DefaultWireframe()
    
    func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private static func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    static func presentAlert(_ message: String) {
        let alertView = UIAlertController(title: "RxSwiftBook", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        rootViewController().present(alertView, animated: true, completion: nil)
    }
    
    func promptFor<Action>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> where Action : CustomStringConvertible {
        return Observable.create { observer in
            let alertView = UIAlertController(title: "RxSwiftBook", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                observer.on(.next(cancelAction))
            })
            for action in actions {
                alertView.addAction(UIAlertAction(title: actions.description, style: .default) { _ in
                    observer.on(.next(action))
                })
            }
            DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)
            return Disposables.create {
                alertView.dismiss(animated: false, completion: nil)
            }
        }
    }
}
