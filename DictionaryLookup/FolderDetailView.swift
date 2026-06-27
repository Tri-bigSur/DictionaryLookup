//
//  FolderDetailView.swift
//  DictionaryLookup
//
//  Created by warbo on 17/6/26.
//

import SwiftUI
import SwiftData

struct FolderDetailView: View {
    let folder: WordFolder
    // 👉 Gọi tất cả thư mục lên để làm danh sách điểm đến cho Popup Move
    @Query(sort: \WordFolder.createdAt,order: .reverse) private var allFolders: [WordFolder]
    // Các biến phục vụ Move Mode y hệt như bên ngoài
    @State private var isSelectionMode = false
    @State private var selectedWordIDs: Set<PersistentIdentifier> = []
    @State private var isShowingMoveOptions = false
    
    
    @Environment(\.modelContext) private var context
    var body: some View {
        Group{
            let wordsInFolder = folder.words ?? []
            
            if !wordsInFolder.isEmpty{
                List{
                    ForEach(wordsInFolder){ word in
                        if isSelectionMode {
                            HStack{
                                Image(systemName: selectedWordIDs.contains(word.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedWordIDs.contains(word.persistentModelID) ? .blue : .gray)
                                    .font(.title3)
                                
                                WordRowView(item: word)
                                    .opacity(0.6)
                                    .disabled(true)
                            }
                            .padding(.vertical,2)
                            .contentShape(Rectangle())
                            .onTapGesture{
                                toggleSelection(for: word)
                            }
                            
                            
                        }else{
                            WordRowView(item: word)
                        }
                    }
                    .onDelete(perform: deleteWordFromFolder)
                }
            }else{
                ContentUnavailableView(
                    "Folder is Empty",
                    systemImage: "book.pages",
                    description: Text("Add word to this folder to see them here.")
                    
                )
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            if let words = folder.words, !words.isEmpty{
                ToolbarItem(placement: .navigationBarLeading){
                    Button(isSelectionMode ? "Cancel" : "Select"){
                        withAnimation{
                            isSelectionMode.toggle()
                            if !isSelectionMode{
                                selectedWordIDs.removeAll()
                            }
                        }
                    }
                }
                // Nút Move (Chỉ hiện khi đang ở chế độ Select)
                ToolbarItem(placement: .navigationBarTrailing){
                    if isSelectionMode{
                        Button("Move"){
                            isShowingMoveOptions = true
                        }
                        .disabled(selectedWordIDs.isEmpty)
                    }
                    
                }
            }
        }
        // 👉 POPUP CHỌN NƠI CHUYỂN ĐẾN
        .confirmationDialog("Move Selected Words",isPresented: $isShowingMoveOptions, titleVisibility: .visible){
            // Lựa chọn 1: Bỏ ra ngoài (Gán folder = nil)
            Button("Remove From Folder", role: .destructive){
                moveWords(to: nil)
            }
            // Lựa chọn 2: Chuyển sang thư mục khác
                        // (Dùng filter để ẩn cái Thư mục hiện tại đi, tránh việc chuyển từ thư mục A sang chính thư mục A)
            let otherFolders = allFolders.filter{$0.persistentModelID != folder.persistentModelID}
            ForEach(otherFolders){ targetFolder in
                Button("Move to \(targetFolder.name)"){
                    moveWords(to: targetFolder)
                }
                
            }
            Button("Cancel",role: .cancel){}
            
        }message: {
            Text("Where do you want to move \(selectedWordIDs.count) words ?")
        }
        
    }
    // MARK: -  HELPER FUNCTIONS
    
    // MARK: - Logic Xử Lý trong Folder
    private func toggleSelection(for word: FavoriteWord){
        let id = word.persistentModelID
        if selectedWordIDs.contains(id){
            selectedWordIDs.remove(id)
        }else{
            selectedWordIDs.insert(id)
        }
    }
    // Truyền nil nếu muốn "Remove out of folder"
    private func moveWords(to targetFolder: WordFolder?){
        guard let words = folder.words else { return }
        withAnimation {
            for word in words where selectedWordIDs.contains(word.persistentModelID){
                word.folder = targetFolder
            }
            selectedWordIDs.removeAll()
            isSelectionMode = false
        }
        
    }
    
    
    
    private func deleteWordFromFolder(at offsets: IndexSet){
        guard let words = folder.words else { return }
        for index in offsets{
            let wordToDelete = words[index]
            context.delete(wordToDelete)
            // LƯU Ý: Vì có @Relationship inverse, khi xoá từ vựng, SwiftData tự biết gỡ nó khỏi thư mục!
        }
    }
}

#Preview {
    FolderDetailView(folder: WordFolder(name: "Technology"))
}
