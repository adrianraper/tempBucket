<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class HiddenContentTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.HiddenContentTransform';
	
	public function transform($db, $xml, $href, $service) {
		$menu = $xml->head->script->menu;
		
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		$user = $service->manageableOps->getUserById(Session::get('userID'));
		
		// #339 Hidden content
		// #issue25 only for students
		if ($user->userID >= 1 && $user->userType == User::USER_TYPE_STUDENT) {
			// gh#653 Might get multiple groups
			$groupID = $service->manageableOps->getGroupIdForUserId($user->userID);
			$rs = $service->progressOps->getHiddenContent($groupID, Session::get('productCode'));
			
			// If you found some hidden content records for this group, merge the enabledFlag into the menu.xml
			if (count($rs) > 0) {
				// $rs is likely to contain less records than the XML, so loop through rs setting the specific enabledFlags in the xml.
				foreach ($rs as $record) {
					// Each record has a UID and an enabledFlag. Match the UID to the menu and merge the eF.
					$fullUID = $record['UID'];
					$eF = $record['eF'];
					
					// The hidden content records use eF=0 to show that something is displayed
					// But we need this to be -8 so that we can specifically switch disabled off, without impacting other bitwise flags
					if ($eF == 0) $eF = Content::CONTENT_ENABLED;
					
					$uidArray = explode('.', $fullUID);
					
					// Since every id in the menu.xml should be unique you ought to be able to find each node like this.
					// $node = $menu->xpath('.//[@id="'.$uid.'"]');
					// Otherwise you need a switch that looks at the level of the UID and searches for menu/course/unit/exercise as relevant.
					$uid = end($uidArray);
					switch (count($uidArray)) {
						case 1:
							// gh#171
							//$node = array($xml);
							$node = $xml->xpath('.//xmlns:menu[@id="'.$uid.'"]');
							break;
						case 2:
							$node = $xml->xpath('.//xmlns:course[@id="'.$uid.'"]');
							break;
						case 3:
							$node = $xml->xpath('.//xmlns:unit[@id="'.$uid.'"]');
							break;
						case 4:
							$node = $xml->xpath('.//xmlns:exercise[@id="'.$uid.'"]');
							break;
					}
					// If the UID doesn't match our menu.xml, just ignore it
					// Otherwise set it and all its children to this eF
					if ($node)
						$this->propagateEnabledFlag($node[0], $eF);
				}
				
				// Then go through the structure of the xml to see if all children in a node are hidden, in which case the node is too
				$this->setAttribute($menu, 'enabledFlag', $this->getCompositeEnabledFlag($menu));
				
				// There is a special case where the whole title has been hidden and nothing else set.
				// Schools do this to protect limited licences. If this is the case, get out now and stop the login
				if (((string)$menu->attributes()->enabledFlag & Content::CONTENT_DISABLED) == Content::CONTENT_DISABLED) 
					throw $service->copyOps->getExceptionForId("errorTitleBlockedByHiddenContent", array("groupID" => $groupID));
			}
		}
	}
	
	/**
	 * Helper function to make sure that you can set a bitwise attribute value.
	 * Use a negative value to switch off that bit.
	 */
	private function setAttribute($node, $attributeName, $attributeValue) {
		if (isset($node[$attributeName])) {
			// If the attribute value is negative it means we want a bitwise switch OFF of that number
			if ($attributeValue < 0) {
				$node[$attributeName] &= ~abs(intval($attributeValue));
			} else {
				$node[$attributeName] |= intval($attributeValue);
			}
		} else {
			// #351 If there was no attribute already, ignore negative values
			if ($attributeValue >= 0)
				$node->addAttribute($attributeName, intval($attributeValue));
		}
	}
	
	/**
	 * recursive function to set all child nodes to this enabledFlag
	 */
	private function propagateEnabledFlag($node, $eF) {
		$this->setAttribute($node, 'enabledFlag', $eF);
		
		// Go down from this node
		foreach ($node->children() as $item) {
			// Only interested in course, unit and exercise nodes
			switch ($item->getName()) {
				case 'course':
				case 'unit': 
					$this->setAttribute($item, 'enabledFlag', $eF);
					$this->propagateEnabledFlag($item, $eF);
					break;
				// Exercises are the end of the recursion
				case 'exercise': 
					$this->setAttribute($item, 'enabledFlag', $eF);
					break;
				default:
			}	
		}
	}
		
	/**
	 * recursive function to see if all a nodes children have the same enabledFlag
	 * @param XML $node
	 */
	private function getCompositeEnabledFlag($node) {
		$allItemsHidden = true;
		foreach ($node->children() as $item) {
			// Only interested in course, unit and exercise nodes
			switch ($item->getName()) {
				// For a course, you need to go into every unit
				case 'course':
					$this->setAttribute($item, 'enabledFlag', $this->getCompositeEnabledFlag($item));
					if (((string)$item->attributes()->enabledFlag & Content::CONTENT_DISABLED) == 0)
						$allItemsHidden = false;
					break;
					
				// For units you only need to find one non-disabled exercise to have all you need
				case 'unit': 
					$this->setAttribute($item, 'enabledFlag', $this->getCompositeEnabledFlag($item));
					if (((string)$item['enabledFlag'] & Content::CONTENT_DISABLED) == 0) {
						return Content::CONTENT_ENABLED;
					}
					break;
					
				// Exercises are the end of the recursion, are any of them NOT disabled?
				case 'exercise': 
					if (isset($item['enabledFlag'])) {
						if (((string)$item['enabledFlag'] & Content::CONTENT_DISABLED) == 0)
							return Content::CONTENT_ENABLED;	
					} else {
						return Content::CONTENT_ENABLED;
					}
					break;
				default:
			}	
		}
		
		if ($allItemsHidden) {
			return Content::CONTENT_DISABLED;
		} else {
			return Content::CONTENT_ENABLED;
		}
	}
	
}