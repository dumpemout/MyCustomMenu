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

    var defaultIcon  = WatchUi.loadResource($.Rez.Drawables.heartWhite);

    private var _label as String;
    private var _icon as BitmapReference;
    private var _fontLabel as FontReference;
    private var _fontSubLabel as FontReference;
    private var _status as Array<Number or BitmapReference>;

    //! Constructor
    //! @param id The identifier for this item
    //! @param label Text to display
    //! @param bitmap Color of the text
    public function initialize(id as Symbol, label as String) {
        CustomMenuItem.initialize(id, {});
        _label = label;
        _icon = defaultIcon;
        _fontLabel = Graphics.FONT_XTINY as FontReference;
        _fontSubLabel = Graphics.FONT_XTINY as FontReference;
        _status = [null as Number, WatchUi.loadResource($.Rez.Drawables.heartWhite)];
    }

    //! Draw the item's label and bitmap
    //! @param dc Device context
    public function draw(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        if (isFocused()) {
            _status = getDeviceStatus();
            _fontLabel = Graphics.FONT_TINY as FontReference;

            if(_status[0] == null ) {
                dc.drawText(0, dc.getHeight()/2, _fontLabel, "?", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.drawBitmap(0, _status[1].getHeight()/2, _status[1]);
                dc.drawText(0 + _status[1].getWidth() + 5, 2, _fontLabel, _label, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(0 + _status[1].getWidth() + 5, dc.getHeight()-dc.getFontHeight(_fontSubLabel), _fontSubLabel, "Status: " + _status[0], Graphics.TEXT_JUSTIFY_LEFT);
            } 
            
        } else {
            _fontLabel = Graphics.FONT_XTINY as FontReference;
            dc.drawText(0 + _icon.getWidth() + 5, dc.getHeight()/2, _fontLabel, _label, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

        }

        if (isSelected()) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
            dc.clear();
        }

        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0, dc.getHeight() - 2, dc.getWidth(), dc.getHeight() - 2);
    }
}

public function getDeviceStatus() as Array {
    var statusValue = 100 + Math.rand() / ((0x7FFFFFFF).toFloat() / (0 - 100 + 1) + 1).toNumber();
    var statusIcon = statusValue < 34 ? WatchUi.loadResource($.Rez.Drawables.heartRed) : 
                     statusValue < 67 ? WatchUi.loadResource($.Rez.Drawables.heartYellow) : WatchUi.loadResource($.Rez.Drawables.heartGreen);
    return [statusValue, statusIcon];
}