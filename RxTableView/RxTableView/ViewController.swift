//
//  ViewController.swift
//  RxTableView
//
//  Created by MaxChen on 04/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableviewData: UITableView!

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let items = Observable.just((0..<20).map { "\($0)" })
        items.bind(to: tableviewData.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
            cell.textLabel?.text = "\(element) @ row \(row)"
        }.disposed(by: disposeBag)
        
        tableviewData.rx.modelSelected(String.self)
            .subscribe(onNext: { value in
                self.showAlert(message: "Tapped \(value)")
            }).disposed(by: disposeBag)
        
        tableviewData.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { indexPath in
                self.showAlert(message: "Tapped Detail @ \(indexPath.section), \(indexPath.row)")
            })
            .disposed(by: disposeBag)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "RxTableView", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

