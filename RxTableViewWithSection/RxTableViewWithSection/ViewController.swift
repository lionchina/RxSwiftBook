//
//  ViewController.swift
//  RxTableViewWithSection
//
//  Created by MaxChen on 04/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableviewData: UITableView!
    
    let disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource
        let items = Observable.just([
            SectionModel(model: "First section", items: [1.0, 2.0, 3.0]),
            SectionModel(model: "Second section", items: [2.0, 3.0, 4.0]),
            SectionModel(model: "Third section", items: [3.0, 4.0, 5.0])])
        dataSource.configureCell = { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        }
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
        items.bind(to: tableviewData.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableviewData.rx.itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { indexPath, model in
                print("Tapped \(model) @ row \(indexPath)")
            })
            .disposed(by: disposeBag)
        tableviewData.rx.setDelegate(self).disposed(by: disposeBag)
    }
}
