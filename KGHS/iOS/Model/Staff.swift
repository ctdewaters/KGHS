//
//  Staff.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/17/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Foundation

///`Staff`: represents a staff member, stored on the server.
public class Staff: Codable {
    
    ///`Staff.Department`: represents the department of a staff member.
    public enum Department: Int {
        case CTE, FineArts, HealthPE, LanguageArts, Mathematics, NJROTC, Science, SocialStudies, SpecialEducation, WorldLanguages, BuildingServices, Counseling, DiningServices, InstructionalSupport, OfficeStaff, Administration
        
        ///The display title for this department.
        public var displayTitle: String {
            switch self {
            case .CTE :
                return "Career & Technology"
            case .FineArts :
                return "Fine Arts"
            case .HealthPE :
                return "Health & Physical Education"
            case .LanguageArts :
                return "Language Arts"
            case .Mathematics :
                return "Mathematics"
            case .NJROTC :
                return "NJROTC"
            case .Science :
                return "Science"
            case .SocialStudies :
                return "Social Studies"
            case .SpecialEducation :
                return "Special Education"
            case .WorldLanguages :
                return "World Languages"
            case .BuildingServices :
                return "Building Services"
            case .Counseling :
                return  "Counseling"
            case .DiningServices :
                return "Dining Services"
            case .InstructionalSupport :
                 return "Instructional Support"
            case .OfficeStaff :
                return "Office Staff"
            case .Administration :
                return "Administration"
            }
        }
    }
    
    ///The staff member's name.
    public var name: String?
    
    ///The staff member's voicemail extension.
    public var voicemailExt: String?
    
    ///The staff member's email address.
    public var email: String?
    
    ///The staff member's webpage URL, in String format.
    public var websiteURL: String?
    
    ///The organization this staff member is a part of, if applicable.
    public var organization: String?
    
    ///The storage id for this staff member.
    public var id: String?
    
    ///The department identifier for this staff member.
    private var department: String?
    
    ///1 if staff member is department chair, 0 if not.
    private var isDepartmentChair: String?
    
    ///The staff member's department.
    public var departmentValue: Department? {
        return Staff.Department(rawValue: Int(self.department ?? "-1") ?? -1)
    }

    ///Boolean value determining department chair.
    public var departmentChair: Bool {
        return Int(self.isDepartmentChair ?? "0") == 1
    }
    
    ///Favorite events ID array.
    public static var favoriteIDs: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: "favoriteStaffIDs")
        }
        get {
            return UserDefaults.standard.value(forKey: "favoriteStaffIDs") as? [String] ?? []
        }
    }
    
    ///True if the user has favorited this event.
    public var isFavorited: Bool {
        set {
            self.isFavoritedLocal = newValue
        }
        get {
            guard let isFavoritedLocal = self.isFavoritedLocal else {
                self.isFavoritedLocal = Staff.favoriteIDs.contains(self.id ?? "")
                return self.isFavoritedLocal ?? false
            }
            return isFavoritedLocal
        }
    }
    private var isFavoritedLocal: Bool?
    
    //MARK: - Favoriting.
    ///Favorites or unfavorites this staff memeber, depending on whether or not it's GUID is in the favorited staff member id array.
    public func favorite() {
        if let guid = self.id {
            if Staff.favoriteIDs.contains(guid) {
                //Unfavorite.
                for i in 0..<Staff.favoriteIDs.count {
                    if Staff.favoriteIDs[i] == guid {
                        Staff.favoriteIDs.remove(at: i)
                        self.isFavorited = false
                        return
                    }
                }
            }
            else {
                //Favorite.
                Staff.favoriteIDs.append(guid)
                self.isFavorited = true
            }
        }
    }

    //MARK: - Staff fetching.
    ///The url to the staff fetch script.
    private static let retrievalURL = URL(string: "https://collindewaters.me/kghs/scripts/retrieveStaff.php?iOSRetrieval2")
    
    ///Retrieves all staff members stored in database.
    public class func retrieveAll(withCompletion completion: @escaping ([Staff.Department: [Staff]]?, [Staff.Department]?) -> Void) {
        if let url = Staff.retrievalURL {
            //Run the data task.
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "Error occurred.")
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                    return
                }
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: String]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                        
                        ///Decode json data.
                        let jsonDecoder = JSONDecoder()
                        let retrievedStaff = try jsonDecoder.decode([Staff].self, from: jsonData)
                        
                        var staffDepartments = [Staff.Department]()
                        var sortedStaff = [Staff.Department: [Staff]]()
                        //Sort retrieved staff.
                        
                        for staffMember in retrievedStaff {
                            staffMember.isFavoritedLocal = Staff.favoriteIDs.contains(staffMember.id ?? "")
                            if let department = staffMember.departmentValue {
                                if !staffDepartments.contains(department) {
                                    //Department not yet set to the dictionary, add it and append the staff member.
                                    staffDepartments.append(department)
                                    sortedStaff[department] = [staffMember]
                                }
                                else {
                                    //Append the staff member to the correct array in the dictionary.
                                    sortedStaff[department]?.append(staffMember)
                                }
                            }
                        }
                        
                        //Sort staff departments alphabetically.
                        staffDepartments = staffDepartments.sorted {
                            return $0.displayTitle < $1.displayTitle
                        }
                        //Run completion block.
                        DispatchQueue.main.async {
                            completion(sortedStaff, staffDepartments)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                    return
                }
            }.resume()
        }
    }
}
