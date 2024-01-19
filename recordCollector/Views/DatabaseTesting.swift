//
//  DatabaseTesting.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/14/24.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase

struct DatabaseTesting: View {
    var ref: DatabaseReference! = Database.database().reference()
    let storage = Storage.storage()
    
    var body: some View {
        Button(action: {
            ref.child("Records").child("ID1").child("Name").setValue("Hunky Dory")
        }, label: {
            /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
        })
    }
}

#Preview {
    DatabaseTesting()
}
