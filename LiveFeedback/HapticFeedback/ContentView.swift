//
//  ContentView.swift
//  Haptics
//
//  Created by Leonie Schäper on 02/06/2021.
//

import SwiftUI

func makeTestFitnessProgram () -> FitnessProgram {
    let excercise = Excercise(name: "Fietsen", interval: [
        Interval(duration: 100, heartrate: Heartrate(lowLimit: 100, highLimit: 120, zone: 2))
    ])
    
    let fitnessProgram = FitnessProgram(excercises: [excercise])
    
    return fitnessProgram
}


struct ContentView: View {
#if os(iOS)
    let engine : HapticEngine  = {
        let h = HapticEngine()
        h.createEngine()
        return h

    }()
    
    

#endif
    var body: some View {
        VStack {
#if os(watchOS)
//            ScrollView {
//                VStack {
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.success)
//                    }) {
//                        Text ("success")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.notification)
//
//                    }) {
//                        Text ("notivication")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.directionUp)
//
//                    }) {
//                        Text ("directionUp")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.directionDown)
//
//                    }) {
//                        Text ("directionDown")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.retry)
//
//                    }) {
//                        Text ("retry")
//                    }
//
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.start)
//
//                    }) {
//                        Text ("start")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.stop)
//
//                    }) {
//                        Text ("stop")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.navigationGenericManeuver)
//
//                    }) {
//                        Text ("navigationGenericManeuver")
//                    }
//                    Button (action: {
//
//                        WKInterfaceDevice.current().play(.navigationLeftTurn)
//
//                    }) {
//                        Text ("navigationLeftTurn")
//                    }
//
//
//                }
//            }
#endif

            HStack {
                FitnessProgramPlayer(model: FitnessModel(fitnessProgram: makeTestFitnessProgram()))
            }

        }
        
        #if os(iOS)
//        HStack{
//            VStack{
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "1")
//                }) {
//                    Text ("1").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "3")
//                }) {
//                    Text ("3").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "5")
//                }) {
//                    Text ("5").font(.title)
//                }
//                Spacer()
//            }.padding(.horizontal, 20)
//
//            VStack{
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "2")
//                }) {
//                    Text ("2").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "4")
//                }) {
//                    Text ("4").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "6")
//                }) {
//                    Text ("6").font(.title)
//                }
//                Spacer()
//            }.padding(.horizontal, 20)
//            VStack{
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "7")
//                }) {
//                    Text ("7").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "8")
//                }) {
//                    Text ("8").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "9")
//                }) {
//                    Text ("9").font(.title)
//                }
//                Spacer()
//            }.padding(.horizontal, 20)
//
//            VStack{
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "10")
//                }) {
//                    Text ("10").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "11")
//                }) {
//                    Text ("11").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "12")
//                }) {
//                    Text ("12").font(.title)
//                }
//                Spacer()
//            }.padding(.horizontal, 20)
//
//            VStack{
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "13")
//                }) {
//                    Text ("13").font(.title)
//                }
//                Spacer()
//                Button (action: {
//                    engine.playHapticsFile(named: "14")
//                }) {
//                    Text ("14").font(.title)
//                }
//                Spacer()
//
//            }.padding(.horizontal, 20)
//
//        }
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

