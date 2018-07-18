//
//  Event.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/17/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import MXLCalendarManager

///`Event`: represents an iCal event fetched from the school's ics feed.
class Event: MXLCalendarEvent {
    
    //MARK: - Properties.
    ///The category of this event.
    public var category: Category {
        return (self.eventCategory == "KGHS Athletics") ? .athletics : .kghs
    }
    
    ///`Event.Category`: represents the category this event came from.
    public enum Category {
        case kghs, athletics
    }
    
    //MARK: - Retrieval.
    ///The url to the school's ICS feed.
    private static let icsURL = URL(string: "https://www.calendarwiz.com/CalendarWiz_iCal.php?crd=kgcs")
    
    ///Retrieves all events currently in the school's ICS feed.
    public class func retrieve(allEventsWithCompletion completion: @escaping ([Event]?)->Void) {
        if let url = icsURL {
            do {
                //Retrieve ICS data.
                let data = try Data(contentsOf: url)
                if let icsString = String(data: data, encoding: .utf8) {
                    let calendarManager = MXLCalendarManager()
                    calendarManager.parseICSString(icsString) { (calendar, error) in
                        guard let calendar = calendar, error == nil else {
                            print(error?.localizedDescription ?? "Error occurred.")
                            return
                        }
                        
                        for event in calendar.events as! [MXLCalendarEvent] {
                            
                        }
                    }
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    private func process(calendarEvent: MXLCalendarEvent) -> Event {
        //Convert to `Event`.
        let event = calendarEvent as! Event
        
        return event
    }
}
