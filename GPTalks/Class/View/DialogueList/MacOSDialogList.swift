//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

#if os(macOS)
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
//                    .padding(.top, -10)
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
            ToolbarItemGroup {
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
            }
            
            ToolbarItem(placement: .keyboard) {
                Button("h") {
                    viewModel.deleteSelectedDialogues()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .hidden()
                .disabled(viewModel.selectedDialogues.count < 2)
            }
        }
        .listStyle(.sidebar)
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

        // Add keyboard shortcut listener
        let shortcutListener = ShortcutListener(searchField: textField)
        context.coordinator.shortcutListener = shortcutListener
        shortcutListener.startListening()

        return textField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }

    class Coordinator: NSObject, NSSearchFieldDelegate {
        let binding: Binding<String>
        let onClear: () -> Void
        var shortcutListener: ShortcutListener?

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
}

class ShortcutListener {
    weak var searchField: NSSearchField?

    init(searchField: NSSearchField) {
        self.searchField = searchField
    }

    func startListening() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if event.modifierFlags.contains(.command) && event.characters == "f" {
                self.searchField?.becomeFirstResponder()
                return nil
            }
            return event
        }
    }
}

#endif
