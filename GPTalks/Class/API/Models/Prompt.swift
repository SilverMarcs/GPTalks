//
//  Prompt.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/21.
//

import Foundation
import SwiftCSV
import SwiftUI


struct Prompt: Codable, Identifiable, Hashable, Equatable {
    var id: String {
        cmd
    }
    let cmd: String
    let act: String
    let prompt: String
    let tags: [String]
    
    static func == (lhs: Prompt, rhs: Prompt) -> Bool {
        lhs.id == rhs.id
    }
}

class PromptManager: ObservableObject {
    
    static let shared = PromptManager()
    
    @Published private(set) var prompts: [Prompt] = []
    
    @Published private(set) var syncedPrompts: [Prompt] = []
    
    @Published var customPrompts = [Prompt]()
    
    func addCustomPrompt(_ prompt: Prompt) {
        customPrompts.append(prompt)
        mergePrompts()
        saveCustomPrompts()
    }
    
    private func saveCustomPrompts() {
        do {
            let data = try JSONEncoder().encode(customPrompts)
            try data.write(to: customFileURL, options: .atomic)
            print("[Prompt Manager] Write user custom prompts to \(customFileURL).")
        } catch let error  {
            print(error.localizedDescription)
        }
    }
    
    func removeCustomPrompts(atOffsets indexSet: IndexSet) {
        customPrompts.remove(atOffsets: indexSet)
        saveCustomPrompts()
    }
    
    func removeCustomPrompt(_ prompt: Prompt) {
        customPrompts.removeAll {
            $0 == prompt
        }
        saveCustomPrompts()
    }
    
    init() {
        loadCachedPrompts()
        loadCustomPrompts()
        mergePrompts()
        print("[Prompt Manager] Load local prompts. Count: \(prompts.count).")
    }
    
    private func mergePrompts() {
        prompts = (syncedPrompts + customPrompts).sorted(by: {
            $0.act < $1.act
        })
        prompts.removeDuplicates()
    }
    
    private func jsonData() -> Data? {
        if let path = Bundle.main.path(forResource: "chatgpt_prompts", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return data
        }
        return nil
    }
    
    private func loadCachedPrompts() {
        if let data = jsonData(),
           let prompts = try? JSONDecoder().decode([Prompt].self, from: data) {
            syncedPrompts = prompts
            syncedPrompts.removeDuplicates()
            print("[Prompt Manager] Load cached prompts. Count: \(syncedPrompts.count).")
        }
    }
    
    private func loadCustomPrompts() {
        guard let data = try? Data(contentsOf: customFileURL),
              let prompts = try? JSONDecoder().decode([Prompt].self, from: data) else {
            return
        }
        customPrompts = prompts
        print("[Prompt Manager] Load user custom prompts. Count: \(customPrompts.count).")
    }
    
    
    private func parseCSVFile(at url: URL) {
        do {
            let csv: CSV = try CSV<Named>(url: url)
            var prompts = [Prompt]()
            try csv.enumerateAsDict({ dic in
                if let act = dic["act"],
                   let prompt = dic["prompt"] {
                    let cmd = act.convertToSnakeCase()
                    prompts.append(.init(cmd: cmd, act: act, prompt: prompt, tags: ["chatgpt-prompts"]))
                }
            })
            syncedPrompts = prompts
            syncedPrompts.removeDuplicates()
            mergePrompts()

            print("[Prompt Manager] Sync completed. Count: \(syncedPrompts.count). Total: \(self.prompts.count).")
            let data = try JSONEncoder().encode(prompts)
            try data.write(to: cachedFileURL, options: .atomic)
            print("[Prompt Manager] Write synced prompts to \(cachedFileURL).")
        } catch let error as CSVParseError {
            print(error.localizedDescription)
        } catch let error  {
            print(error.localizedDescription)
        }
    }
    
    private var cachedFileURL: URL {
        URL.documentsDirectory.appendingPathComponent("chatgpt_prompts.json")
    }
    
    private var customFileURL: URL {
        URL.documentsDirectory.appendingPathComponent("custom_prompts.json")
    }
    
}


extension String {
    
    func convertToSnakeCase() -> String {
        let lowercaseInput = self.lowercased()
        let separatorSet = CharacterSet(charactersIn: "- ")
        let replaced = lowercaseInput
            .replacingOccurrences(of: "`", with: "")
            .components(separatedBy: separatorSet)
            .joined(separator: "_")
        return replaced
    }

}

extension URL {
    
    // Get user's documents directory path
    static func documentDirectoryPath() -> URL {
        let arrayPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = arrayPaths[0]
        return docDirectoryPath
    }
    
}


extension Array where Element: Hashable {
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }
    
}
