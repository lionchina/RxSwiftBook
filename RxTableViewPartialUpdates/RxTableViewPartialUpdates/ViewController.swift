//
//  ViewController.swift
//  RxTableViewPartialUpdates
//
//  Created by MaxChen on 05/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    
    @IBOutlet weak var tableviewPartialUpdates: UITableView!
    @IBOutlet weak var tableviewReload: UITableView!
    @IBOutlet weak var collectionviewPartialUpdates: UICollectionView!
    
    static let initialValue: [AnimatableSectionModel<String, Int>] = [
        NumberSection(model: "section 1", items: [1, 2, 3]),
        NumberSection(model: "section 2", items: [4, 5, 6]),
        NumberSection(model: "section 3", items: [7, 8, 9]),
        NumberSection(model: "section 4", items: [10, 11, 12]),
        NumberSection(model: "section 5", items: [13, 14, 15]),
        NumberSection(model: "section 6", items: [16, 17, 18]),
        NumberSection(model: "section 7", items: [19, 20, 21]),
        NumberSection(model: "section 8", items: [22, 23, 24]),
        NumberSection(model: "section 9", items: [25, 26, 27]),
        NumberSection(model: "section 10", items: [28, 29, 30])]
    
    static let firstChange: [AnimatableSectionModel<String, Int>]? = nil
    
    var generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: initialValue)
    
    var sections = Variable([NumberSection]())
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sections.value = generator.sections
        let tvAnimatedDataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let tvReloadDataSource = RxTableViewSectionedReloadDataSource<NumberSection>()
        
        skinTableViewDataSources(tvAnimatedDataSource)
        skinTableViewDataSources(tvReloadDataSource)
        
        self.sections.asObservable()
            .bind(to: tableviewPartialUpdates.rx.items(dataSource: tvAnimatedDataSource))
            .disposed(by: disposeBag)
        
        self.sections.asObservable()
            .bind(to: tableviewReload.rx.items(dataSource: tvReloadDataSource))
            .disposed(by: disposeBag)
        
        let cvReloadDataSource = RxCollectionViewSectionedReloadDataSource<NumberSection>()
        skinCollectionViewDataSource(cvReloadDataSource)
        self.sections.asObservable()
            .bind(to: collectionviewPartialUpdates.rx.items(dataSource: cvReloadDataSource))
            .disposed(by: disposeBag)
        
        collectionviewPartialUpdates.rx.itemSelected
            .subscribe(onNext: { [weak self] i in
                print("\(String(describing: self?.generator.sections[i.section].items[i.item]))")
            })
            .disposed(by: disposeBag)
        Observable.of(tableviewPartialUpdates.rx.itemSelected, tableviewReload.rx.itemSelected)
            .merge()
            .subscribe(onNext: { [weak self] i in
                print("\(String(describing: self?.generator.sections[i.section].items[i.item]))")
            })
            .disposed(by: disposeBag)
    }
    
    func skinTableViewDataSources(_ dataSource: TableViewSectionedDataSource<NumberSection>) {
        dataSource.configureCell = { (_, tv, ip, i) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel!.text = "\(i)"
            return cell
        }
        dataSource.titleForHeaderInSection = { (ds, section: Int) -> String in
            return dataSource[section].model
        }
    }
    
    func skinCollectionViewDataSource(_ dataSource: CollectionViewSectionedDataSource<NumberSection>) {
        dataSource.configureCell = { (_, cv, ip, i) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "Cell", for: ip) as! NumberCell
            cell.labelValue!.text = "\(i)"
            return cell
        }
        dataSource.supplementaryViewFactory = { (dataSource, cv, kind, ip) in
            let section = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: ip) as! NumberSectionView
            section.labelValue!.text = "\(dataSource[ip.section].model)"
            return section
        }
    }

    @IBAction func randomize(_ sender: Any) {
        generator.randomize()
        var values = generator.sections
        
        if ViewController.firstChange != nil {
            values = ViewController.firstChange!
        }
        
        sections.value = values
    }
}

