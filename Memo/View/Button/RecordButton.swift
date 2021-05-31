//
//  RecordButton.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 27/04/2021.
//

import SwiftUI

//struct RecordSymbol: View {
//    @Binding var isRecording: Bool
//    var body: some View {
//            Circle()
//                .foregroundColor(.red)
//                .padding(6)
//                .overlay(Circle().stroke(Color.gray, lineWidth: 3))
//    }
//}

struct RecordSymbol_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}, label: {})
            .buttonStyle(RecordButtonStyle(isRecording: .constant(false)))
    }
}

struct RecordButtonStyle: ButtonStyle {
    @Binding var isRecording: Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            Circle()
                .foregroundColor(.red)
                .padding(configuration.isPressed ? 10 : 6)
            Image(systemName: "mic.fill")
                .foregroundColor(.white)
                .imageScale(.large)
                .opacity(isRecording ? 1.0 : 0.0)
            Circle().stroke(Color.gray, lineWidth: 3)
                        .opacity(configuration.isPressed ? 0.8 : 1)
        }
        .frame(width: 75, height: 75, alignment: .center)

    }
}
