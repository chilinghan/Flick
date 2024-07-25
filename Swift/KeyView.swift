//
//  KeyView.swift
//  WristPlus
//
//  Created by Rohan Gadde on 7/25/24.
//

//
//  KeyView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/24/24.
//
// /*
import SwiftUI

struct KeyView: View {
    @State private var isOn = false

    var body: some View {
        Toggle("Vibrate ON", isOn: $isOn)
            .toggleStyle(.button)
            .tint(Color("LightOr"))
        
        if isOn {
            Text("Vibrate ON")
        } else {
            Text("Vibrate OFF")
        }
        
    }
}

#Preview {
    KeyView()
}


// */
