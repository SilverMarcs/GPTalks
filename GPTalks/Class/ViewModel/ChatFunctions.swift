//
//  ChatFunctions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//


import SwiftUI
import OpenAI

enum ChatTool: String, CaseIterable {
    case urlScrape
//    case browse
    case imageGenerate
    case transcribe

    var completionToolParam: ChatQuery.ChatCompletionToolParam {
        switch self {
        case .urlScrape:
            return .init(function:
                        .init(name: "urlScrape",
                              description: "If a URL is explicitly given, this function can be used to receive the contents of that url webpage. If you feel absolutely confident that you know some url where some information can be found, you may come up with the url yourself. If you already know the information, do not use the function to come up with a url. Always prioritize your pre-existing knowledge",
                              parameters:
                                .init(type: .object,
                                      properties: ["url":
                                                    .init(type: .string,
                                                          description: "The URL of the website to scrape")]
                                     )
                             )
                    )
        case .imageGenerate:
            return .init(function:
                        .init(name: "imageGenerate",
                              description: "If the user asks to generate an image with a description of the image, create a prompt that dalle can use to generate the image(s). Note that in the chat history, if this function was called and the following image comes from the user, it was in fact created by the assistant",
                              parameters:
                                .init(type: .object,
                                      properties: ["prompt":
                                                    .init(type: .string,
                                                          description: "The prompt for dalle")]
                                     )
                             )
                    )
        case .transcribe:
            return .init(function:
                        .init(name: "transcribe",
                              description: "If the user's input message contains something like a path to an audio file, then call this function with the exact filepath that the user provided. Do not add or format the fiel url in any way. For example, if the user's provided file path was 'file:///Users/Zabir/Downloads/test.mp3' then you need to return exactly 'file:///Users/Zabir/Downloads/test.mp3'",
                              parameters:
                                .init(type: .object,
                                      properties: ["audioPath":
                                                    .init(type: .string,
                                                          description: "The file path for the user's audio file")]
                                     )
                             )
                    )
        }
    }
    
    static var allTools: [ChatQuery.ChatCompletionToolParam] {
        return ChatTool.allCases.map { $0.completionToolParam }
    }
    
}
