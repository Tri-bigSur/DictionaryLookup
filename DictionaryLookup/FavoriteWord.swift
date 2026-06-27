//
//  FavoriteWord.swift
//  DictionaryLookup
//
//  Created by warbo on 10/6/26.
//

import Foundation
import SwiftData

@Model
final class WordFolder{
    @Attribute(.unique) var name : String
    var createdAt: Date
    // 🎯 THIẾT LẬP MỐI QUAN HỆ: Một Thư mục chứa Nhiều từ vựng
        // deleteRule: .cascade nghĩa là khi xóa Thư mục này, toàn bộ các từ nằm trong nó sẽ tự động bị xóa theo vĩnh viễn khỏi ổ cứng!
    @Relationship(deleteRule:.cascade,inverse: \FavoriteWord.folder)
    var words: [FavoriteWord]? = []
    init(name: String) {
        self.name = name
        self.createdAt = Date.now
        self.words = []
    }
}

@Model
final class FavoriteWord{
    @Attribute(.unique) var word : String
    var partOfSpeech: String
    var definition: String
    var addedDate: Date
    // 🎯 THIẾT LẬP MỐI QUAN HỆ NGƯỢC: Một từ vựng thuộc về Một thư mục duy nhất
    // Thuộc tính này là Optional vì đôi khi từ vựng không nằm trong thư mục nào (Uncategorized)
    var folder: WordFolder?
    init(word: String, partOfSpeech: String, definition: String, addedDate: Date = .now, folder: WordFolder? = nil) {
        self.word = word
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.addedDate = addedDate
        self.folder = folder
    }
    
    @Transient
    var unpackedDefinitions: [FormattedDefinition] {
        let lines = definition.components(separatedBy: "\n")
        
        var result: [FormattedDefinition] = []
        
        for line in lines {
            let parts = line.components(separatedBy: "\t")
            if parts.count >= 2{
                let formatted = FormattedDefinition(partOfSpeech: parts[0], text: parts[1])
                result.append(formatted)
            }else if !line.isEmpty {
                let formatted = FormattedDefinition(partOfSpeech: "", text: line)
                result.append(formatted)
            }
        }
        return result
        
        
    }
    
}
