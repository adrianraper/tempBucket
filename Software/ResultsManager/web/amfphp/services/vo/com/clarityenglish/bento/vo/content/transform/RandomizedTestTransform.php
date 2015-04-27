<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class RandomizedTestTransform extends XmlTransform {
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.RandomizedTestTransform';
	
	public function transform($db, $xml, $href, $service) {
		
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		$xmlDoc = new DOMDocument();
		$xmlDoc->formatOutput = true;
		$xmlDoc->load($href->getUrl());
		$xmlQuestions = $xmlDoc->getElementsByTagName("questions")->item(0);
		$questionBanks = $xmlDoc->getElementsByTagName("questionBank");
		$xmlPath = new DOMXPath($xmlDoc);
		$xmlPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$bodyQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]';
		$xmlBody = $xmlPath->query($bodyQuery)->item(0);
		
		$tempQuestions = new DOMDocument();
		$tempQuestions->formatOutput = true;
		$tempDoc = new DOMDocument();
		$tempDoc->formatOutput = true;
		$totalNumber = 0;

		foreach ($questionBanks as $questionBank) {
			$bankHref = new Href();
			$bankHref->currentDir = $href->currentDir;
			$bankHref->filename = $questionBank->getAttribute('href');
			
			// gh#1030 Number of questions required from this bank (default to 5)
			$numQuestionsToUse = $questionBank->getAttribute('use');
			if (!$numQuestionsToUse || $numQuestionsToUse < 1)
				$numQuestionsToUse = 5;
			$totalNumber += $numQuestionsToUse;

			$bankDoc = new DOMDocument();
			$bankDoc->load($bankHref->getUrl());
			
			$xPath = new DOMXPath($bankDoc);
			$xPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

			$query = '/xmlns:bento/xmlns:head/xmlns:meta[@name="conversion-from"]';
			$questionType = $xPath->query($query)->item(0)->getAttribute('content');
			
			switch ($questionType) {
				case "multiplechoice":
					$tagName = "MultipleChoiceQuestion";
					break;
				case "gapfill":
					$tagName = "GapFillQuestion";
					break;
				default:
					continue;
			}
			$questions = $bankDoc->getElementsByTagName($tagName);
			$maxQuestions = $questions->length;
			if ($maxQuestions < 1)
				continue;
			$numQuestionsToUse = ($maxQuestions < $numQuestionsToUse) ? $maxQuestions : $numQuestionsToUse;
				
			// gh#1030 Pick x questions at random from the bank
			$randArray = array_rand(range(0, $maxQuestions-1), $numQuestionsToUse);
			
			for ($i = 0; $i < $numQuestionsToUse; $i++) {
				// copy question and answer model from questionBank xml to template
				$questionModel = $questions->item($randArray[$i]);
				$xmlModelNode = $tempQuestions->importNode($questionModel, true);
				$tempQuestions->appendChild($xmlModelNode);
				$questionID = $questionModel->getAttribute('block');
				$questionQuery = '/xmlns:bento/xmlns:body/xmlns:section[@id="body"]/xmlns:div[@id="' . $questionID . '"]';
				$questionText = $xPath->query($questionQuery)->item(0);
				$xmlQuestionNode = $tempDoc->importNode($questionText, true);
				$tempDoc->appendChild($xmlQuestionNode);
			}
		}
		
		// remove <questionBank/> in <questions/>
		$questionBankLength = $questionBanks->length;
		for ($i = 0; $i < $questionBankLength; $i++) {
			$xmlQuestions->removeChild($questionBanks->item(0));
		}
		
		$numbers = range(0, $totalNumber-1);
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
		
		return $xmlDoc->saveXML();						
	}
}