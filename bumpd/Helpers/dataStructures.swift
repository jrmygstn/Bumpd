//
//  dataStructures.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation

enum VerifyError: Error {
    case invalidUrl
    case err(String)
}


protocol WithMessage {
    var message: String { get }
}

enum VerifyResult {
    case success(WithMessage)
    case failure(Error)
}


class DataResult: WithMessage {
    let data: Data
    let message: String

    init(data: Data) {
        self.data = data
        self.message = String(describing: data)
    }
}

struct CheckResult: Codable, WithMessage {
    let success: Bool
    let message: String
}
