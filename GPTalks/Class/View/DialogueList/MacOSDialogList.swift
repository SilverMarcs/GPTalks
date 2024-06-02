//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct MacOSDialogList: View {
    @Bindable var viewModel: DialogueViewModel
    @State private var previousActiveDialoguesCount = 0

    var body: some View {
        SearchField("Search", text: $viewModel.searchText) {
            viewModel.searchText = ""
        }
        .padding(.horizontal, 11)
        
        Group {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogues) { session in
                        DialogueListItem(session: session)
                            .id(session.id.uuidString)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
                            .accentColor(.accentColor)
                    }
                    .accentColor(Color("niceColorLighter"))
                    .animation(.default, value: viewModel.searchText)
                    .padding(.top, -10)
                    .onChange(of: viewModel.currentDialogues.count) {
                        if viewModel.currentDialogues.count > previousActiveDialoguesCount {
                            if !viewModel.currentDialogues.isEmpty {
                                withAnimation {
                                    proxy.scrollTo(viewModel.currentDialogues[0].id.uuidString, anchor: .top)
                                }
                            }
                        }
                        previousActiveDialoguesCount = viewModel.currentDialogues.count
                    }
                    .onChange(of: viewModel.currentDialogues.first?.date) {
                        if !viewModel.currentDialogues.isEmpty {
                            withAnimation {
                                proxy.scrollTo(viewModel.currentDialogues[0].id.uuidString, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 280)
        .toolbar {
            Spacer()

            Picker("Select State", selection: $viewModel.selectedState) {
                ForEach(ContentState.allCases) { state in
                    Text(state.rawValue).tag(state)
                }
            }

            Spacer()

            Button {
                viewModel.addDialogue()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button("h") {
                viewModel.deleteSelectedDialogues()
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .hidden()
            .disabled(viewModel.selectedDialogues.count < 2)
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
//        .searchable(text: $viewModel.searchText, placement: .toolbar)
    }
}

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var onClear: () -> Void
    let prompt: String
    let height: CGFloat

    init(_ prompt: String, text: Binding<String>, height: CGFloat = 30, onClear: @escaping () -> Void) {
        self.onClear = onClear
        self.prompt = prompt
        self.height = height
        _text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text, onClear: onClear)
    }

    func makeNSView(context: Context) -> NSSearchField {
        let textField = NSSearchField(string: text)
        textField.placeholderString = prompt
        textField.delegate = context.coordinator
        textField.bezelStyle = .roundedBezel
        textField.focusRingType = .none

        // Set the height constraint
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: height)
        ])

//        // Customize the search and cancel button colors
//        if let cell = textField.cell as? NSSearchFieldCell {
//            if let searchButton = cell.searchButtonCell {
//                searchButton.image = tintedImage(named: "magnifyingglass", color: .slightlyBrighterSecondaryLabelColor)
//            }
//            if let cancelButton = cell.cancelButtonCell {
//                cancelButton.image = tintedImage(named: "xmark.circle.fill", color: .slightlyBrighterSecondaryLabelColor)
//            }
//        }

        return textField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }

    class Coordinator: NSObject, NSSearchFieldDelegate {
        let binding: Binding<String>
        let onClear: () -> Void

        init(binding: Binding<String>, onClear: @escaping () -> Void) {
            self.binding = binding
            self.onClear = onClear
            super.init()
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            binding.wrappedValue = field.stringValue

            if field.stringValue.isEmpty {
                onClear()
            }
        }
    }

    private func tintedImage(named: String, color: NSColor) -> NSImage? {
//        guard let image = NSImage(named: named) else { return nil }
        guard let image = NSImage(systemSymbolName: named, accessibilityDescription: nil) else { return nil }
        let tintedImage = NSImage(size: image.size)

        tintedImage.lockFocus()
        let imageRect = NSRect(origin: .zero, size: image.size)
        image.draw(in: imageRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        color.set()
        imageRect.fill(using: .sourceAtop)
        tintedImage.unlockFocus()

        return tintedImage
    
    }
}

extension NSColor {
    static var slightlyBrighterSecondaryLabelColor: NSColor {
        return NSColor.secondaryLabelColor.blended(withFraction: 0.2, of: .white) ?? .secondaryLabelColor
    }
}
