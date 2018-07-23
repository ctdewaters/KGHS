//
//  Event.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/17/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit


///`Event`: represents an iCal event fetched from the school's ics feed.
class Event {
    
    //MARK: - Properties.
    ///The calendar event
    var calendarEvent: MXLCalendarEvent?
    
    ///The category of this event.
    public var category: Category {
        return ((self.calendarEvent?.eventCategory ?? "nil") == "KGHS Athletics") ? .athletics : ((self.calendarEvent?.eventCategory ?? "nil") == "King George High") ? .kghs : .extraneous
    }
    
    ///The subcategory of this event.
    public var subCategory: SubCategory?
    
    ///`Event.Category`: represents the category this event came from.
    public enum Category {
        case kghs, athletics, extraneous
        
        ///The title to display for this category.
        public var displayTitle: String {
            if self == .athletics {
                return "Athletics"
            }
            return "KGHS"
        }
    }
    
    ///Favorite events ID array.
    public static var favoriteIDs: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: "favoriteEventIDs")
        }
        get {
            return UserDefaults.standard.value(forKey: "favoriteEventIDs") as? [String] ?? []
        }
    }
    
    ///True if the user has favorited this event.
    public var isFavorited: Bool {
        set {
            self.isFavoritedLocal = newValue
        }
        get {
            guard let isFavoritedLocal = self.isFavoritedLocal else {
                self.isFavoritedLocal = Event.favoriteIDs.contains(self.calendarEvent?.eventUniqueID ?? "")
                return self.isFavoritedLocal ?? false
            }
            return isFavoritedLocal
        }
    }
    private var isFavoritedLocal: Bool?
    
    ///`Event.SubCategory`: represents a sub category this event belongs to, based on keywords.
    public enum SubCategory: String {
        case VFB, JVFB, Golf, FH, JVBBSB, VBBSB, BSoccer, GSoccer, BTennis, GTennis, Track, VB, Graduation, Faculty, DepartmentChair, FBLA, DECA, Band, Chorus, SOL, AP, Theatre, BBB, GBB, Senior
        
        ///The athletics subcategories.
        static let athletics: [SubCategory] = [.JVFB, .VFB, .Golf, .FH, .JVBBSB, .VBBSB, .BSoccer, .GSoccer, .BTennis, .GTennis, .Track, .VB, .BBB, .GBB]
        
        ///The academic subcategories.
        static let academics: [SubCategory] = [.Graduation, .Faculty, .DepartmentChair, .FBLA, .DECA, .Band, .Chorus, .SOL, .AP, .Theatre, .Senior]
        
        ///The title to display for this category.
        public var displayTitle: String {
            switch self {
            case .VFB :
                return "Varsity Football"
            case .JVFB :
                return "JV Football"
            case .FH :
                return "Field Hockey"
            case .VBBSB :
                return "Varsity Baseball / Softball"
            case .JVBBSB :
                return "JV Baseball / Softball"
            case .BSoccer :
                return "Boys Soccer"
            case .GSoccer :
                return "Girls Soccer"
            case .BTennis :
                return "Boys Tennis"
            case .VB :
                return "Volleyball"
            case .DepartmentChair :
                return "Department Chair"
            case .BBB :
                return "Boys Basketball"
            case .GBB :
                return "Girls Basketball"
            default :
                return self.rawValue
            }
        }
        
        public var searchTerm: String {
            switch self {
            case .VBBSB :
                return "V BB/SB"
            case .JVBBSB :
                return "JV BB/SB"
            default :
                return self.rawValue
            }
        }
        
        ///Icon to display with this subcategory.
        public var icon: UIImage {
            if SubCategory.athletics.contains(self) {
                return UIImage(named: "athletics")!
            }
            switch self {
            case .Graduation, .Senior :
                return UIImage(named: "graduation")!
            case .AP :
                return UIImage(named: "AP")!
            case .Band :
                return UIImage(named: "band")!
            case .DECA :
                return UIImage(named: "decaLogo")!
            case .FBLA :
                return UIImage(named: "fblaLogo")!
            case .DepartmentChair :
                return UIImage(named: "departmentChair")!
            case .SOL :
                return UIImage(named: "SOL")!
            case .Theatre :
                return UIImage(named: "theatre")!
            default :
                return UIImage(named: "academics")!
            }
        }
    }
    
    //MARK: - Initialization.
    public init(withMXLCalendarEvent calendarEvent: MXLCalendarEvent) {
        self.calendarEvent = calendarEvent
    }
    
    //MARK: - Favoriting.
    ///Favorites or unfavorites this event, depending on whether or not it's GUID is in the favorited event id array.
    public func favorite() {
        if let guid = self.calendarEvent?.eventUniqueID {
            if Event.favoriteIDs.contains(guid) {
                //Unfavorite.
                for i in 0..<Event.favoriteIDs.count {
                    if Event.favoriteIDs[i] == guid {
                        Event.favoriteIDs.remove(at: i)
                        self.isFavorited = false
                        return
                    }
                }
            }
            else {
                //Favorite.
                Event.favoriteIDs.append(guid)
                self.isFavorited = true
            }
        }
    }
    
    //MARK: - Retrieval.
    ///The url to the school's ICS feed.
    private static let icsURL = URL(string: "https://www.calendarwiz.com/CalendarWiz_iCal.php?crd=kgcs&ical_days_ahead=150&ical_days_back=0&cid[]=132859&cid[]=133033")
    
    ///Retrieves all events currently in the school's ICS feed.
    public class func retrieve(allEventsWithCompletion completion: @escaping ([Event]?)->Void) {
        //Run in background thread.
        DispatchQueue.global(qos: .background).async {
            //Unwrap url.
            if let url = icsURL {
                do {
                    //Retrieve ICS data.
                    let data = try Data(contentsOf: url)
                    //Convert ICS data to string.
                    if let icsString = String(data: data, encoding: .utf8) {
                        
                        //Parse the ICS string.
                        let calendarManager = MXLCalendarManager()
                        calendarManager.parseICSString(icsString) { (calendar, error) in
                            guard let calendar = calendar, error == nil else {
                                print(error?.localizedDescription ?? "Error occurred.")
                                DispatchQueue.main.async {
                                    completion(nil)
                                }
                                return
                            }
                            
                            var events = [Event]()
                            //Process mxl calendar events.
                            for mxlEvent in calendar.events as! [MXLCalendarEvent] {
                                let processedEvent = Event.process(from: mxlEvent)
                                if processedEvent.category != .extraneous {
                                    events.append(processedEvent)
                                }
                            }
                            //Run the completion block.
                            DispatchQueue.main.async {
                                completion(events)
                            }
                        }
                    }
                }
                catch {
                    print(error)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }
        }
    }
    
    private class func process(from calendarEvent: MXLCalendarEvent) -> Event {
        //Convert to `Event`.
        let event = Event(withMXLCalendarEvent: calendarEvent)
        
        //Set the event's subcategory.
        event.setSubCategory()
        
        event.isFavoritedLocal = Event.favoriteIDs.contains(event.calendarEvent?.eventUniqueID ?? "")
        
        return event
    }
    
    private func setSubCategory() {
        if self.category == .kghs {
            //Academic event, search through academic subcategories.
            for sCategory in SubCategory.academics {
                if self.calendarEvent?.eventSummary.contains(sCategory.searchTerm) ?? false {
                    self.subCategory = sCategory
                    self.calendarEvent?.eventSummary = self.calendarEvent?.eventSummary.replacingOccurrences(of: sCategory.searchTerm, with: sCategory.displayTitle)
                    return
                }
            }
        }
        else {
            //Athletic event, search through athletic subcategories.
            for sCategory in SubCategory.athletics {
                if self.calendarEvent?.eventSummary.contains(sCategory.searchTerm) ?? false {
                    self.subCategory = sCategory
                    self.calendarEvent?.eventSummary = self.calendarEvent?.eventSummary.replacingOccurrences(of: sCategory.searchTerm, with: sCategory.displayTitle)
                    return
                }
            }
        }
    }
}
