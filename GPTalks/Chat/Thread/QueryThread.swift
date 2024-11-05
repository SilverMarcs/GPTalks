//
//  QueryThread.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/11/2024.
//

import Foundation

struct QueryThread {
    let id: UUID = UUID()
    let role: ThreadRole
    let content: String
    let datas: [Data]
    
//    func from(thread: Thread) -> QueryThread {
//        return QueryThread(role: thread.role, content: thread.content, datas: thread.datas)
//    }
}
