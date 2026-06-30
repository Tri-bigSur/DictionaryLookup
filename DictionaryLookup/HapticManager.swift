//
//  HapticManager.swift
//  DictionaryLookup
//
//  Created by warbo on 30/6/26.
//

import SwiftUI
import UIKit
// HapticManager giúp tạo phản hồi xúc giác chuyên nghiệp cho ứng dụng SwiftUI
class HapticManager{
    static let shared = HapticManager()
    private init(){}
    // Hàm tạo hiệu ứng rung theo độ mạnh nhẹ
        /// - Parameter style: Kiểu rung (light, medium, heavy, success, warning, error)
    func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    // Hàm chuyên biệt cho các hành động thành công (kêu nhẹ nhưng dứt khoát)
    func playSuccess(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
