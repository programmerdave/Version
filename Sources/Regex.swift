//
//  Regex.swift
//  Version
//
//  Based on: http://nshipster.com/swift-operators/
//  Created by Mattt Thompson.
//

import Foundation


extension String {
    var range: NSRange {
        return NSMakeRange(0, self.utf16.count)
    }
    
    func substringWithRange(_ range: NSRange) -> String {
        let rangeStart : String.Index = self.characters.index(self.startIndex, offsetBy: range.location)
        return self.substring(with: rangeStart..<self.characters.index(rangeStart, offsetBy: range.length))
    }
}


struct Regex {
    let pattern: String
    let options: NSRegularExpression.Options
    let matcher: NSRegularExpression!
    
    init?(pattern: String, options: NSRegularExpression.Options = []) {
        self.init(pattern: pattern, options: options, error: nil)
        if self.matcher == nil {
            return nil
        }
    }
    
    init(pattern: String, options: NSRegularExpression.Options = [], error: NSErrorPointer? = nil) {
        self.pattern = pattern
        self.options = options
        var e: NSError?
        do {
            self.matcher = try NSRegularExpression(pattern: self.pattern, options: self.options)
        } catch let error as NSError {
            e = error
            self.matcher = nil
        }
        if let pointer = error {
            pointer?.pointee = e
        }
    }
    
    func match(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        return self.matcher.numberOfMatches(in: string, options: options, range: string.range) != 0
    }
    
    func matchingsOf(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> [String] {
        var matches : [String] = []
        self.matcher.enumerateMatches(in: string, options: options, range: string.range) {
            (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
            if let result = result {
                matches.append(string.substringWithRange(result.range))
            }
        }
        return matches
    }
    
    func groupsOfFirstMatch(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> [String] {
        let match = self.matcher.firstMatch(in: string, options: options, range: string.range)
        var groups : [String] = []
        if let match = match {
            for i in 0..<match.numberOfRanges {
                let range = match.rangeAt(i)
                if range.location != NSNotFound {
                    groups.append(string.substringWithRange(range))
                }
            }
        }
        return groups
    }
}

func ==(lhs: Regex, rhs: Regex) -> Bool {
    return lhs.pattern == rhs.pattern
        && lhs.options == rhs.options
}

extension Regex: ExpressibleByStringLiteral {
    typealias UnicodeScalarLiteralType = StringLiteralType
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.init(pattern: value, error: nil)
    }
}
