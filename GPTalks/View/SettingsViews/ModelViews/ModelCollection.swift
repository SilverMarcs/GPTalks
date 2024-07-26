//
//  ModelCollection.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/07/2024.
//

//import SwiftUI
//
//struct ModelCollection: View {
//   var provider: Provider
//    
//    var body: some View {
//        ForEach(provider.models.sorted(by: { $0.order < $1.order }), id: \.self) { model in
//            ModelRow(model: model)
//        }
//        .onDelete(perform: deleteItems)
//        .onMove(perform: moveItems)
//    }
//    
//    private func deleteItems(at offsets: IndexSet) {
//        let sortedModels = provider.models.sorted(by: { $0.order < $1.order })
//        let sortedIndices = offsets.map { sortedModels[$0].id }
//        provider.models.removeAll { sortedIndices.contains($0.id) }
//        
//        // Update the order of remaining items
//        for (index, model) in provider.models.enumerated() {
//            model.order = index
//        }
//    }
//
//    private func moveItems(from source: IndexSet, to destination: Int) {
//        var sortedModels = provider.models.sorted(by: { $0.order < $1.order })
//        sortedModels.move(fromOffsets: source, toOffset: destination)
//        
//        for (index, model) in sortedModels.enumerated() {
//            withAnimation {
//                model.order = index
//            }
//        }
//        
//        provider.models = sortedModels
//    }
//}
//
//#Preview {
//    ModelCollection(provider: Provider.factory(type: .openai))
//}
