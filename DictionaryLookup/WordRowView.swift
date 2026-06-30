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
                
//                Button{
//                    SpeechManager.shared.speak(text: item.word)
//                }label: {
//                    Image(systemName: "speaker.3.fill")
//                        .font(.system(size: 14))
//                        .foregroundColor(.white)
//                        .padding(.vertical,8)
//                        .padding(.horizontal,8)
//                        .background(Color.blue)
//                        .clipShape(Circle())
//                    // 👉 Bổ sung thêm contentShape để xác định vùng chạm là hình tròn khít với nút
//                        .contentShape(Circle())
//                }
//                // 👉 Áp dụng Style tạo hiệu ứng nhún và mờ đi khi bấm
//                .buttonStyle(BouncySpeakerStyle())
                PlayAudioButton(wordToSpeak: item.word)
                
                
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
// MARK: - Effect For ButtonStyle
struct BouncySpeakerStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        // Khi ngón tay đè lên (isPressed = true) -> Mờ đi một nửa
            .opacity(configuration.isPressed ? 0.5 : 1.0)
        // Khi ngón tay đè lên -> Thu nhỏ lại 20%
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
        // Lắp thêm chiếc lò xo (spring) quen thuộc để nút tự nảy về vị trí cũ
            .animation(.spring(response:0.3,dampingFraction: 0.6),value: configuration.isPressed)
        
        
    }
}

struct PlayAudioButton:View {
    let wordToSpeak: String
    @State private var isBouncing = false
    var body: some View {
        Image(systemName: "speaker.3.fill")
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.vertical,8)
            .padding(.horizontal,8)
            .background(Color.blue)
            .clipShape(Circle())
        
            .scaleEffect(isBouncing ? 0.75 : 1.0)
            .opacity(isBouncing ? 0.6 : 1.0)
        
            .highPriorityGesture(
                TapGesture()
                    .onEnded{ _ in
                        SpeechManager.shared.speak(text: wordToSpeak)
                        
                        withAnimation(.spring(response:0.15,dampingFraction:0.5)){
                            isBouncing = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15){
                            withAnimation(.spring(response:0.3,dampingFraction: 0.5)){
                                isBouncing = false
                            }
                        }
                        
                    }
            )
    }
}

#Preview {
    WordRowView(item: FavoriteWord(word: "Meticulous", partOfSpeech: "adj", definition: "Meticulous is an adjective that means showing extreme care, precision, and attention to detail. Someone or something that is meticulous is incredibly thorough, ensuring that no minor point is overlooked or left imperfect"))
}
