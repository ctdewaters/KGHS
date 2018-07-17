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
    
    ///The department identifier for this staff member.
    private var department: Int?
    
    ///1 if staff member is department chair, 0 if not.
    private var isDepartmentChair: Int?
    
    ///The staff member's department.
    public var departmentValue: Department? {
        return Staff.Department(rawValue: self.department ?? -1)
    }

    ///Boolean value determining department chair.
    public var departmentChair: Bool {
        return self.isDepartmentChair == 1
    }
}
