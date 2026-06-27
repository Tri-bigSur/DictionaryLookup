//
//  WordBookView.swift
//  DictionaryLookup
//
//  Created by warbo on 11/6/26.
//

import SwiftUI
import SwiftData
struct WordBookView: View {
    
    @Query(sort:\WordFolder.createdAt, order: .reverse) private var folders: [WordFolder]
    
    // 2. VŨ KHÍ MỚI (#Predicate): Chỉ lấy những từ vựng CHƯA có thư mục (folder == nil)
    @Query(filter: #Predicate<FavoriteWord>{word in word.folder == nil}, sort: \FavoriteWord.addedDate, order: .reverse ) private var uncategorizedWords: [FavoriteWord]
    
    // Lấy context ra để phục vụ tính năng xoá từ
    @Environment(\.modelContext) private var context
    
    // MARK: - States cho "Move Mode"
    // 1. Trạng thái bật/tắt chế độ chọn
    @State private var isSelectionMode = false
    // 2. Lưu trữ các ID của những từ vựng đang được check
    @State private var selectedWordIDs: Set<PersistentIdentifier> = []
    
    // States cho tạo Folder mới
    @State private var isShowingNewFolderAlert = false
    @State private var newFolderName = ""
    
    
    
    var body: some View {
        NavigationStack{
            // 2. Nếu trống lịch sử, hiển thị màn hình trống thông minh (iOS 17+)
                if folders.isEmpty && uncategorizedWords.isEmpty{
                    ContentUnavailableView("No Favorites Yet",systemImage: "book.pages",description: Text("Search for definitions and tap on ✩ icon to show them here."))
                    
                }else{
                    // 3. Sử dụng List để tối ưu giao diện danh sách
                    List{
                        // PHÂN KHU 1: DANH SÁCH THƯ MỤC
                        if !folders.isEmpty{
                            Section(header: Text("Folders")){
                                ForEach(folders){folder in
                                    // 👉 NẾU ĐANG Ở CHẾ ĐỘ CHỌN: Bấm vào Folder sẽ thực hiện lệnh "Move"
                                    if isSelectionMode && !selectedWordIDs.isEmpty{
                                        Button{
                                            moveSelectedWords(to: folder)
                                        }label:{
                                            FolderRowContent(folder: folder, isMoveTarget: true)
                                        }
                                    }else{
                                        
                                        NavigationLink(destination: FolderDetailView(folder: folder)){
                                            FolderRowContent(folder: folder, isMoveTarget: false)
                                        }
                                    }
                                } // Place Holder For onDelete
                                .onDelete(perform: isSelectionMode ? nil : {offsets in deleteFolder(at: offsets)}) // Khóa xóa khi đang chọn
                            }
                        }
                        
                        // PHÂN KHU 2: DANH SÁCH TỪ VỰNG TỰ DO
                        
                        if !uncategorizedWords.isEmpty{
                            Section(header:Text("Uncategorized Words")){
                                ForEach(uncategorizedWords){ item in
                                    if isSelectionMode{
                                        HStack{
                                            // Hiển thị vòng tròn Checkbox khi bật Selection Mode
                                        Image(systemName: selectedWordIDs.contains(item.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedWordIDs.contains(item.persistentModelID) ? .blue : .gray)
                                                .font(.title3)
                                            // Nếu đang trong chế độ chọn, View từ vựng bị làm mờ một chút và VÔ HIỆU HÓA tính năng xổ xuống
                                            WordRowView(item: item) // Dùng lại Component Accordion
                                                .opacity(selectedWordIDs.contains(item.persistentModelID) ? 0.6 : 1.0)
                                                .disabled(true) // Khóa tính năng Accordion
                                            
                                            
                                            
                                        }
                                        .padding(.vertical,2)
                                        // Cho phép bấm vào cả hàng để check nhanh
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            toggleSelection(for: item)
                                        }
                                    }else{
                                        // 2. KHI BÌNH THƯỜNG: Vứt bỏ HStack đi, để DisclosureGroup nằm trực tiếp trong List!
                                                                                // Giao diện sẽ mượt mà 100% như ở FolderDetailView.
                                        WordRowView(item: item)
                                        
                                    }
                                }
                                .onDelete(perform: deleteWord)
                            }
                        }
                        
                    }
                    
                    .navigationTitle("My dictionary")
                    .toolbar{
                        // Nút bên trái: Nút Select / Cancel
                        ToolbarItem(placement: .navigationBarLeading){
                            if !uncategorizedWords.isEmpty{
                                Button(isSelectionMode ? "Cancel" : "Select"){
                                    withAnimation{
                                        isSelectionMode.toggle()
                                        if !isSelectionMode{
                                            selectedWordIDs.removeAll() // Xóa lựa chọn khi Cancel
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Nút bên phải: Tạo thư mục MỚI
                        ToolbarItem(placement:.navigationBarTrailing){
                            if !isSelectionMode{
                                Button{
                                    isShowingNewFolderAlert = true
                                }label:{
                                    Image(systemName:"folder.badge.plus")
                                }
                            }else {
                                Button{
                                    isShowingNewFolderAlert = true
                                    
                                }label:{
                                    Image(systemName: "folder.badge.plus")
                                }
                                .disabled(selectedWordIDs.isEmpty)
                            }
                        }
                    }
                    .alert("New Folder",isPresented: $isShowingNewFolderAlert){
                        TextField("Folder Name",text: $newFolderName)
                        Button("Cancel",role: .cancel){newFolderName = ""}
                        Button("Create"){createNewFolder()}
                            .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                        
                    }message: {
                        Text("Enter a name for this vocabulary category.")
                    }
                    
                }
            
        }
        
       
    }
    // MARK: -  HELPER FUNCTIONS
    
    // MARK: - Logic Xử Lý "Move"
        
    // Hàm bật/tắt checkmark cho 1 từ
    func toggleSelection(for word: FavoriteWord){
        let id = word.persistentModelID
        if selectedWordIDs.contains(id){
            selectedWordIDs.remove(id)
        }else{
            selectedWordIDs.insert(id)
        }
        
    }
    
    
    // Hàm cốt lõi: Chuyển các từ đã chọn vào Thư mục
    private func moveSelectedWords(to targetFolder: WordFolder){
        withAnimation{
            // Lặp qua mảng Uncategorized để tìm những từ có ID nằm trong danh sách đã chọn
            for word in uncategorizedWords where selectedWordIDs.contains(word.persistentModelID){
                // ĐIỀU KỲ DIỆU CỦA SWIFTDATA Ở ĐÂY: Chỉ cần gán biến folder là xong!
                word.folder = targetFolder
            }
            // Reset trạng thái
            selectedWordIDs.removeAll()
            isSelectionMode = false
        }
    }
    
    
    private func createNewFolder(){
        let cleanedName = newFolderName.trimmingCharacters(in: .whitespaces)
        guard !cleanedName.isEmpty else{return}
        let newFolder = WordFolder(name: cleanedName)
        context.insert(newFolder)
        if isSelectionMode && !selectedWordIDs.isEmpty {
            moveSelectedWords(to: newFolder)
        }
        
        newFolderName = ""
    }
    
    // Hàm xử lý xoá khi người dùng vuốt row
    private func deleteFolder(at offsets: IndexSet){
        for index in offsets{
            context.delete(folders[index])
        }
    }
    private func deleteWord(at offsets: IndexSet){
        for index in offsets{context.delete(uncategorizedWords[index])}
    }
    
    

}

// Extract giao diện của Folder thành một View nhỏ cho gọn code
struct FolderRowContent: View{
    // 👉 1. Thêm biến State để điều khiển nhịp đập (pulse) của radar
    @State private var ispulsing = false
    let folder: WordFolder
    let isMoveTarget: Bool
    var body: some View{
        HStack{
            Image(systemName: isMoveTarget ? "folder.fill.badge.plus" : "folder.fill")
                .foregroundColor(.blue)
            Text(folder.name)
                .font(.headline)
            Spacer()
            if isMoveTarget{
                Text("Move Here")
                    .font(.caption).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
                    .padding(.vertical,4)
                    .background(
                    Capsule()
                        .fill(Color.blue)
                        )
                // Đưa scaleEffect và animation ra ngoài cùng để áp dụng cho CẢ CHỮ LẪN NỀN
                    .scaleEffect(ispulsing ? 1.1 : 1.0)// Chỉnh xuống 1.1 để nút thở nhẹ nhàng, không bị quá lố
                    .animation(
                        .easeInOut(duration: 1.2)// easeInOut tạo cảm giác hít thở tự nhiên
                        .repeatForever(autoreverses: true),value: ispulsing
                    )
                    
                   // MARK: - Ripple/Radar Ping Animation
//                    .background(
//                        ZStack{
//                            
//                            ForEach(0..<2,id:\.self){index in
//                                Capsule()
//                                    .fill(Color.blue.opacity(0.4))
//                                    .scaleEffect(ispulsing ? 1.8 : 1.0)
//                                    .opacity(ispulsing ? 0.0 : 1.0)
//                                    .animation(
//                                        .easeOut(duration: 1.5)
//                                        .repeatForever(autoreverses: false)
//                                        .delay(Double(index) * 0.5),
//                                        value: ispulsing
//                                        
//                                    )
//                                
//                            }
//                            Capsule()
//                                .fill(Color.blue)
//                            
//                        }
//                    
//                    )
                    .onAppear{
                        ispulsing = true
                    }
                    
                
                    
                
            }else{
                Text("\(folder.words?.count ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal,8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical,4)
    }
    
}

#Preview {
    WordBookView()
}
