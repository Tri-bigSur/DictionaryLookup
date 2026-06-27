//
//  DictionaryViewModel.swift
//  DictionaryLookup
//
//  Created by warbo on 7/6/26.
//

import Foundation
import Observation

@Observable
class DictionaryViewModel{
    var errorMessage: String? = nil
    var isLoading = false
    var formatedDefinitions: [FormattedDefinition] = []
    var wordResult: String = ""
    
    
    func fetchWord(keyword: String)async{
        isLoading = true
        errorMessage = nil
        formatedDefinitions = []
        wordResult = ""
        
        // Tránh user bấm search khoảng trắng vô ích
        let cleanedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedKeyword.isEmpty else{
            isLoading = false
            return
            
        }
        
        // 1. Tạo URLComponents với đường dẫn gốc
        guard var components = URLComponents(string: "https://api.datamuse.com/words")else{
            errorMessage = "The Root Link Get Error !"
            isLoading = false
            return
        }
        // 2. Lắp ráp Query Parameters
        components.queryItems = [
            URLQueryItem(name: "sp", value: cleanedKeyword),
            URLQueryItem(name: "md", value: "d")
        ]
        // Lấy URL hoàn chỉnh từ components
        guard let finalURL = components.url else{
            errorMessage = "ERROR: Composing URL with query parameters !"
            isLoading = false
            return
        }
        print("Đang gọi API tới: \(finalURL.absoluteString)")
                
        // 3. Gọi mạng và Decode
        do{
            let (data,response) = try await URLSession.shared.data(from: finalURL)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                throw URLError(.badServerResponse)
            }
            let decodedWords = try JSONDecoder().decode([WordDefinition].self, from: data)
            await MainActor.run{
                if let firstResult = decodedWords.first{
                    self.wordResult = firstResult.word
                    let rawDefs = firstResult.defs ?? ["\tCouldn't Find Any Difinitions"]
                    self.formatedDefinitions = rawDefs.map{ rawString in
                        let parts = rawString.components(separatedBy: "\t")
                        if parts.count >= 2 {
                            return FormattedDefinition(partOfSpeech: parts[0], text: parts[1])
                        }else{
                            return FormattedDefinition(partOfSpeech: "", text: rawString)
                        }
                        
                    }
                }else{
                    // Trường hợp gõ từ linh tinh Server không tìm ra kết quả
                    self.errorMessage = "No Results Found For '\(cleanedKeyword)'"
                }
                self.isLoading = false
            }
//            print(decodedWords)
            
        }catch{
            await MainActor.run{
                self.errorMessage = "Network Error: \(error.localizedDescription)"
                self.isLoading = false
            }
            
        }
        
        
        
    }
    
}



struct WordDefinition: Codable {
    var word: String
    var defs: [String]?
}

struct FormattedDefinition: Identifiable, Hashable{
    let id = UUID()
    let partOfSpeech: String
    let text: String
}

