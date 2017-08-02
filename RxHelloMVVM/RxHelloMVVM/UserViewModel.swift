//
//  UserViewModel.swift
//  RxExample
//
//  Created by 陈秀鹏 on 2017/7/29.
//  Copyright © 2017年 com.linglustudio. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserViewModel {
    let username = Variable("")
    let greetingUser: Observable<String>
    init() {
        greetingUser = username.asObservable()
            .map { "Hello, " + $0 }
    }
}
