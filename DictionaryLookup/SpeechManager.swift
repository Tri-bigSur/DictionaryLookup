//
//  SpeechManager.swift
//  DictionaryLookup
//
//  Created by warbo on 29/6/26.
//

import Foundation
import AVFoundation

// Class này sẽ quản lý việc phát âm từ vựng
class SpeechManager{
    static let shared = SpeechManager() // Singleton pattern - dùng chung cho toàn bộ app
    private let synthesizer = AVSpeechSynthesizer()
    func speak(text: String, language: String = "en-US"){
        // 👉 KIỂM TRA & DỪNG: Nếu đang đọc thì bắt ngừng lại ngay lập tức (.immediate)
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // Tạo yêu cầu đọc văn bản
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5 // Tốc độ đọc: 0.5 là mức trung bình (khá tự nhiên)
        
        // Phát âm
        synthesizer.speak(utterance)
    }
    
}
