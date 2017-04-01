//
//  CourseSearchResult.swift
//  TUHub
//
//  Created by Connor Crawford on 3/18/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import AEXML

struct CourseSearchResult {
    
    static let searchPageSize = 15
    
    let name: String
    let title: String
    let description: String
    let credits: Int?
    let levels: [String]
    let division: String
    let college: String
    let department: String
    let schedule: [String]
    
    init?(xml: AEXMLElement) {
        guard
            let name = xml["crseId"].value?.stripXML(),
            let title = xml["title"].value?.stripXML(),
            let description = xml["description"].value?.stripXML(),
            let division = xml["division"].value?.stripXML(),
            let college  = xml["college"].value?.stripXML(),
            let department = xml["department"].value?.stripXML()
            else {
                log.error("Failed to parse CourseSearchResult.")
                return nil
        }
        
        self.name = name
        self.title = title
        self.description = description
        credits = xml["creditHr"]["low"].int!
        self.levels = xml["levels"].children.flatMap({ $0.value })
        self.division = division
        self.college = college
        self.department = department
        self.schedule = xml["schedule"].children.flatMap({ $0.value })
    }
    
    static func search(for searchText: String, pageNumber: Int, _ responseHandler: @escaping ([CourseSearchResult]?, Error?)->Void) {
        var searchText = searchText.trailingWhitespacesTrimmed()
        guard searchText.characters.count > 0 else { responseHandler(nil, nil); return }
        
        // Replace spaces with commas, and remove all other non-alphanumeric characters
        let setToRemove = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ",")).inverted
        let searchTerms = searchText.replacingOccurrences(of: " ", with: ",").trimmingCharacters(in: setToRemove)
        
        // Determine min and max rows based on the desired page
        let minRow = pageNumber * CourseSearchResult.searchPageSize + 1
        let maxRow = (pageNumber + 1) * CourseSearchResult.searchPageSize
        
        let params: [String : Any] = ["searchTerms" : searchTerms,
                                      "term" : "All",
                                      "division" : "All",
                                      "minRow" : minRow,
                                      "maxRow" : maxRow]
        
        NetworkManager.shared.request(fromEndpoint: .courseSearch, parameters: params) { (data, error) in
            
            var results: [CourseSearchResult]?
            
            defer { responseHandler(results, error) }
            guard let data = data else { return }
            do {
                let xmlDoc = try AEXMLDocument(xml: data)
                let coursesXML = xmlDoc.root.children
                results = coursesXML.flatMap({ CourseSearchResult(xml: $0) })
            } catch {
                log.error("Unable to parse XML. Error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
}

extension String {
    
    func stripXML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func trailingWhitespacesTrimmed() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
    
}
