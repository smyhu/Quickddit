/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

AbstractPage {
    id: aboutSubredditPage

    property alias subreddit: aboutSubredditManager.subreddit

    title: "About " + (aboutSubredditManager.url || "Subreddit")
    busy: aboutSubredditManager.busy
    onHeaderClicked: flickable.contentY = 0;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton {
            text: aboutSubredditManager.isSubscribed ? "Unsubscribe" : "Subscribe"
            enabled: !aboutSubredditManager.busy && aboutSubredditManager.isValid
            visible: quickdditManager.isSignedIn
            platformStyle: ToolButtonStyle { disabledBackground: "" } // prevent missing image warning text
            onClicked: aboutSubredditManager.subscribeOrUnsubscribe();
        }
        Item { width: 80; height: 64 }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: flickableColumn.height + 2 * constant.paddingMedium

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium
            visible: aboutSubredditManager.isValid

            Item {
                anchors { left: parent.left; right: parent.right }
                height: Math.max(headerImage.height, titleText.height)

                Image {
                    id: headerImage
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    source: aboutSubredditManager.headerImageUrl
                    asynchronous: true
                }

                Text {
                    id: titleText
                    anchors {
                        left: headerImage.right
                        leftMargin: headerImage.status == Image.Ready ? constant.paddingLarge : 0
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    elide: Text.ElideRight
                    font.pixelSize: constant.fontSizeLarge
                    color: constant.colorLight
                    font.bold: true
                    text: aboutSubredditManager.subreddit
                }
            }

            Text {
                anchors { left: parent.left; right: parent.right }
                visible: aboutSubredditManager.isNSFW
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorNegative
                font.italic: true
                text: "This subreddit is Not Safe For Work"
            }

            Text {
                id: shortDescriptionText
                anchors { left: parent.left; right: parent.right }
                wrapMode: Text.Wrap
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorMid
                text: aboutSubredditManager.shortDescription
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                spacing: constant.paddingMedium

                CustomCountBubble {
                    value: aboutSubredditManager.subscribers
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: "subscribers"
                }

                CustomCountBubble {
                    value: aboutSubredditManager.activeUsers
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: "active users"
                }
            }

            Text {
                anchors { left: parent.left; right: parent.right }
                visible: quickdditManager.isSignedIn
                font.pixelSize: constant.fontSizeMedium
                color: aboutSubredditManager.isSubscribed ? constant.colorPositive : constant.colorNegative
                text: aboutSubredditManager.isSubscribed ? "Subscribed" : "Not Subscribed"
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorMid
                visible: longDescriptionText != ""
            }

            Text {
                id: longDescriptionText
                anchors { left: parent.left; right: parent.right }
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                text: aboutSubredditManager.longDescription
                onLinkActivated: globalUtils.openInTextLink(link);
            }
        }
    }

    ScrollDecorator { flickableItem: flickable }

    AboutSubredditManager {
        id: aboutSubredditManager
        manager: quickdditManager
        onSubscribeSuccess: {
            if (isSubscribed) {
                infoBanner.alert(qsTr("You have subscribed to %1").arg(url))
            } else {
                infoBanner.alert(qsTr("You have unsubscribed from %1").arg(url))
            }
        }
        onError: infoBanner.alert(errorString)
    }
}
