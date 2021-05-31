//
//  ContentView.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 27/04/2021.
//

import SwiftUI
import CoreData

struct ContentView: View{
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Memo.date, ascending: true)],
        animation: .default)
    private var memos: FetchedResults<Memo>
    @State var isAllowedToRecord: Bool?
    @State var isRecording: Bool = false
    @State private var selectedMemo: Memo?
    
    var viewModel = ContentViewModel()
    var body: some View {
        ZStack {
            VStack{
                ScrollView {
                    VStack(spacing: 50) {
                        
                        ForEach(memos.reversed()){ memo in
                            MemoRowView(memo: memo)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMemo = memo
                                }
                        }
                        .padding(.vertical)
                    }
                    .frame(maxWidth: .infinity)
                }
                if(isAllowedToRecord == false){
                    VStack(spacing: 20){
                        Text("You didn't allowed Memo to access the Microhone, wana retry ?")
                        Button("Retry"){
                            viewModel.recordNewMemo()
                        }
                    }
                    .padding()
                }
                VStack{
                    HStack{
                        Button(action: {withAnimation(.easeInOut){onRecordPress()}}, label: {})
                            .buttonStyle(RecordButtonStyle(isRecording: $isRecording))
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
                .background(Color.init(white: 0.9))
                .cornerRadius(20)
            }
            .onReceive(viewModel.$isRecording, perform: { userIsRecording in
                self.isRecording = userIsRecording
            })
            .onReceive(viewModel.$isAllowedToRecord, perform: { isAllowedToRecord in
                self.isAllowedToRecord = isAllowedToRecord
            })
        }
        .fullScreenCover(item: $selectedMemo){ _ in
            MemoDetails(selectedMemo: $selectedMemo)
        }
        .ignoresSafeArea(edges: .bottom)
        
    }
    func onRecordPress(){
        if(isRecording){
            print("stop memo")
            viewModel.finishRecording()
        } else{
            print("start memo")
            viewModel.recordNewMemo()
        }
    }
    func tmpAddMemo(){
        let newMemo = Memo(context: self.viewContext)
        let url = ContentViewModel.getWhistleURL()
        newMemo.url = url
        newMemo.date = Date()
        try! viewContext.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
