//
//  Binding+not.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//
import SwiftUI


extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
