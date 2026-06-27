//
//  StructRowView.swift
//  DictionaryLookup
//
//  Created by warbo on 13/6/26.
//

import SwiftUI

struct WordRowView: View {
    let item: FavoriteWord
    @State private var isExpanded: Bool = false
    
    var body: some View {
        // Sử dụng DisclosureGroup của Apple thay vì tự code bằng tay
        DisclosureGroup(isExpanded:$isExpanded,content: {
            VStack(alignment:.leading,spacing:8){
                ForEach(item.unpackedDefinitions){def in
                    HStack(alignment:.top,spacing: 6){
                        if !def.partOfSpeech.isEmpty{
                            Text(def.partOfSpeech)
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.blue)
                                .padding(.horizontal,6)
                                .padding(.vertical,2)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        Text(def.text)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                    }
                    
                }
            }
            .padding(.top,4)
            .padding(.bottom,8)
        },label: {
            // --- PHẦN HEADER (Luôn hiển thị) ---
            HStack{
                Text(item.word)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                
                Text(item.addedDate.formatted(.dateTime.day().month()))
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
            // Biến toàn bộ khu vực Header thành nút bấm tàng hình
            .contentShape(Rectangle())
            
        })
        .tint(.gray)
            
            
        
    }
}

#Preview {
    WordRowView(item: FavoriteWord(word: "Meticulous", partOfSpeech: "adj", definition: "Meticulous is an adjective that means showing extreme care, precision, and attention to detail. Someone or something that is meticulous is incredibly thorough, ensuring that no minor point is overlooked or left imperfect"))
}
