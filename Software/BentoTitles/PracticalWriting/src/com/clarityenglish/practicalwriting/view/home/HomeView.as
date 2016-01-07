package com.clarityenglish.practicalwriting.view.home {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.MouseEvent;
import flash.geom.Point;

import mx.collections.XMLListCollection;

import mx.collections.XMLListCollection;

import org.osflash.signals.Signal;

import spark.components.Group;
import spark.components.Label;

import spark.components.List;
import spark.events.IndexChangeEvent;

public class HomeView extends BentoView {

    [SkinPart]
    public var courseList:List;

    [SkinPart]
    public var demoTooltipGroup:Group;

    [SkinPart]
    public var demoTooltipLabel1:Label;

    [Bindable]
    public var courseXMLListCollection:XMLListCollection;

    [Bindable]
    public var userNameCaption:String;

    public var courseSelect:Signal = new Signal(XML);

    public function HomeView() {
        actionBarVisible = false;
    }

    override protected function updateViewFromXHTML(xhtml:XHTML):void {
        super.updateViewFromXHTML(xhtml);

        courseXMLListCollection = new XMLListCollection(xhtml..menu.course);
    }

    override protected function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);

        switch (instance) {
            case courseList:
                courseList.addEventListener(IndexChangeEvent.CHANGE, onIndexChange);
                courseList.addEventListener(MouseEvent.CLICK, onCourseListClick);
                break;
            case demoTooltipLabel1:
                demoTooltipLabel1.text = copyProvider.getCopyForId("demoTooltipLabel");
                break;
        }
    }

    protected override function commitProperties():void {
        super.commitProperties();

        // gh#1194
        userNameCaption = '';
        if (config.username == null || config.username == '') {
            if (config.email)
                userNameCaption = copyProvider.getCopyForId('welcomeLabel', {name: config.email});
        } else if (config.username.toLowerCase() != 'anonymous') {
            userNameCaption = copyProvider.getCopyForId('welcomeLabel', {name: config.username});
        }
    }

    protected function onIndexChange(event:IndexChangeEvent):void {
        if (event.target.selectedItem)
            courseSelect.dispatch(event.target.selectedItem);
    }

    protected function onCourseListClick(event:MouseEvent):void {
        demoTooltipGroup.visible = false;
        if (productVersion == BentoApplication.DEMO && courseList.selectedIndex == -1) {
            var pt:Point = new Point(event.localX, event.localY);
            pt = event.target.localToGlobal(pt);
            if(pt.x > 730) {
                demoTooltipGroup.left = pt.x - demoTooltipGroup.width - 10;
            } else {
                demoTooltipGroup.left = pt.x + 10;
            }
            demoTooltipGroup.top = pt.y + 10;

            demoTooltipGroup.visible = true;
        }
    }
}
}
