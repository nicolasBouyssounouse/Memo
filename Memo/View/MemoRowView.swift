//
//  MemoPreview.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 27/04/2021.
//

import SwiftUI
import AVFoundation

struct MemoRowView: View {
    let memo: Memo
    @State private var sounds: [MemoSound] = Array.init(repeating: 0, count: 60).map{MemoSound(value: $0)}
    @State private var angle: Double = 0.0
    @State private var isAnimating = false
    var foreverAnimation: Animation {
            Animation.linear(duration: 2.0)
//                .repeatForever()
        }
    var dateFormater: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "fr_FR")
        return dateFormatter
    }
    var body: some View {
        ZStack(alignment: .center){
            ForEach(sounds.indices){ soundID in
                    Capsule()
                        .foregroundColor(.gray)
                        .position(y: 150 )
                        .rotationEffect(.init(degrees: (360.0 / Double(sounds.count)) * Double(soundID)))
                        .frame(width: 2, height:  (CGFloat(sounds[soundID].value)))
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.75).delay(Double(soundID)/100))
                
                
            }
            .rotationEffect(Angle(degrees: self.isAnimating ? self.angle : 0.0))
            VStack(){
                if (memo.name != nil){
                    Text(memo.name!)
                        .font(.title3.bold())
                }
                if (memo.date != nil){
                    Text(dateFormater.string(from: memo.date!)).font(.title3)
                }
            }
        }
        .contentShape(Rectangle())
        .frame(width: 250, height: 250)
        .padding()
        .onAppear{
            withTransaction(Transaction(animation: .easeInOut(duration: 0.75).delay(0))){
                getSounds()
            }
            withAnimation(.linear(duration: 105).repeatForever(autoreverses: false)){//self.foreverAnimation){
                isAnimating.toggle()
                angle += 360
            }
        }
    }
    
    
    
    func getSounds(){

        
        let url = memo.url!
        let file = try! AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: file.fileFormat.sampleRate,
                                   channels: 1,
                                   interleaved: false)!

        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)
        try! file.read(into: buf!)

        let floatArray = Array(UnsafeBufferPointer(start: buf!.floatChannelData![0], count:Int(buf!.frameLength)))
        let chunkSize = 10
        let stride = stride(from: 0, to: floatArray.count, by: chunkSize)
           let preffix =  stride.map {
                Array(floatArray[$0..<Swift.min($0 + chunkSize, floatArray.count)])
            }
           .map{chunk -> Float in
                let sound = chunk.reduce(0){ buff, value in
                    buff + value/Float(chunk.count)
                }
                return (abs(sound) * 20000)
            }
        .prefix(60)
        
        print(preffix.count)
        let sMax = Float(1020)
        let sMin = Float(1)
        let gMax = Float(75)
        let gMin = Float(5)
        
        let clamp = gMin...gMax
        
        Array(preffix).enumerated().forEach{ id, sound in
            let newSound = (sound * gMax) / sMax
            let clamped = (0...newSound).clamped(to: clamp)
            self.sounds[id].value = log(clamped.upperBound) * 10
        }
    }
}

struct MemoRowView_Previews: PreviewProvider {
    static var previews: some View {
        var memo = Memo()
        memo.date = Date()
        return MemoRowView(memo: memo)
    }
}
