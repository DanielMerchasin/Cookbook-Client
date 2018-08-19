import Foundation

public class Ingredient {
    
    var name: String! = nil
    var quantity: Double = 1
    var unit: MeasurementUnit = .unit
    var mandatory: Bool = true
    
    init() {}
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    convenience init(json: [String:Any]) {
        self.init(name: json["name"] as! String)
        self.quantity = json["quantity"] as! Double
        self.mandatory = json["mandatory"] as! Bool
        self.unit = MeasurementUnit.valueOf(json["unit"] as! String)
    }
    
    public func toDictionary() -> [String:Any] {
        return [
            "name" : name,
            "quantity" : quantity,
            "mandatory" : mandatory,
            "unit" : unit.rawValue
        ]
    }
    
}
