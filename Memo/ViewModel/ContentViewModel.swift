//
//  ContentViewModel.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 27/04/2021.
//

import Foundation
import AVFoundation
import CoreData
import Combine

class ContentViewModel: NSObject, ObservableObject {
    var urlRecording: URL?
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    
    var viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    @Published var isAllowedToRecord: Bool?
    @Published var isRecording: Bool = false
    
    
    func recordNewMemo(){
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    func loadRecordingUI() {
        isAllowedToRecord = true
        self.isRecording.toggle()
        
        urlRecording = URL(string: "file://\(ContentViewModel.getWhistleURL())")!
        print(urlRecording!.absoluteString)
        
        // 4
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // 5
            whistleRecorder = try AVAudioRecorder(url: urlRecording!, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func loadFailUI() {
        isAllowedToRecord = false
    }
    
    func finishRecording(success: Bool = true){
        isRecording = false
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if success {
            //            recordButton.setTitle("Tap to Re-record", for: .normal)
            //            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            //            recordButton.setTitle("Tap to Record", for: .normal)
            
            //            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            //            ac.addAction(UIAlertAction(title: "OK", style: .default))
            //            present(ac, animated: true)
        }
    }
    
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getWhistleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).m4a")
    }
}

extension ContentViewModel: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully: Bool){
        print("finish recording")
        
        let newMemo = Memo(context: viewContext)
        newMemo.url = urlRecording!
        newMemo.date = Date()
        try! viewContext.save()
        
        urlRecording = nil
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?){
        urlRecording = nil

        fatalError("AudioRecorderEncodeErrorDidOccur : \(error)")
    }
}
