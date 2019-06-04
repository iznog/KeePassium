//  KeePassium Password Manager
//  Copyright © 2018–2019 Andrei Popleteev <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

extension PremiumFeature {
    
    public var titleName: String {
        switch self {
        case .canUseMultipleDatabases:
            return "Multiple Databases".localized(comment: "Title of a premium feature: ability to use multiple databases (In Title Case)")
        case .canUseBiometricAppLock:
            return "Biometric Unlock".localized(comment: "Title of a premium feature: ability to use Touch ID / Face ID in AppLock settings (In Title Case)")
        case .canUseLongDatabaseTimeouts:
            return "Long Database Timeouts".localized(comment: "Title of a premium feature: ability to set long delays in Database Lock Timeout settings (In Title Case)")
        case .canEditDatabase:
            return "Edit Database".localized(comment: "Title of a premium feature: ability to edit database: add/edit/delete new groups and entries (In Title Case)")
        case .canPreviewAttachments:
            return "Preview Attachments".localized(comment: "Title of a premium feature: ability to preview some attached files directly in the app (In Title Case)")
        case .canRememberKeyFiles:
            return "Remember Key Files".localized(comment: "Title of a premium feature: ability to enable 'Remember Key Files' setting, that is to remember which key file was used with which database (In Title Case)")
        }
    }
    
    public var upgradeNoticeText: String {
        switch self {
        case .canUseMultipleDatabases:
            return "Easily switch between databases in the premium version.".localized(comment: "Description/advertisement for the `Multiple Databases` premium feature")
        case .canUseBiometricAppLock:
            return "Quickly access your passwords using Face ID/Touch ID in the premium version.".localized(comment: "Description/advertisement for the `Biometric Unlock` premium feature")
        case .canUseLongDatabaseTimeouts:
            return "Save time entering your complex master passwords — keep your database open longer in the premium version.".localized(comment: "Description/advertisement for the `Long Database Timeouts` premium feature")
        case .canEditDatabase:
            return "Edit your database, generate new passwords, add new entries and attachments in the premium version.".localized(comment: "Description/advertisement for the `Edit Database` premium feature")
        case .canPreviewAttachments:
            return "Preview images and documents directly in the app, in the premium version.".localized(comment: "Description/advertisement for the `Preview Attachments` premium feature")
        case .canRememberKeyFiles:
            return "Save time selecting key files — automatically select the previously used one".localized(comment: "Description/advertisement for the `Remember Key Files` premium feature")
        }
    }
}