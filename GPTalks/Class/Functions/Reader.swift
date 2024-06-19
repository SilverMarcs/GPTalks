//
//  Reader.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/06/2024.
//

import Foundation

struct SearchResponseData: Codable {
    let code: Int
    let status: Int
    let data: [DataContent]
    
    struct DataContent: Codable {
        let title: String
        let url: String
        let content: String
        let description: String
    }
}

func fetchSearchResults(for query: String) async -> String {
    do {
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://s.jina.ai/\(formattedQuery)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("true", forHTTPHeaderField: "X-With-Generated-Alt")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(SearchResponseData.self, from: data)
        
        let formattedResults = responseData.data.map { dataContent in
        """
        Title: \(dataContent.title)
        \nURL: \(dataContent.url)
        \nContent: \(dataContent.content)
        \nDescription: \(dataContent.description)
        """
        }
        
        return formattedResults.joined(separator: "\n\n")
    } catch {
        return "An error occured fetching the search results. Error: \(error)"
    }
}


struct ResponseData: Codable {
    let code: Int
    let status: Int
    let data: DataContent
    
    struct DataContent: Codable {
        let title: String
        let url: String
        let content: String
    }
}

func useReader(from urlString: String) async -> String {
    do {
        guard let url = URL(string: "https://r.jina.ai/\(urlString)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("true", forHTTPHeaderField: "X-With-Generated-Alt")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(ResponseData.self, from: data)
        
        let formattedString = 
        """
        Title: \(responseData.data.title)
        \nURL: \(responseData.data.url)
        \nContent: \(responseData.data.content)
        """
        
        return formattedString
    } catch {
        return "An error occured fetching the URL. Error: \(error)"
    }
}
