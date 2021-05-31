//
//  MemoNav.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 30/04/2021.
//

import SwiftUI

struct MemoNav: View {
    @Binding var selectedMemo: Memo?
    
    var body: some View {
        Text("")
    }
}

struct MemoNav_Previews: PreviewProvider {
    static var previews: some View {
        MemoNav(selectedMemo: .constant(Memo()))
    }
}
