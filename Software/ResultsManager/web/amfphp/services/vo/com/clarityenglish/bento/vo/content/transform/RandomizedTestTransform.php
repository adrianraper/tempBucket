<?php
require_once(dirname(__FILE__)."/XmlTransform.php");
require_once("D:\Projectbench\Software\ResultsManager\web\amfphp\services\AbstractService.php");

class RandomizedTestTransform extends XmlTransform {
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.RandomizedTestTransform';
	
	public function transform($db, $xml, $href, $service) {
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$randArray = array();
		
		$xmlDoc = new DOMDocument();
		$xmlDoc->formatOutput = true;
		$xmlDoc->load($href->getUrl());
		$xmlQuestions = $xmlDoc->getElementsByTagName("questions")->item(0);
		$questionBanks = $xmlDoc->getElementsByTagName("questionBank");
		$xmlPath = new DOMXPath($xmlDoc);
		$xmlPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$multiQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]';
		$xmlBody = $xmlPath->query($multiQuery)->item(0);

		foreach ($questionBanks as $questionBank) {
			$bankHref = new Href();
			$bankHref->currentDir = $href->currentDir;
			$bankHref->filename = $questionBank->getAttribute('href');
			$bankDoc = new DOMDocument();
			$bankDoc->load($bankHref->getUrl());
			
			$xPath = new DOMXPath($bankDoc);
			$xPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

			$query = '/xmlns:bento/xmlns:head/xmlns:meta[@name="conversion-from"]';
			$questionType = $xPath->query($query)->item(0)->getAttribute('content');
			
			$randArray = array();
			AbstractService::$debugLog->info("question type: ".$questionType);
			if ($questionType == "multiplechoice") {
				//$multiQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:ol[@id="questionList_mc"]';
				//$xmlBody = $xmlPath->query($multiQuery)->item(0);
				$MultipleChoiceQuestion = $bankDoc->getElementsByTagName("MultipleChoiceQuestion");
				for($i = 0; $i < 5; $i ++) {
					$n = rand ( 0, 5 );
					// make sure $n is unique
					if (count ( $randArray ) > 0) {
						for($i = 0; $i < count ( $randArray ); $i ++) {
							if ($n == $randArray [$i]) {
								$n = rand ( 0, 24 );
								$i = - 1;
							}
						}
					}
					array_push ( $randArray, $n );
					// copy mutiple choice question and answer model from questionBank xml to template
					$multiQuestionModel = $MultipleChoiceQuestion->item ( $n );
					$xmlMultiModelNode = $xmlDoc->importNode ( $multiQuestionModel, true );
					$xmlQuestions->appendChild ( $xmlMultiModelNode );
					
					// copy question text to template
					$multiQuestionID = $MultipleChoiceQuestion->item ( $n )->getAttribute ( 'block' );
					AbstractService::$debugLog->info ( 'multiQuestionID: ' . $multiQuestionID );
					//$multiQuestionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:li[@id="' . $multiQuestionID . '"]';
					$multiQuestionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]/xmlns:div[@id="' . $multiQuestionID . '"]';
					$multiQuestionText = $xPath->query( $multiQuestionQuery )->item ( 0 );
					$xmlMultiQuestionNode = $xmlDoc->importNode ( $multiQuestionText, true );
					$xmlBody->appendChild ( $xmlMultiQuestionNode );
					
					// copy answer text to template
					/*$multiAnswerModelQuery = 'xmlns:answer';
					$multiAnswers = $xPath->query ( $multiAnswerModelQuery, $multiQuestionModel );
					foreach ( $multiAnswers as $multiAnswer ) {
						$multianswerID = $multiAnswer->getAttribute ( 'source' );
						$multiAnswerQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:a[@id="' . $multianswerID . '"]';
						$multiAnswerText = $xPath->query ( $multiAnswerQuery )->item ( 0 )->parentNode;
						$xmlMultiAnswerNode = $xmlDoc->importNode ( $multiAnswerText, true );
						$xmlBody->appendChild ( $xmlMultiAnswerNode );
					}*/
				}
			} else if ($questionType == "gapfill") {
				//$gapQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:ol[@id="questionList_gapfill"]';
				//$xmlBody = $xmlPath->query($gapQuery)->item(0);
				$gapFillQuestion = $bankDoc->getElementsByTagName("GapFillQuestion");
				for($i = 0; $i < 5; $i ++) {
					$n = rand ( 0, 24 );
					// make sure $n is unique
					if (count ( $randArray ) > 0) {
						for($i = 0; $i < count ( $randArray ); $i ++) {
							if ($n == $randArray [$i]) {
								$n = rand ( 0, 9 );
								$i = - 1;
							}
						}
					}
					array_push ( $randArray, $n );
					// copy mutiple choice question and answer model from questionBank xml to template
					$gapQuestionModel = $gapFillQuestion->item ( $n );
					$xmlGapModelNode = $xmlDoc->importNode ( $gapQuestionModel, true );
					$xmlQuestions->appendChild ( $xmlGapModelNode );
					
					// copy question text to template
					/*$gapQuestionID = $gapQuestionModel->getAttribute ( 'source' );
					AbstractService::$debugLog->info ( 'gapQuestionID: ' . $gapQuestionID );
					$gapQuestionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:input[@id="' . $gapQuestionID . '"]';
					$gapQuestionText = $xPath->query ( $gapQuestionQuery )->item ( 0 )->parentNode;
					$xmlGapQuestionNode = $xmlDoc->importNode ( $gapQuestionText, true );
					$xmlBody->appendChild ( $xmlGapQuestionNode );
					$gapLineQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:p[@class="linespace"]';
					$gapLine = $xPath->query ( $gapLineQuery )->item ( 0 );
					$xmlGapLineNode = $xmlDoc->importNode ( $gapLine );
					$xmlBody->appendChild ( $xmlGapLineNode );*/
					$gapQuestionID  = $gapFillQuestion->item ( $n )->getAttribute ( 'block' );
					$gapQuestionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]/xmlns:div[@id="' . $gapQuestionID . '"]';
					$gapQuestionText = $xPath->query ( $gapQuestionQuery )->item ( 0 );
					$xmlGapQuestionNode = $xmlDoc->importNode ( $gapQuestionText, true );
					$xmlBody->appendChild ( $xmlGapQuestionNode );
				}
			}
		}
		return $xmlDoc->saveXML();						
	}
}