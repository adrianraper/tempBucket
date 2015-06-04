package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.alivepdf.pdf.PDF;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.vo.manageable.User;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.navigateToURL;
import flash.utils.ByteArray;

import flashx.textLayout.elements.TextFlow;

import mx.controls.SWFLoader;

import org.alivepdf.display.Display;
import org.alivepdf.fonts.CoreFont;
import org.alivepdf.fonts.FontFamily;
import org.alivepdf.fonts.IFont;
import org.alivepdf.layout.Orientation;
import org.alivepdf.layout.Size;
import org.alivepdf.layout.Unit;
import org.alivepdf.saving.Method;
import org.davekeen.util.DateUtil;
import org.osflash.signals.Signal;

import spark.components.Button;
import spark.components.Label;
import spark.components.RichEditableText;
import spark.components.VGroup;
import spark.utils.TextFlowUtil;

public class ProgressCertificateView extends BentoView {

    [SkinPart]
    public var notCompleteRichEditableText:RichEditableText;

    [SkinPart]
    public var oopsVGroup:VGroup;

    [SkinPart]
    public var certificateSWFLoader:SWFLoader;

    [SkinPart]
    public var nameTextLabel:Label;

    [SkinPart]
    public var nameLabel:Label;

    [SkinPart]
    public var courseTextLabel:Label;

    [SkinPart]
    public var courseLabel:Label;

    [SkinPart]
    public var dateTextLabel:Label;

    [SkinPart]
    public var dateLabel:Label;

    [SkinPart]
    public var certificateRichEditableText:RichEditableText;

    [SkinPart]
    public var certificateGroup:spark.components.Group;

    [SkinPart]
    public var printButton:Button;

    [SkinPart]
    public var certificateFooter:SWFLoader;

    [SkinPart]
    public var certificateSignatureNameLabel:Label;

    [SkinPart]
    public var certificateSignatureTitle:Label;

    [Embed(source="/skins/practicalwriting/assets/progress/certificate.png")]
    [Bindable]
    private static var certificateClass:Class;

    private var _isPlatformTablet:Boolean;
    private var aveScore:Number = 0;
    //private var pdf:PDF;

    [Bindable]
    public var user:User;

    public var courseSelect:Signal = new Signal(String);

    /**
     * This can be called from outside the view to make the view display a different course
     *
     * @param XML A course node from the menu
     *
     */

    public function set isPlatformTablet(value:Boolean):void {
        _isPlatformTablet = value;
    }

    [Bindable]
    public function get isPlatformTablet():Boolean {
        return _isPlatformTablet;
    }

    protected override function onViewCreationComplete():void {
        super.onViewCreationComplete();

        nameLabel.text = user.fullName;
        printButton.label = copyProvider.getCopyForId("printButton");
        nameTextLabel.text = copyProvider.getCopyForId("nameTextLabel");
        courseTextLabel.text = copyProvider.getCopyForId("courseTextLabel");
        dateTextLabel.text = copyProvider.getCopyForId("dateTextLabel");
        certificateSignatureNameLabel.text = copyProvider.getCopyForId("certificateSignatureNameLabel");
        certificateSignatureTitle.text = copyProvider.getCopyForId("certificateSignatureTitle");
    }

    protected override function updateViewFromXHTML(xhtml:XHTML):void {
        super.updateViewFromXHTML(xhtml);

        var totalCourse:Number = menu.course.length();
        var coverage:Number = 0;
        var exerciseAmount:Number = 0;
        var totalExercise:Number = 0;
        for (var i:Number = 0; i < totalCourse; i++) {
            var courseXML:XML = menu.course[i];
            var unitXMLList:XMLList = courseXML.unit.(@["class"] == "learning");
            var totalExercisePerUnit:Number = unitXMLList.exercise.length();
            for (var j:Number = 0; j < totalExercisePerUnit; j++) {
                if (unitXMLList.exercise[j].attribute("done").length() > 0) {
                    exerciseAmount++;
                }
            }
            totalExercise += totalExercisePerUnit;
            coverage += Number(courseXML.@coverage);
            aveScore += Number(courseXML.@averageScore);
        }
        aveScore = aveScore / totalCourse;
        oopsVGroup.visible = false;
        certificateGroup.visible = false;
        printButton.visible = false;
        trace("coverage: "+coverage);
        if (coverage > 90) {
            oopsVGroup.visible = true;
            var notCompleteString:String = copyProvider.getCopyForId("notCompleteString", {exerciseAmount: exerciseAmount, totalExercise: totalExercise, aveScor: aveScore});
            var textFlow:TextFlow = TextFlowUtil.importFromString(notCompleteString);
            notCompleteRichEditableText.textFlow = textFlow;
        } else {
            certificateGroup.visible = true;
            if (isPlatformTablet) {
                printButton.visible = false;
            } else {
                printButton.visible = true;
            }
            var completeString:String = copyProvider.getCopyForId("completeString", {aveScore: aveScore});
            var completeTextFlow:TextFlow = TextFlowUtil.importFromString(completeString);
            certificateRichEditableText.textFlow = completeTextFlow;
        }
    }

    protected override function commitProperties():void {
        super.commitProperties();
    }

    protected override function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);

        switch (instance) {
            case dateLabel:
                var date:Date = new Date();
                dateLabel.text = DateUtil.formatDate(date, "dd MMMM yyyy");
                break;
            case printButton:
                printButton.addEventListener(MouseEvent.CLICK, onPrintClick);
                break;
        }
    }

    /**
     * The user has changed the course to be displayed
     *
     * @param String course class name
     */
    public function onCourseSelect(event:Event):void {
        courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
    }

    // gh#1038 Redone
    protected function onPrintClick(event:MouseEvent):void {
        var pdf:PDF = new PDF(Orientation.LANDSCAPE, Unit.MM, Size.A4);

        // set the zoom to 100% (applies when it is opened in Reader)
        pdf.setDisplayMode(Display.FULL_WIDTH, org.alivepdf.layout.Layout.SINGLE_PAGE);

        // add a page
        pdf.addPage();

        // Add background graphic
        // This would be fine if it wasn't dependent on scrolling in a shallow window.
        //pdf.addImage(certificateGroup, null, -25, 0, 290);
        /*var swfLoader:SWFLoader = new SWFLoader();
        swfLoader.source = certificateClass;*/
        pdf.addImage(new certificateClass(), null, -10, -10, 297);

        // add labels and certificate wording
        var arialNormal:IFont = new CoreFont(FontFamily.HELVETICA);
        var arialBold:IFont = new CoreFont(FontFamily.HELVETICA_BOLD);
        pdf.setFont(arialNormal, 11);

        pdf.setXY(10, 55);
        pdf.addCell(50, 10, nameTextLabel.text, 0, 0, 'R');
        pdf.setXY(10, 65);
        pdf.addCell(50, 10, courseTextLabel.text, 0, 0, 'R');
        pdf.setXY(10, 75);
        pdf.addCell(50, 10, dateTextLabel.text, 0, 0, 'R');

        pdf.setFont(arialBold, 13);
        var replaceObj:Object = { name:nameLabel.text };
        pdf.setXY(62, 55);
        pdf.addCell(50, 10, copyProvider.getCopyForId("certificateName",replaceObj), 0, 0, 'L');
        replaceObj = { course:courseLabel.text };
        pdf.setXY(62, 65);
        pdf.addCell(50, 10, copyProvider.getCopyForId("certificateCourse",replaceObj), 0, 0, 'L');
        replaceObj = { date:dateLabel.text };
        pdf.setXY(62, 75);
        pdf.addCell(50, 10, copyProvider.getCopyForId("certificateDate",replaceObj), 0, 0, 'L');

        pdf.setFont(arialNormal, 13);
        var aveScore:Number = aveScore;
        pdf.setXY(88, 92);
        pdf.addMultiCell(120, 6, copyProvider.getCopyForId("certificateWording", {score: aveScore}), 0, 'C');

        pdf.setFont(arialBold, 11);
        pdf.setXY(57, 163);
        pdf.addCell(50, 10, copyProvider.getCopyForId("certificateSignatureNameLabel"), 0, 0, 'C');
        pdf.setXY(57, 163);
        pdf.addCell(50, 20, copyProvider.getCopyForId("certificateSignatureTitle"), 0, 0, 'C');

        var pdfURL:String = "/Software/ResultsManager/web/amfphp/services/createPDF.php?filename=certificate.pdf";
        var bytesTemp:ByteArray = pdf.save(Method.LOCAL);
        var sendRequest:URLRequest = new URLRequest(pdfURL);
        sendRequest.method = URLRequestMethod.POST;
        sendRequest.data = bytesTemp;
        navigateToURL(sendRequest,'_blank');

        // Then close
        pdf.end();
    }
}
}