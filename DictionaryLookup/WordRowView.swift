//
//  StructRowView.swift
//  DictionaryLookup
//
//  Created by warbo on 13/6/26.
//

import SwiftUI

struct StructRowView: View {
    let favoriteItem: FavoriteWord
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment:.leading,spacing: 8){
            // --- PHẦN HEADER (Luôn hiển thị) ---
            
            HStack{
                Text(favoriteItem.word)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                
                Text(favoriteItem.addedDate.formatted(.dateTime.day().month()))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .padding(.leading,4)
                
            }
            // Biến toàn bộ khu vực Header thành nút bấm tàng hình
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4,dampingFraction: 0.7)){
                    isExpanded.toggle()
                }
            }
            // --- PHẦN CHI TIẾT (Chỉ hiện khi isExpanded == true) ---
            if isExpanded{
                VStack{
                    Divider()
                    ForEach(favoriteItem.unpackedDefinitions){def in
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
                // Hiệu ứng xuất hiện mờ dần
                .transition(.opacity.combined(with: .move(edge: .top)))
                
                
            }
        }
        .padding(.vertical,4)
        
        
        
    }
}

#Preview {
    StructRowView(favoriteItem: FavoriteWord(word: "Meticulous", partOfSpeech: "adj", definition: "Meticulous is an adjective that means showing extreme care, precision, and attention to detail. Someone or something that is meticulous is incredibly thorough, ensuring that no minor point is overlooked or left imperfect"))
}
