//
//  Calculator.swift
//  RxCalculator
//
//  Created by MaxChen on 03/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

enum Operator {
    case addition
    case subtraction
    case multiplication
    case division
    
    var sign: String {
        switch self {
        case .addition:
            return "+"
        case .subtraction:
            return "-"
        case .multiplication:
            return "x"
        case .division:
            return "/"
        }
    }
    
    var perform: (Double, Double) -> Double {
        switch self {
        case .addition:
            return (+)
        case .subtraction:
            return (-)
        case .multiplication:
            return (*)
        case .division:
            return (/)
        }
    }
}

private extension String {
    var doubleValue: Double {
        guard let double = Double(self) else {
            return Double.infinity
        }
        return double
    }
    
}

enum CalculatorCommand {
    case clear
    case changeSign
    case percent
    case operation(Operator)
    case equal
    case addNumber(Character)
    case addDot
}

enum CalculatorState {
    case oneOperand(screen: String)
    case oneOperandAndOperator(operand: Double, operator: Operator)
    case twoOperandsAndOperator(operand: Double, operator: Operator, screen: String)

    static let initial = CalculatorState.oneOperand(screen: "0")
    
    func mapScreen(transform: (String) -> String) -> CalculatorState {
        switch self {
        case let .oneOperand(screen):
            return .oneOperand(screen: transform(screen))
        case let .oneOperandAndOperator(operand, operat):
            return .twoOperandsAndOperator(operand: operand, operator: operat, screen: transform("0"))
        case let .twoOperandsAndOperator(operand, operat, screen):
            return .twoOperandsAndOperator(operand: operand, operator: operat, screen: transform(screen))
        }
    }
    
    var screen: String {
        switch self {
        case let .oneOperand(screen):
            return screen
        case .oneOperandAndOperator:
            return "0"
        case let .twoOperandsAndOperator(_, _, screen):
            return screen
        }
    }
    
    var sign: String {
        switch self {
        case .oneOperand:
            return ""
        case let .oneOperandAndOperator(_, o):
            return o.sign
        case let .twoOperandsAndOperator(_, o, _):
            return o.sign
        }
    }
    
    static func reduce(state: CalculatorState, _ x: CalculatorCommand) -> CalculatorState {
        switch x {
        case .clear:
            return CalculatorState.initial
        case .addNumber(let c):
            return state.mapScreen { $0 == "0" ? String(c) : $0 + String(c) }
        case .addDot:
            return state.mapScreen { $0.range(of: ".") == nil ? $0 + "." : $0 }
        case .changeSign:
            return state.mapScreen { "\(-(Double($0) ?? 0.0))" }
        case .percent:
            return state.mapScreen { "\((Double($0) ?? 0.0) / 100.0)" }
        case .operation(let o):
            switch state {
            case let .oneOperand(screen):
                return .oneOperandAndOperator(operand: screen.doubleValue, operator: o)
            case let .oneOperandAndOperator(operand, _):
                return .oneOperandAndOperator(operand: operand, operator: o)
            case let .twoOperandsAndOperator(operand, oldOperator, screen):
                return .twoOperandsAndOperator(operand: oldOperator.perform(operand, screen.doubleValue), operator: o, screen: "0")
            }
        case .equal:
            switch state {
            case let .twoOperandsAndOperator(operand, operat, screen):
                let result = operat.perform(operand, screen.doubleValue)
                return .oneOperand(screen: String(result))
            default:
                return state
            }
        }
    }
}
