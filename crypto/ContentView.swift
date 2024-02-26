//
//  ContentView.swift
//  crypto
//
//  Created by Tech9320 on 2/24/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

public var yourBitcoinBalance = 0.0

struct ContentView: View {

    @State private var rate = "Loading..."
    @State private var enteredBitcoinAmount = ""
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var orientation: SIMD3<Double> = .zero
    private let modelDepth: Double = 200    
    
    var body: some View {
        
            if var rotation: RotationComponent = earth.components[RotationComponent.self] {
        rotation.speed = configuration.currentSpeed
        earth.components[RotationComponent.self] = rotation
    } else {
        earth.components.set(RotationComponent(speed: configuration.currentSpeed))
    }
        HStack {
            
            VStack {
                // Logo Placeholder
                // Model3D(named: "Scene", bundle: realityKitContentBundle)
                //     .padding(.bottom, 20)
                  Model3D(named:"Scene", bundle: realityKitContentBundle) { model in
                model.resizable()
                model.components[RotationComponent.self] = RotationComponent(speed: 0.1, axis: [0, 1, 0])
                    .scaledToFit()
                    .rotation3DEffect(
                        Rotation3D(
                            eulerAngles: .init(angles: orientation, order: .xyz)
                        )
                    )
                    .frame(depth: modelDepth)
                    .offset(z: -modelDepth / 2)
                    .accessibilitySortPriority(1)
            } placeholder: {
                ProgressView()
                    .offset(z: -modelDepth * 0.75)
        }
                Text("CryptoBalance Pal - Your Virtual Crypto Companion")

                Text("Welcome to CryptoBalance Pal, your one-stop solution for tracking your Bitcoin holdings in an immersive experience. Seamlessly manage your cryptocurrency portfolio with a user-friendly interface designed for the Apple Vision Pro.")
                    .padding(.horizontal, 80)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .onAppear() {
                fetchBitcoinPrice()
            }
            
            
            VStack {
                
                Text("Current Bitcoin Value:")
                Text("\(self.rate) USD")
                    
                TextField("Enter Your Bitcoin Amount", text: $enteredBitcoinAmount)
                    .keyboardType(.decimalPad)
                    .frame(width: 250)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 20)
                
           
                Text("Your holdings in USD: \(yourBitcoinBalance, specifier: "%.2f") USD")
                    .padding(.top, 20)
                    
                Toggle("Proceed", isOn: $showImmersiveSpace)
                    .toggleStyle(.button)
                    .padding(.top, 20)

            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .onChange(of: showImmersiveSpace) { _, newValue in
                Task {
                    if newValue {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
            
        }
        

    }
    
    func fetchBitcoinPrice(){
        print("Fetching Bitcoin Price")
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let bpi = json["bpi"] as! [String: Any]
                let usd = bpi["USD"] as! [String: Any]
                let rate = usd["rate"] as! String
                self.rate = rate
                print("Bitcoin price: \(rate)")
                calculateYourBitcoinBalance()
            }
        }
        task.resume()

    }
    
    func calculateYourBitcoinBalance(){
        print("Calculating your Bitcoin Balance")
        if let bitcoinAmount = Double(enteredBitcoinAmount) {
            if let bitcoinRate = Double(rate.replacingOccurrences(of: ",", with: "")) {
                yourBitcoinBalance = bitcoinAmount * bitcoinRate
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
