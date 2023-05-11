//
//  extentions.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension String {
    
    var trim: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func makeFirebaseString() -> String {
        let arrCharacterToReplace = [".","#","$","[","]"]
        var finalString = self

        for character in arrCharacterToReplace{
            finalString = finalString.replacingOccurrences(of: character, with: "")
        }

        return finalString
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}

extension UILabel {

    // Pass value for any one of both parameters and see result
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }
}

extension UIFont {
    
    class func italicSystemFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular)-> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        switch weight {
        case .ultraLight, .light, .thin, .regular:
            return font.withTraits(.traitItalic, ofSize: size)
        case .medium, .semibold, .bold, .heavy, .black:
            return font.withTraits(.traitBold, .traitItalic, ofSize: size)
        default:
            return UIFont.italicSystemFont(ofSize: size)
        }
     }
    
    class func boldSystemFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular)-> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        switch weight {
        case .ultraLight, .light, .thin, .regular:
            return font.withTraits(.traitBold, ofSize: size)
        case .medium, .semibold, .bold, .heavy, .black:
            return font.withTraits(.traitBold, ofSize: size)
        default:
            return UIFont.boldSystemFont(ofSize: size)
        }
     }
    
     func withTraits(_ traits: UIFontDescriptor.SymbolicTraits..., ofSize size: CGFloat) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: size)
     }
    
}

extension UIButton {
    
    func darkBlur() {
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
    }
    
    func lightBlur() {
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
    }
    
}

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    }
    
    func darkBlur() {
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
    }
    
    func lightBlur() {
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
    }
     
}

extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension Date {
    
    var millisecondsSince1970: Int64 {
        
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
        
    }
    
    var secondsSince1970: Int64 {
        
        Int64((self.timeIntervalSince1970).rounded())
        
    }
    
    func calendarTimeSinceNow() -> String {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        let years = components.year!
        let months = components.month!
        let days = components.day!
        let hours = components.hour!
        let minutes = components.minute!
        let seconds = components.second!
        
        if years > 0 {
            return years == 1 ? "Active 1 y ago" : "Active \(years) y ago"
        } else if months > 0 {
            return months == 1 ? "Active 1 mo ago" : "Active \(months) mo ago"
        } else if days >= 7 {
            let weeks = days / 7
            return weeks == 1 ? "Active 1 w ago" : "Active \(weeks) w ago"
        } else if days > 0 {
            return days == 1 ? "Active 1 d ago" : "Active \(days) d ago"
        } else if hours > 0 {
            return hours == 1 ? "Active 1 h ago" : "Active \(hours) h ago"
        } else if minutes > 0 {
            return minutes == 1 ? "Active 1 m ago" : "Active \(minutes) m ago"
        } else {
            return seconds == 1 ? "Active now" : "Active \(seconds) s ago"
        }
        
    }
    
    func timestampSinceNow() -> String {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        let years = components.year!
        let months = components.month!
        let days = components.day!
        let hours = components.hour!
        let minutes = components.minute!
        let seconds = components.second!
        
        if years > 0 {
            return years == 1 ? "1 yr ago" : "\(years) yrs ago"
        } else if months > 0 {
            return months == 1 ? "1 mo ago" : "\(months) mos ago"
        } else if days >= 7 {
            let weeks = days / 7
            return weeks == 1 ? "1 wk ago" : "\(weeks) wks ago"
        } else if days > 0 {
            return days == 1 ? "1 dy ago" : "\(days) dys ago"
        } else if hours > 0 {
            return hours == 1 ? "1 hr ago" : "\(hours) hrs ago"
        } else if minutes > 0 {
            return minutes == 1 ? "1 mn ago" : "\(minutes) mns ago"
        } else {
            return seconds == 1 ? "1 sec ago" : "\(seconds) secs ago"
        }
        
    }
    
    func postDateSinceNow() -> String {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        let years = components.year!
        let months = components.month!
        let days = components.day!
        let hours = components.hour!
        let minutes = components.minute!
        let seconds = components.second!
        
        if years > 0 {
            return years == 1 ? "Posted 1 yr ago" : "Posted \(years) yrs ago"
        } else if months > 0 {
            return months == 1 ? "Posted 1 mo ago" : "Posted \(months) mos ago"
        } else if days >= 7 {
            let weeks = days / 7
            return weeks == 1 ? "Posted 1 wk ago" : "Posted \(weeks) wks ago"
        } else if days > 0 {
            return days == 1 ? "Posted 1 dy ago" : "Posted \(days) dys ago"
        } else if hours > 0 {
            return hours == 1 ? "Posted 1 hr ago" : "Posted \(hours) hrs ago"
        } else if minutes > 0 {
            return minutes == 1 ? "Posted 1 mn ago" : "Posted \(minutes) mns ago"
        } else {
            return seconds == 1 ? "Posted 1 sec ago" : "Posted \(seconds) secs ago"
        }
        
    }
    
    func sentSinceNow() -> String {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        let years = components.year!
        let months = components.month!
        let days = components.day!
        let hours = components.hour!
        let minutes = components.minute!
        let seconds = components.second!
        
        if years > 0 {
            return years == 1 ? "1 yr" : "\(years) yrs"
        } else if months > 0 {
            return months == 1 ? "1 mo" : "\(months) mos"
        } else if days >= 7 {
            let weeks = days / 7
            return weeks == 1 ? "1 wk" : "\(weeks) wks"
        } else if days > 0 {
            return days == 1 ? "1 dy" : "\(days) dys"
        } else if hours > 0 {
            return hours == 1 ? "1 hr" : "\(hours) hrs"
        } else if minutes > 0 {
            return minutes == 1 ? "1 min" : "\(minutes) mins"
        } else {
            return seconds == 1 ? "1 sec" : "\(seconds) secs"
        }
        
    }
    
    func tillNextSession() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
                
                let years = components.year!
                let months = components.month!
                let days = components.day!
                let hours = components.hour!
                let minutes = components.minute!
                let seconds = components.second!
                
                if years > 0 {
                    return years == 1 ? "Next session starts in 1 year" : "Next session starts in \(years) years"
                } else if months > 0 {
                    return months == 1 ? "Next session starts in 1 month" : "Next session starts in \(months) months"
                } else if days >= 7 {
                    let weeks = days / 7
                    return weeks == 1 ? "Next session starts in 1 week" : "Next session starts in \(weeks) weeks"
                } else if days > 0 {
                    return days == 1 ? "Next session starts in 1 day" : "Next session starts in \(days) days"
                } else if hours > 0 {
                    return hours == 1 ? "Next session starts in 1 hour" : "Next session starts in \(hours) hours"
                } else if minutes > 0 {
                    return minutes == 1 ? "Next session starts in 1 minute" : "Next session is in \(minutes) minutes"
                } else {
                    return seconds == 1 ? "Next session starts in 1 second" : "Next session starts in \(seconds) seconds"
                }
                
            }
            
            func clientSinceNow() -> String {
                let calendar = Calendar.current
                
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
                
                let years = components.year!
                let months = components.month!
                let days = components.day!
                let hours = components.hour!
                let minutes = components.minute!
                let seconds = components.second!
                
                if years > 0 {
                    return years == 1 ? "Last year" : "\(years) years ago"
                } else if months > 0 {
                    return months == 1 ? "Last month" : "\(months) months ago"
                } else if days >= 7 {
                    let weeks = days / 7
                    return weeks == 1 ? "Last week" : "\(weeks) weeks ago"
                } else if days > 0 {
                    return days == 1 ? "Yesterday" : "\(days) days ago"
                } else if hours > 0 {
                    return hours == 1 ? "An hour ago" : "\(hours) hours ago"
                } else if minutes > 0 {
                    return minutes == 1 ? "A minute ago" : "\(minutes) minutes ago"
                } else {
                    return seconds == 1 ? "A second ago" : "\(seconds) seconds ago"
                }
                
            }
            
        }

        extension Int {
            
            var degreesToRadians: CGFloat {
                    return CGFloat(self) * .pi / 180.0
                }
            
            func formatUsingAbbrevation () -> String {
                let numFormatter = NumberFormatter()
                
                typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
                let abbreviations:[Abbrevation] = [(0.0, 100.0, ""),
                                                   (100_000.0, 100_000.0, "K"),
                                                   (100_000_000.0, 100_000_000.0, "M"),
                                                   (100_000_000_000.0, 100_000_000_000.0, "B")]
                // you can add more !
                let startValue = Double (abs(self))
                let abbreviation:Abbrevation = {
                    var prevAbbreviation = abbreviations[0]
                    for tmpAbbreviation in abbreviations {
                        if (startValue < tmpAbbreviation.threshold) {
                            break
                        }
                        prevAbbreviation = tmpAbbreviation
                    }
                    return prevAbbreviation
                } ()
                
                let value = Double(self) / abbreviation.divisor
                numFormatter.positiveSuffix = abbreviation.suffix
                numFormatter.negativeSuffix = abbreviation.suffix
                numFormatter.allowsFloats = true
                numFormatter.numberStyle = .decimal
                numFormatter.minimumIntegerDigits = 1
                numFormatter.minimumFractionDigits = 2
                numFormatter.maximumFractionDigits = 2
                
                return numFormatter.string(from: NSNumber (value:value))!
            }
            
            func pointsUsingAbbrevation () -> String {
                let numFormatter = NumberFormatter()
                
                typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
                let abbreviations:[Abbrevation] = [(0, 1, ""),
                                                   (1000.0, 1000.0, "K"),
                                                   (10000.0, 1000.0, "K"),
                                                   (100000.0, 1000.0, "K"),
                                                   (1000000.0, 1000000.0, "M"),
                                                   (10000000.0, 1000000.0, "M"),
                                                   (100000000.0, 1000000.0, "M"),
                                                   (1000000000.0, 1000000000.0, "B")]
                // you can add more !
                let startValue = Double (abs(self))
                let abbreviation:Abbrevation = {
                    var prevAbbreviation = abbreviations[0]
                    for tmpAbbreviation in abbreviations {
                        if (startValue < tmpAbbreviation.threshold) {
                            break
                        }
                        prevAbbreviation = tmpAbbreviation
                    }
                    return prevAbbreviation
                } ()
                
                let value = Double(self) / abbreviation.divisor
                numFormatter.positiveSuffix = abbreviation.suffix
                numFormatter.negativeSuffix = abbreviation.suffix
                numFormatter.allowsFloats = true
                numFormatter.minimumIntegerDigits = 1
                numFormatter.minimumFractionDigits = 0
                numFormatter.maximumFractionDigits = 1
                
                return numFormatter.string(from: NSNumber (value:value))!
            }
            
        }

        extension Double {
            
          var toTimeString: String {
            
            let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
            let minutes: Int = Int(self / 60.0)
            return String(format: "%d:%02d", minutes, seconds)
            
          }
            
        }

        extension UINavigationController {
            
            func setStatusBar(backgroundColor: UIColor) {
                let statusBarFrame: CGRect
                if #available(iOS 13.0, *) {
                    statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
                } else {
                    statusBarFrame = UIApplication.shared.statusBarFrame
                }
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.backgroundColor = backgroundColor
                view.addSubview(statusBarView)
            }
            
        }

