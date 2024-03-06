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
    // Add other cases here as needed, for example:
    case imageGenerate

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
            // Placeholder for another tool's parameters. Adjust accordingly.
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
        }
    }
    
    static var allTools: [ChatQuery.ChatCompletionToolParam] {
        return ChatTool.allCases.map { $0.completionToolParam }
    }
    
}
