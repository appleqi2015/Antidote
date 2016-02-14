//
//  ProfileMainController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/11/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol ProfileMainControllerDelegate: class {
    func profileMainControllerLogout(controller: ProfileMainController)
    func profileMainControllerChangeUserName(controller: ProfileMainController)
    func profileMainControllerChangeUserStatus(controller: ProfileMainController)
    func profileMainControllerChangeStatusMessage(controller: ProfileMainController)
    func profileMainController(controller: ProfileMainController, showQRCodeWithText text: String)
    func profileMainControllerShowProfileDetails(controller: ProfileMainController)
}

class ProfileMainController: StaticTableController {
    weak var delegate: ProfileMainControllerDelegate?

    private weak var submanagerUser: OCTSubmanagerUser!
    private let avatarManager: AvatarManager

    private let avatarModel = StaticTableAvatarCellModel()
    private let userNameModel = StaticTableDefaultCellModel()
    private let statusMessageModel = StaticTableDefaultCellModel()
    private let userStatusModel = StaticTableDefaultCellModel()
    private let toxIdModel = StaticTableDefaultCellModel()
    private let profileDetailsModel = StaticTableDefaultCellModel()
    private let logoutModel = StaticTableButtonCellModel()

    init(theme: Theme, submanagerUser: OCTSubmanagerUser) {
        self.submanagerUser = submanagerUser

        avatarManager = AvatarManager(theme: theme)

        super.init(theme: theme, style: .Plain, model: [
            [
                avatarModel,
            ],
            [
                userNameModel,
                statusMessageModel,
            ],
            [
                userStatusModel,
            ],
            [
                toxIdModel,
            ],
            [
                profileDetailsModel,
            ],
            [
                logoutModel,
            ],
        ])

        updateModels()

        title = String(localized: "profile_title")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateModels()
        reloadTableView()
    }
}

private extension ProfileMainController {
    func updateModels() {
        avatarModel.avatar = avatarManager.avatarFromString(
                submanagerUser.userName(),
                diameter: StaticTableAvatarCellModel.Constants.AvatarImageSize)
        avatarModel.userInteractionEnabled = false

        userNameModel.title = String(localized: "name")
        userNameModel.value = submanagerUser.userName()
        userNameModel.rightImageType = .Arrow
        userNameModel.didSelectHandler = changeUserName

        // Hardcoding any connected status to show only online/away/busy statuses here.
        let userStatus = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: submanagerUser.userStatus)

        userStatusModel.userStatus = userStatus
        userStatusModel.value = userStatus.toString()
        userStatusModel.rightImageType = .Arrow
        userStatusModel.didSelectHandler = changeUserStatus

        statusMessageModel.title = String(localized: "status_message")
        statusMessageModel.value = submanagerUser.userStatusMessage()
        statusMessageModel.rightImageType = .Arrow
        statusMessageModel.didSelectHandler = changeStatusMessage

        toxIdModel.title = String(localized: "my_tox_id")
        toxIdModel.value = submanagerUser.userAddress
        toxIdModel.rightButton = String(localized: "show_qr")
        toxIdModel.rightButtonHandler = showToxIdQR
        toxIdModel.userInteractionEnabled = false
        toxIdModel.canCopyValue = true

        profileDetailsModel.value = String(localized: "profile_details")
        profileDetailsModel.didSelectHandler = showProfileDetails
        profileDetailsModel.rightImageType = .Arrow

        logoutModel.title = String(localized: "logout_button")
        logoutModel.didSelectHandler = logout
    }

    func logout() {
        delegate?.profileMainControllerLogout(self)
    }

    func changeUserName() {
        delegate?.profileMainControllerChangeUserName(self)
    }

    func changeUserStatus() {
        delegate?.profileMainControllerChangeUserStatus(self)
    }

    func changeStatusMessage() {
        delegate?.profileMainControllerChangeStatusMessage(self)
    }

    func showToxIdQR() {
        delegate?.profileMainController(self, showQRCodeWithText: submanagerUser.userAddress)
    }

    func showProfileDetails() {
        delegate?.profileMainControllerShowProfileDetails(self)
    }
}