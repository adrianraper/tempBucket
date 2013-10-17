<?php
require_once(dirname(__FILE__)."/XmlTransform.php");
require_once("D:\Projectbench\Software\ResultsManager\web\amfphp\services\AbstractService.php");

class RandomizedTestTransform extends XmlTransform {
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.RandomizedTestTransform';
	
	public function transform($db, $xml, $href, $service) {
		// gh#660
		$totalNumber = $href->options['totalNumber'];
		if ($totalNumber <= 0) {
			// default total question number in each question back is 5
			$totalNumber = 5;
		}
		
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
		$tempQuestions = new DOMDocument();
		$tempQuestions->formatOutput = true;
		$tempDoc = new DOMDocument();
		$tempDoc->formatOutput = true;

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
			//AbstractService::$debugLog->info("question type: ".$questionType);
			if ($questionType == "multiplechoice") {
				//$multiQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:ol[@id="questionList_mc"]';
				//$xmlBody = $xmlPath->query($multiQuery)->item(0);
				$MultipleChoiceQuestion = $bankDoc->getElementsByTagName("MultipleChoiceQuestion");
				for($i = 0; $i < $totalNumber; $i ++) {
					$n = rand ( 0, 24 );
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
					$xmlMultiModelNode = $tempQuestions->importNode ( $multiQuestionModel, true );
					$tempQuestions->appendChild ( $xmlMultiModelNode );					
					// copy question text to template
					$multiQuestionID = $MultipleChoiceQuestion->item ( $n )->getAttribute ( 'block' );
					//AbstractService::$debugLog->info ( 'multiQuestionID: ' . $multiQuestionID );
					$multiQuestionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]/xmlns:div[@id="' . $multiQuestionID . '"]';
					$multiQuestionText = $xPath->query( $multiQuestionQuery )->item ( 0 );		
					$xmlMultiQuestionNode = $tempDoc->importNode ( $multiQuestionText, true );
					$tempDoc->appendChild($xmlMultiQuestionNode);
				}
			} else if ($questionType == "gapfill") {
				//$gapQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]//xmlns:ol[@id="questionList_gapfill"]';
				//$xmlBody = $xmlPath->query($gapQuery)->item(0);
				$gapFillQuestion = $bankDoc->getElementsByTagName("GapFillQuestion");
				for($i = 0; $i < $totalNumber; $i ++) {
					$n = rand ( 0, 24 );
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
					$gapQuestionModel = $gapFillQuestion->item ( $n );
					$xmlGapModelNode = $tempQuestions->importNode ( $gapQuestionModel, true );
					$tempQuestions->appendChild ( $xmlGapModelNode );
					$gapQuestionID  = $gapFillQuestion->item ( $n )->getAttribute ( 'block' );
					$gapQuestionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]/xmlns:div[@id="' . $gapQuestionID . '"]';
					$gapQuestionText = $xPath->query ( $gapQuestionQuery )->item ( 0 );
					$xmlGapQuestionNode = $tempDoc->importNode ( $gapQuestionText, true );
					$tempDoc->appendChild($xmlGapQuestionNode);
				}
			}
		}
		
		// remove <questionBank/> in <questions/>
		$questionBackLength = $questionBanks->length;
		for ($i = 0; $i < $questionBackLength; $i++) {
			$xmlQuestions->removeChild($questionBanks->item(0));
		}
		
		$numbers = range(0, (2*$totalNumber-1));
		shuffle($numbers);
		$j = 1;
		// insert question number node to each node in tempDoc and copy each node to xmlDoc
		// TODO gh#660 Replace this with question number variable, #q#, in the question bank
		foreach ($numbers as $number) {
			$tempQuestionNode = $tempQuestions->childNodes->item($number);
			$xmlQuestionNode = $xmlDoc->importNode($tempQuestionNode, true);
			$xmlQuestions->appendChild($xmlQuestionNode);
			
			$questionNumberDoc = new DOMDocument();
			$questionNumberDoc->loadXML('<div class="question-number">'.($j).'</div>');
			$gapQuestionNumberNode = $questionNumberDoc->getElementsByTagName("div")->item(0);
			$gapQuestionNumberNode = $tempDoc->importNode($gapQuestionNumberNode, true);
			$tempNode = $tempDoc->childNodes->item($number);
			$tempNode->insertBefore($gapQuestionNumberNode, $tempNode->firstChild);
			$xmlNode = $xmlDoc->importNode ($tempNode, true );
    		$xmlBody->appendChild($xmlNode);
    		$j++;
		}
		AbstractService::$debugLog->info("xml doc: ".$xmlDoc->saveXML());
		return $xmlDoc->saveXML();						
	}
}