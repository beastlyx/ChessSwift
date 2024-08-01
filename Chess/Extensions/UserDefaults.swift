import SwiftUI

extension UserDefaults {
    func color(forKey key: String) -> Color? {
        guard let data = data(forKey: key),
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return nil
        }
        return Color(uiColor)
    }
    
    func set(_ color: Color, forKey key: String) {
        let uiColor = UIColor(color)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) else {
            return
        }
        set(data, forKey: key)
    }
}
