//
//  FitnessProgramPlayer.swift
//

import SwiftUI
import AVFoundation
import UIKit
import HealthKit

let healthStore = HKHealthStore()

func requestHeartRateAuthorization() {
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    let typesToShare: Set<HKSampleType> = []
    let typesToRead: Set<HKObjectType> = [heartRateType]

    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
        if success {
            // Authorization granted, you can now access heart rate data
        } else {
            // Authorization denied or error occurred
        }
    }
}


func checkHealthKitAuthorizationStatus() {
    let healthStore = HKHealthStore()
    
    guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
        print("Heart rate data is not available.")
        return
    }
    
    let authorizationStatus = healthStore.authorizationStatus(for: heartRateType)
    
    switch authorizationStatus {
    case .notDetermined:
        print("HealthKit authorization status: Not determined")
        // Handle not determined status
    case .sharingDenied:
        print("HealthKit authorization status: Sharing denied")
        // Handle sharing denied status
    case .sharingAuthorized:
        print("HealthKit authorization status: Sharing authorized")
        // Handle sharing authorized status
    @unknown default:
        print("Unknown HealthKit authorization status")
    }
}



class FitnessModel: ObservableObject {
    let fitnessProgram: FitnessProgram
    #if os(iOS)
    let feedbackGenerator = UINotificationFeedbackGenerator()
    #endif

    private var currentExcerciseIndex = 0
    private var currentIntervalIndex = 0
    @Published var currentExcercise : Excercise?
    @Published var currentInterval : Interval?
    @Published var excercising : Bool = false
    @Published var excerciseElapsedTime = 0
    @Published var intervalElapsedTime = 0

    init(fitnessProgram: FitnessProgram) {
        self.fitnessProgram = fitnessProgram
    }

    func start() {
        excercising = true
        currentExcercise = fitnessProgram.excercises[0]
        currentInterval = currentExcercise?.interval[0]
        currentExcerciseIndex = 0
        currentIntervalIndex = 0
        startTimer()
    }

    var excerciseTimer: Timer?

    func startTimer() {
        excerciseElapsedTime = 0
        intervalElapsedTime = 0

        excerciseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.communicateStart()
            self.excerciseElapsedTime += 1
            self.intervalElapsedTime += 1
            self.communicateMilestones()
            self.communicateNinetyPercent()
            self.communicateSeventyPercent()
            self.communicateHeartbeat()

            guard let currentInterval = self.currentInterval,
                  let currentExcercise = self.currentExcercise else {
                return
            }

            if Double(self.intervalElapsedTime) > currentInterval.duration {
                // Current interval completed, go to the next one
                if self.currentIntervalIndex + 1 < currentExcercise.interval.count {
                    
                    self.currentIntervalIndex += 1
                    self.intervalElapsedTime = 0
                    self.currentInterval = currentExcercise.interval[self.currentIntervalIndex]
                    
                } else {
                    print("There are no more intervals.")
                    communicateEnd(endText: "Goal achieved!You cycled for 1 minute and 40 seconds with an average heart rate of \(startMonitoringHeartRate())")
                        #if os(watchOS)
                        WKInterfaceDevice.current().play(.stop)
                        #endif
                    self.excerciseTimer?.invalidate()
                    
                    func communicateEnd(endText : String) {
                        self.speakText(endText)
                    }
                }
            }
        }
    }

   

    func communicateStart() {
        guard let currentInterval else {
            return
        }
        
        let progressPercentage = Double(intervalElapsedTime) / currentInterval.duration

        if progressPercentage == 0.0 {
            communicateStart(startText: "Start biking")
            provideHapticFeedbackStart()
        }

    }
    
    
    func communicateStart(startText : String) {
        self.speakText(startText)
    }
    
    func communicateMilestones() {
            guard let currentInterval = currentInterval else {
                return
            }
            
            if currentInterval.duration / Double(intervalElapsedTime) == 2 {
                communicateMilestone(milestoneText: "Half way!")
                provideHapticFeedbackHalfWay()
            }
        }
    
    
    func communicateMilestone(milestoneText : String) {
        print (milestoneText)
        speakText(milestoneText)
    }
    
    func communicateNinetyPercent () {
        guard let currentInterval else {
            return
        }
        
        let progressPercentage = Double(intervalElapsedTime) / currentInterval.duration

        if progressPercentage == 0.9 {
            communicateNinetyPercent(NinetyPercentText: "90%. You're almost there!")
            provideHapticFeedbackNinetyPercent()
        }

    }
    
    func communicateNinetyPercent(NinetyPercentText : String) {
        print (NinetyPercentText)
        speakText(NinetyPercentText)
    }
    
    func communicateSeventyPercent () {
        guard let currentInterval else {
            return
        }
        
        let progressPercentage = Double(intervalElapsedTime) / currentInterval.duration

        if progressPercentage == 0.7 {
            communicateSeventyPercent(SeventyPercentText: "70%")
            provideHapticFeedbackSeventyProcent()
        }

    }
    func communicateSeventyPercent(SeventyPercentText : String) {
        print (SeventyPercentText)
        speakText(SeventyPercentText)
    }
    
    
    func startMonitoringHeartRate() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, newAnchor, error in
            guard let heartRateSamples = samples as? [HKQuantitySample] else {
                // Handle error
                return
            }
            
            if let heartRateSample = heartRateSamples.last {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = heartRateSample.quantity.doubleValue(for: heartRateUnit)
                
                // Use the heart rate data as needed
                let formattedHeartRate = String(format: "%.1f", heartRate)
                let heartbeatText = "\(formattedHeartRate) bpm"
                self.communicateHeartbeatText(heartbeatText: heartbeatText)
            }
        }
        
        healthStore.execute(query)
    }

    

   
    var previousProgressPercentage: Int = 0
    
    func communicateHeartbeat() {
        guard let currentInterval = currentInterval else {
            return
        }

        let progressPercentage = Int((Double(intervalElapsedTime) / currentInterval.duration) * 100)

        if progressPercentage >= previousProgressPercentage + 20 {

            startMonitoringHeartRate()
            previousProgressPercentage = progressPercentage
        }
    }

    func communicateHeartbeatText(heartbeatText: String) {
        print(heartbeatText)
        speakText(heartbeatText)
    }

    
    #if os(iOS)
    let engine : HapticEngine  = {
        let h = HapticEngine()
        h.createEngine()
        return h
    }()
    #endif
    
    func provideHapticFeedbackHalfWay() {
        #if os(iOS)
        engine.playHapticsFile(named: "3")
        #endif
        
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
        }
    
    func provideHapticFeedbackStart() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.start)
        #endif
        }
    
    func provideHapticFeedbackNinetyPercent() {
        #if os(iOS)
        engine.playHapticsFile(named: "1")
        #endif
        
        #if os(watchOS)
        WKInterfaceDevice.current().play(.retry)
        #endif
        }
    
//    func provideHapticFeedbackTooHigh() {
//        #if os(watchOS)
//        WKInterfaceDevice.current().play(.directionUp)
//        #endif
//        }
//
//    func provideHapticFeedbackTooLow() {
//        #if os(watchOS)
//        WKInterfaceDevice.current().play(.directionDown)
//        #endif
//        }
    
    func provideHapticFeedbackSeventyProcent() {
        #if os(iOS)
        engine.playHapticsFile(named: "2")
        #endif
        
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
        }
    
    
    
   
        
    let synth = AVSpeechSynthesizer() // <== Let op, ios 16 ding
    func speakText(_ text: String) {
        
        let utterance = AVSpeechUtterance(string: text)

        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Voice moeten zijn gedownload
        synth.speak(utterance)
    }
}

struct FitnessProgramPlayer: View {
    @ObservedObject var model : FitnessModel
    
    var body: some View {
        VStack {
            Text ("Fitness player")
            
            if model.excercising {
                Text ("\(model.currentExcercise!.name)")
                    .font(.title)
//                Text ("Interval: \(model.currentInterval!.name)")

                Text("\(model.intervalElapsedTime)")
//                Text ("\(model.excerciseElapsedTime)")
//                Text ("\(model.intervalElapsedTime)")


            }
            else {
                List {
                    ForEach (model.fitnessProgram.excercises){excercise in
                        Text (excercise.name)
                    }
                }
                
                Button (action: {
                    model.start()
                }) {
                    Text ("Start")
                }
            }
        }
    }
    
    
}



fileprivate func makeFitnessProgram () -> FitnessProgram {
    let excercise = Excercise(name: "Fietsen", interval: [
        Interval(duration: 100, heartrate: Heartrate(lowLimit: 100, highLimit: 120, zone: 2))
    ])
    
    let fitnessProgram = FitnessProgram(excercises: [excercise])
    
    return fitnessProgram
}


struct FitnessProgramPlayer_Previews: PreviewProvider {
    static var previews: some View {
        FitnessProgramPlayer(model:
                                FitnessModel(fitnessProgram:  makeFitnessProgram()))
    }
}
