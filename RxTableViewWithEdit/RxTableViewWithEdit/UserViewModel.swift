//
//  UserViewModel.swift
//  RxTableViewWithEdit
//
//  Created by MaxChen on 05/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import RxSwift
import RxCocoa

enum UserViewModelCommand {
    case setUsers(users: [UserModel])
    case setFavoriteUsers(favoriteUsers: [UserModel])
    case deleteUser(indexPath: IndexPath)
    case moveUser(from: IndexPath, to: IndexPath)
}

class UserViewModel {
    var favoriteUsers: [UserModel]
    var users: [UserModel]
    
    static func executeCommand(state: UserViewModel, _ command: UserViewModelCommand) -> UserViewModel {
        switch command {
        case let .setUsers(users):
            return UserViewModel.init(favoriteUsers: state.favoriteUsers, users: users)
        case let .setFavoriteUsers(favoriteUsers):
            return UserViewModel.init(favoriteUsers: favoriteUsers, users: state.users)
        case let .deleteUser(indexPath):
            var all = [state.favoriteUsers, state.users]
            all[indexPath.section].remove(at: indexPath.row)
            return UserViewModel.init(favoriteUsers: all[0], users: all[1])
        case let .moveUser(from, to):
            var all = [state.favoriteUsers, state.users]
            let user = all[from.section][from.row]
            all[from.section].remove(at: from.row)
            all[to.section].insert(user, at: to.row)
            return UserViewModel.init(favoriteUsers: all[0], users: all[1])
        }
    }
    
    init() {
        self.favoriteUsers = []
        self.users = []
    }
    
    init(favoriteUsers: [UserModel], users: [UserModel]) {
        self.favoriteUsers = favoriteUsers
        self.users = users
    }
}
