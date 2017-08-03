//
//  ViewController.swift
//  RxCalculator
//
//  Created by MaxChen on 03/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var labelLastSign: UILabel!
    @IBOutlet weak var labelResult: UILabel!
    
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSign: UIButton!
    @IBOutlet weak var buttonPercent: UIButton!
    @IBOutlet weak var buttonEqual: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonMultiply: UIButton!
    @IBOutlet weak var buttonDivide: UIButton!
    @IBOutlet weak var buttonDot: UIButton!
    @IBOutlet weak var buttonZero: UIButton!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!
    @IBOutlet weak var buttonSix: UIButton!
    @IBOutlet weak var buttonSeven: UIButton!
    @IBOutlet weak var buttonEight: UIButton!
    @IBOutlet weak var buttonNine: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commands: Observable<CalculatorCommand> = Observable.merge([
            buttonClear.rx.tap.map { _ in .clear },
            buttonSign.rx.tap.map { _ in .changeSign },
            buttonPercent.rx.tap.map { _ in .percent },
            buttonEqual.rx.tap.map { _ in .equal },
            buttonPlus.rx.tap.map { _ in .operation(.addition) },
            buttonMinus.rx.tap.map { _ in .operation(.subtraction) },
            buttonMultiply.rx.tap.map { _ in .operation(.multiplication) },
            buttonDivide.rx.tap.map { _ in .operation(.division) },
            buttonDot.rx.tap.map { _ in .addDot },
            buttonZero.rx.tap.map { _ in .addNumber("0") },
            buttonOne.rx.tap.map { _ in .addNumber("1") },
            buttonTwo.rx.tap.map { _ in .addNumber("2") },
            buttonThree.rx.tap.map { _ in .addNumber("3") },
            buttonFour.rx.tap.map { _ in .addNumber("4") },
            buttonFive.rx.tap.map { _ in .addNumber("5") },
            buttonSix.rx.tap.map { _ in .addNumber("6") },
            buttonSeven.rx.tap.map { _ in .addNumber("7") },
            buttonEight.rx.tap.map { _ in .addNumber("8") },
            buttonNine.rx.tap.map { _ in .addNumber("9") }
            ])
        
        let system = Observable<CalculatorState>.deferred {
            return Observable.merge(commands)
                .observeOn(MainScheduler.instance)
                .scan(CalculatorState.initial, accumulator: CalculatorState.reduce)
                .startWith(CalculatorState.initial)
        }.share()
        
        system.map { $0.screen }
            .bind(to: labelResult.rx.text)
            .disposed(by: disposeBag)
        
        system.map { $0.sign }
            .bind(to: labelLastSign.rx.text)
            .disposed(by: disposeBag)
    }
}

