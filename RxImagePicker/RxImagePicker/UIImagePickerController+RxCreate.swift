//
//  UIImagePickerController+RxCreate.swift
//  RxImagePicker
//
//  Created by MaxChen on 03/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

extension Reactive where Base: UIImagePickerController {
    public var didFinishPickingMediaWithInfo: Observable<[String: AnyObject]> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map({ (a) in
                return try castOrThrow(Dictionary<String, AnyObject>.self, a[1])
            })
    }
    
    public var didCancel: Observable<()> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map { _ in () }
    }
    
    static func createWithParent(_ parent: UIViewController?, animated: Bool = true, configureImagePicker: @escaping (UIImagePickerController) throws -> () = { x in }) -> Observable<UIImagePickerController> {
        return Observable.create{ [weak parent] observer in
            let imagePicker = UIImagePickerController()
            let dismissDisposable = imagePicker.rx.didCancel
                .subscribe(onNext: { [weak imagePicker] in
                    guard let imagePicker = imagePicker else {
                        return
                    }
                    dismissViewController(imagePicker, animated: animated)
                })
            do {
                try configureImagePicker(imagePicker)
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            parent.present(imagePicker, animated: animated, completion: nil)
            observer.on(.next(imagePicker))
            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(imagePicker, animated: animated)
            })
        }
    }
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
