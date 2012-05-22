/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project on Qt Labs.
**
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions contained
** in the Technology Preview License Agreement accompanying this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

import QtQuick 1.1
import com.nokia.meego 1.0

/*
   Class: PageIndicator
   Component to indicate the page user is currently viewing.

   A page indicator is a component that shows the number of availabe pages as well as the page the user is
   currently on.  The user can also specify the display type to select the normal/inverted visual.
*/
ImplicitSizeItem {
    id: root

    /*
     * Property: totalPages
     * [int] The total number of pages.  This value should be larger than 0.
     */
    property int totalPages: 0

    /*
     * Property: currentPage
     * [int] The current page the user is on.  This value should be larger than 0.
     */
    property int currentPage: 0

    /*
     * Property: inverted
     * [bool] Specify whether the visual for the rating indicator uses the inverted color.  The value is
     * false for use with a light background and true for use with a dark background.
     */
    property bool inverted: false

    implicitWidth: currentImage.width * totalPages + (totalPages - 1) * internal.spacing
    implicitHeight: currentImage.height

    /* private */
    QtObject {
        id: internal

        property int spacing: 8

        property string totalPagesImageSource: !inverted ?
                                                 "image://theme/meegotouch-inverted-pageindicator-page" :
                                                 "image://theme/meegotouch-pageindicator-page"
        property string currentPageImageSource: !inverted ?
                                                  "image://theme/meegotouch-inverted-pageindicator-page-current" :
                                                  "image://theme/meegotouch-pageindicator-page-current"

        property bool init: true


        function updateUI() {

            if(totalPages <=0) {
                totalPages = 1;
                currentPage = 1;
            } else {
                if(currentPage <=0)
                    currentPage = 1;
                if(currentPage > totalPages)
                    currentPage = totalPages;
            }

            frontRepeater.model = currentPage - 1;
            backRepeater.model = totalPages - currentPage;
        }
    }

    Component.onCompleted: {
        internal.updateUI();
        internal.init = false;
    }

    onTotalPagesChanged: {
        if(!internal.init)
            internal.updateUI();
    }

    onCurrentPageChanged: {
        if(!internal.init)
            internal.updateUI();
    }

    Row {
        Repeater {
             id: frontRepeater

             Item {
                 height: currentImage.height
                 width:  currentImage.width + internal.spacing

                 Image {
                     source: internal.totalPagesImageSource
                 }
             }
         }

         Image {
             id: currentImage
             source:  internal.currentPageImageSource
         }

         Repeater {
             id: backRepeater

             Item {
                 height: currentImage.height
                 width:  currentImage.width + internal.spacing

                 Image {
                     source: internal.totalPagesImageSource
                     anchors.right: parent.right
                 }
             }
         }
    }
}

