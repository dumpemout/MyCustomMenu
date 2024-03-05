//
// Copyright 2018-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

//! This is the Images custom menu, which shows an
//! image and text for each item
class StatusMenu extends WatchUi.CustomMenu {

    //! Constructor
    //! @param itemHeight The pixel height of menu items rendered by this menu
    //! @param backgroundColor The color for the menu background
    //! @param options A Dictionary with options for the CustomMenu object
    public function initialize() {
        var itemHeight = System.getDeviceSettings().screenHeight/5;

        var options = {
            :theme => null,
            :titleItemHeight => itemHeight,
            :focusItemHeight => (itemHeight*1.1).toNumber()
        };

        CustomMenu.initialize(itemHeight, Graphics.COLOR_BLACK, options);
        
        addItem(new StatusMenuItem(:device1, "Device 1"));
        addItem(new StatusMenuItem(:device2, "Device 2"));
        addItem(new StatusMenuItem(:device3, "Device 3"));
        addItem(new StatusMenuItem(:device4, "Device 4"));
        addItem(new StatusMenuItem(:device5, "Device 5"));
    }

    //! Draw the menu title
    //! @param dc Device Context
    public function drawTitle(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0, dc.getHeight() - 2, dc.getWidth(), dc.getHeight() - 2);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_XTINY, "Device Statuses", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

//! This is the menu input delegate for the images custom menu
class StatusMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle an item being selected
    //! @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        WatchUi.requestUpdate();
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

//! This is the custom item drawable.
//! It draws the item's bitmap and label.
class StatusMenuItem extends WatchUi.CustomMenuItem {

    private var _label as String;
    private var _icon as BitmapReference;
    private var _fontLabel as FontReference;
    private var _fontSubLabel as FontReference;
    private var _status as Array<Number or BitmapReference>;

    //! Constructor
    //! @param id The identifier for this item
    //! @param label Text to display
    public function initialize(id as Symbol, label as String) {
        CustomMenuItem.initialize(id, {});
        _label = label;
        _icon = WatchUi.loadResource($.Rez.Drawables.heartWhite);
        _fontLabel = Graphics.FONT_XTINY as FontReference;
        _fontSubLabel = Graphics.FONT_XTINY as FontReference;
        _status = [null as Number, null as BitmapReference];
    }

    //! Draw the item's label and bitmap
    //! @param dc Device context
    public function draw(dc as Dc) as Void {

        var marginX = 10;
        var statusValue = "Status: ";

        //when item is in focus, display the corresponding Icon and Device Status, otherwise just display the Label
        if (isFocused()) {
            //get the device status array [value, icon]
            _status = getDeviceStatus();

            //make label a bit bigger while in focus
            _fontLabel = Graphics.FONT_TINY as FontReference;

            //create a semi-transparent box around the focus item and a vertical slanted line since we removed the default theme
            dc.setFill(Graphics.createColor(100, 0, 100, 100));
            dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
            dc.setColor(Graphics.createColor(255, 0, 100, 100), Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
            dc.drawLine(0, dc.getHeight(), 5, 0);

            //set color back to white to draw text labels
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

            //draw the corresponding icon based on the statusValue (red, yellow, green, or white = unknown)
            dc.drawBitmap(marginX, _status[1].getHeight()/2, _status[1]);

            //set status label
            statusValue += _status[0] == null ? "Unknown" : _status[0];

            //draw device label
            dc.drawText(marginX + _status[1].getWidth() + 5, 2, _fontLabel, _label, Graphics.TEXT_JUSTIFY_LEFT);
            //draw the device status value between 1-100
            dc.drawText(marginX + _status[1].getWidth() + 5, dc.getHeight()-dc.getFontHeight(_fontSubLabel), _fontSubLabel, statusValue, Graphics.TEXT_JUSTIFY_LEFT);
            
        } else {
            //if device is not in focus, only draw the label and make it smaller than the focus item
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            _fontLabel = Graphics.FONT_XTINY as FontReference;
            dc.drawText(marginX + _icon.getWidth() + 5, dc.getHeight()/2, _fontLabel, _label, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

        }

        //if the item is selected, draw it accordingly... maybe a different colored semi-transparent box? 
        //left it unchanged from the Menu2Sample code
        if (isSelected()) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
            dc.clear();
        }

    }
}

//dummy Device Status function that returns a random number between 1-100 and the corresponding icon in an Array
public function getDeviceStatus() as Array {
    var statusValue = 100 + Math.rand() / ((0x7FFFFFFF).toFloat() / (0 - 100 + 1) + 1).toNumber();
    var statusIcon = statusValue < 34 ? WatchUi.loadResource($.Rez.Drawables.heartRed) : 
                     statusValue < 67 ? WatchUi.loadResource($.Rez.Drawables.heartYellow) : 
                     statusValue < 101 ? WatchUi.loadResource($.Rez.Drawables.heartGreen) : WatchUi.loadResource($.Rez.Drawables.heartWhite);
    return [statusValue, statusIcon];
}