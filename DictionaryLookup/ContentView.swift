//
//  ContentView.swift
//  DictionaryLookup
//
//  Created by warbo on 7/6/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var dict = DictionaryViewModel()
    @State private var searchText = ""
    // 1. 📻 "Dò đài" lấy modelContext để ra lệnh Thêm/Xóa
    @Environment(\.modelContext) private var context
    // 2. 🔍 Lấy danh sách từ đã lưu dưới ổ cứng lên để kiểm tra trạng thái Trùng
    @Query private var favoriteWords: [FavoriteWord]
    // 3. Hàm Helper kiểm tra xem từ hiện tại đã được lưu hay chưa
    private var isSaved: Bool {
        favoriteWords.contains {$0.word.lowercased() == dict.wordResult.lowercased()}
        
    }
    

    var body: some View {
        NavigationStack{
                if dict.isLoading{
                    VStack{
                        ProgressView("Loading Word Definitions...")
                            .scaleEffect(1.5)
                    }
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                }else if let error = dict.errorMessage{
                    Text(error).foregroundColor(.red)
                }else{
                    VStack(alignment:.leading){
                        ScrollView(showsIndicators: false){
                            if !dict.formatedDefinitions.isEmpty{
                                VStack(alignment:.leading){
                                    HStack{
                                        Text("Definition")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .padding(.leading)
                                            
                                        Spacer()
                                    }
                                    HStack{
                                        Text(dict.wordResult)
                                            .font(.system(size: 28,weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Button{
                                            toggleFavorite()
                                        }label: {
                                            Image(systemName: isSaved ? "star.fill" : "star")
                                                .foregroundColor(isSaved ? .yellow : .gray)
                                                .font(.title2)
                                        }
                                        .padding(.leading,8)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.top)
                                    
                                }
                            }
                            
                            VStack(alignment:.leading){
                                ForEach(dict.formatedDefinitions, id:\.self){ def in
                                    HStack(alignment:.top,spacing: 12){
                                        if !def.partOfSpeech.isEmpty{
                                            Text(def.partOfSpeech)
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.blue)
                                                .padding(.all,6)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(Circle())
                                            
                                        }
                                        
                                        Text(def.text)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity,alignment: .leading)// Đảm bảo các Card luôn giãn rộng bằng nhau
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        
                    }
                    .padding(.horizontal,8)
                    Spacer()
                    .navigationTitle("Oxford Dictionary")
                }
            
            
            
        }
        .searchable(text: $searchText,prompt: "Type your word to search")
        .onSubmit(of: .search) {
            Task{
                await dict.fetchWord(keyword: searchText)
            }
            
        }
        .onChange(of: isSaved){
            print(isSaved)
        }
        // Task
        
    }
    // 🪄 4. Hàm xử lý logic Thêm / Xóa dữ liệu dưới ổ cứng
    private func toggleFavorite(){
        let currentWord = dict.wordResult.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentWord.isEmpty else{
            return
        }
        if isSaved {
            if let wordToDelete = favoriteWords.first(where: {$0.word.lowercased() == dict.wordResult.lowercased()}){
                context.delete(wordToDelete)
            }
        }else{
            // Lệnh THÊM: Gộp các định nghĩa thành một chuỗi duy nhất để lưu trữ
            let allDefs = dict.formatedDefinitions.map{ "\($0.partOfSpeech)\t\($0.text)"}.joined(separator: "\n")
            
            // Khởi tạo đối tượng Model mới
            let newFavorite = FavoriteWord(word: currentWord, partOfSpeech: "Multiple", definition: allDefs)
            
            // Ghi vào bản nháp context
            context.insert(newFavorite)
        }
    }
    
}

#Preview {
    ContentView()
}
