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

func fetchSearchResultsConcise(for query: String, truncateRemaining: Bool = true) async -> String {
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
        
        // Filter out entries from Wikipedia and Reddit
        let filteredData = responseData.data.filter { dataContent in
            !(dataContent.url.contains("wikipedia.org") || dataContent.url.contains("reddit.com"))
        }
        
        // Take the first two results after filtering
        let firstTwoResults = Array(filteredData.prefix(2))
        
        let formattedResults = firstTwoResults.enumerated().map { index, dataContent in
            let result = """
            Title: \(dataContent.title)
            \nURL: \(dataContent.url)
            \nContent: \(dataContent.content)
            \nDescription: \(dataContent.description)
            """
            
            if index < 2 {
                // Return entire content for the first two results
                return result
            } else if truncateRemaining {
                // Return first 4000 characters for the rest if truncateRemaining is true
                return String(result.prefix(4000))
            } else {
                // Return nothing for the rest if truncateRemaining is false
                return ""
            }
        }
        
        // Filter out empty strings if truncateRemaining is false
        let nonEmptyResults = formattedResults.filter { !$0.isEmpty }
        
        print(nonEmptyResults.count)
        
        return nonEmptyResults.joined(separator: "\n\n")
    } catch {
        return "An error occurred fetching the search results. Error: \(error)"
    }
}


func fetchFilteredSearchResults(for query: String) async -> String {
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
        
        // Filter out entries from Wikipedia and Reddit
        let filteredData = responseData.data.filter { dataContent in
            !(dataContent.url.contains("wikipedia.org") || dataContent.url.contains("reddit.com"))
        }
        
        let firstTwoResults = Array(filteredData.prefix(3))
        
        let formattedResults = firstTwoResults.map { dataContent in
            """
            Title: \(dataContent.title)
            \nURL: \(dataContent.url)
            \nContent: \(dataContent.content)
            \nDescription: \(dataContent.description)
            """
        }
        
        return formattedResults.joined(separator: "\n\n")
    } catch {
        return "An error occurred fetching the search results. Error: \(error)"
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
