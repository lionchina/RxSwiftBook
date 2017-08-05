//
//  ViewController.swift
//  RxTableViewWithEdit
//
//  Created by MaxChen on 05/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableviewData: UITableView!
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, UserModel>>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        dataSource.configureCell = { (_, tv, ip, user: UserModel) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = user.debugDescription
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
        
        dataSource.canEditRowAtIndexPath = { (ds, ip) in
            return true
        }
        
        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let superMan = UserModel(firstName: "Super", lastName: "Man")
        let watMan = UserModel(firstName: "Wat", lastName: "Man")
        let greenMan = UserModel(firstName: "Green", lastName: "Man")
        let loadUsers = Observable.just(UserViewModelCommand.setUsers(users: [greenMan]))
        let initialLoadCommand = Observable.just(UserViewModelCommand.setFavoriteUsers(favoriteUsers: [superMan, watMan]))
            .concat(loadUsers)
            .observeOn(MainScheduler.instance)
        let deleteUserCommand = tableviewData.rx.itemDeleted
            .map(UserViewModelCommand.deleteUser)
        let moveUserCommand = tableviewData.rx.itemMoved
            .map(UserViewModelCommand.moveUser)
        let initialState = UserViewModel(favoriteUsers: [], users: [])

        let viewModel = Observable<UserViewModel>.deferred {
            return Observable.merge(initialLoadCommand, deleteUserCommand, moveUserCommand)
                .observeOn(MainScheduler.instance)
                .scan(initialState, accumulator: UserViewModel.executeCommand)
                .startWith(initialState)
        }.shareReplay(1)
        
        viewModel.map {
            [SectionModel(model: "Favorite Users", items: $0.favoriteUsers),
             SectionModel(model: "Normal Users", items: $0.users)]
            }.bind(to: tableviewData.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableviewData.rx.itemSelected
            .withLatestFrom(viewModel) { i, viewModel in
                let all = [viewModel.favoriteUsers, viewModel.users]
                return all[i.section][i.row]
            }.subscribe(onNext: { [weak self] user in
                self?.alertMessage(user: user)
            })
            .disposed(by: disposeBag)
        tableviewData.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func alertMessage(user: UserModel) {
        let alert: UIAlertController = UIAlertController(title: "RxTableViewWithEdit", message: "\(user)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableviewData.isEditing = editing
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource[section]
        let label = UILabel(frame: CGRect.zero)
        label.text = " \(title)"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.darkGray
        label.alpha = 0.9
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

