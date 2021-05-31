//
//  MemoDetails.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 29/04/2021.
//

import SwiftUI

struct MemoDetails: View {
    @Binding var selectedMemo: Memo?
//    @GestureState(resetTransaction: .init(animation: .easeIn(duration: 0.4))) var dragAmount = CGFloat.zero
    @GestureState(reset: { val, transaction in
        var dragWillQuit = val > UIScreen.screens.first!.bounds.width/2
            transaction.animation = .easeIn(duration: 0.4)
    }) var dragAmount = CGFloat.zero
    
    @State private var name: String = ""
    var body: some View {
        let viewGesture = DragGesture(minimumDistance: CGFloat(0.1))
            .updating($dragAmount){ value, state, transaction in
                if(value.translation.height > 0){
                    transaction.isContinuous = true
                    withAnimation(.linear(duration: 0.1)){
                        state = value.translation.height
                    }
                }
            }
            .onEnded{ value in
                let screenHeight = UIScreen.screens.first!.bounds.height
                if value.translation.height > screenHeight/3 {
                        quit()
                }
            }
        return VStack(alignment: .leading, spacing: 20){
                HStack{
                    Button(action: {
                        let transaction = Transaction(animation: .easeIn(duration: 0.7))
                        withTransaction(transaction){
                            quit()
                        }
                    }) {
                        Image(systemName: "arrow.backward")
                            .imageScale(.large)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                if(selectedMemo != nil){
                    HStack {
                        MemoRowView(memo: selectedMemo!)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                HStack{
                    Text("Delete")
                    Spacer()
                    Button(action: {deleteMemo()}){
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                }
                .padding(.horizontal)
                HStack{
                    TextField("Name", text: $name, onCommit: {changeMemoName()})
                }
                .padding(.horizontal)
                Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .background(Color.white.shadow(radius: 10).clipShape(RoundedRectangle(cornerRadius: 25.0)))
        .offset(y: dragAmount)
        .gesture(viewGesture)
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear{
            self.name = selectedMemo?.name ?? ""
        }
    }
    
    func changeMemoName(){
        self.selectedMemo?.name = self.name
        try! PersistenceController.shared.container.viewContext.save()
        print(self.selectedMemo?.name)
    }
    
    func deleteMemo(){
        let ctx = PersistenceController.shared.container.viewContext
        let memoFileURL = selectedMemo!.url!
        ctx.delete(selectedMemo!)
        try! ctx.save()
        try? FileManager.default.removeItem(at: memoFileURL)
        quit()
    }
    func quit(){
        self.selectedMemo = nil
    }
}

struct MemoDetails_Previews: PreviewProvider {
    static var previews: some View {
        MemoDetails(selectedMemo: .constant(Memo()))
    }
}
