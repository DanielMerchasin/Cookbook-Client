import Foundation

public enum MeasurementUnit: String {
    
    case cup = "CUP"
    case teaspoon = "TSP"
    case tablespoon = "TBSP"
    case gram = "GRAM"
    case liter = "LITER"
    case ounce = "OZ"
    case unit = "UNIT"
    
    public static func valueOf(_ s: String) -> MeasurementUnit {
        if let unit = MeasurementUnit(rawValue: s.uppercased()) {
            return unit
        }
        return .unit
    }
    
    public static func values() -> [MeasurementUnit] {
        return [
            .cup,
            .teaspoon,
            .tablespoon,
            .gram,
            .liter,
            .ounce,
            .unit
        ]
    }
    
    public func ordinal() -> Int {
        switch self {
        case .cup:
            return 0
        case .teaspoon:
            return 1
        case .tablespoon:
            return 2
        case .gram:
            return 3
        case .liter:
            return 4
        case .ounce:
            return 5
        case .unit:
            return 6
        }
    }
    
    public func description() -> String {
        switch self {
        case .cup:
            return "Cups"
        case .teaspoon:
            return "Teaspoons"
        case .tablespoon:
            return "Tablespoons"
        case .gram:
            return "Grams"
        case .liter:
            return "Liters"
        case .ounce:
            return "Ounces"
        case .unit:
            return "Units"
        }
    }
    
}
