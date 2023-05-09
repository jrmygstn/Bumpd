//
//  verifyAPI.swift
//  
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation

struct VerifyAPI {

    static func sendVerificationCode(_ countryCode: String, _ phoneNumber: String) {
        let parameters = [
            "via": "sms",
            "country_code": countryCode,
            "phone_number": phoneNumber
        ]
        
        RequestHelper.createRequest("start", parameters) { json in
            return .success(DataResult(data: json))
        }
        
    }

//    static func validateVerificationCode(_ countryCode: String, _ phoneNumber: String, _ code: String, segue: @escaping (CheckResult) -> Void) {
//
//        let parameters = [
//            "via": "sms",
//            "country_code": countryCode,
//            "phone_number": phoneNumber,
//            "verification_code": code
//        ]
//
//        createRequest("check", parameters) {
//            jsonData in
//
//            let decoder = JSONDecoder()
//            do {
//                let checked = try decoder.decode(CheckResult.self, from: jsonData)
//                DispatchQueue.main.async(execute: {
//                    segue(checked)
//                })
//                return VerifyResult.success(checked)
//            } catch {
//                return VerifyResult.failure(VerifyError.err("failed to deserialize"))
//            }
//        }
//    }
}
