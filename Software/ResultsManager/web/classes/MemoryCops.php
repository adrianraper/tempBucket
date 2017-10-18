<?php
class MemoryCops {

	/**
	 * This class manages the user's memory. This is used for storing product specific information
	 * that needs to be retained between sessions.
	 * 
	 * Memories are stored by userId and productCode, then key. The value is any string.
     * If the string contains a JSON it is not decoded or validated.
	 */
	
	var $db;
	private $productCode;
	private $userId;
	
	function __construct($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	public function changeDB($db) {
		$this->db = $db;
	}

	// Not used in Couloir
	public function setProductCode($productCode) {
	    $this->productCode = $productCode;
    }
    public function setUserId($userId) {
	    $this->userId = $userId;
    }
    /**
     * Gets the memory for the given key. If the key is not found this will return null.
     */
    public function get($key, $userId = null, $productCode = null) {
    	if (!$userId)
    		$userId = $this->userId;
    	if (!$productCode)
    		$productCode = $this->productCode;
    		
        $value = $this->db->GetOne("SELECT F_Value FROM T_Memory WHERE F_UserID=? AND F_ProductCode=? AND F_Key=?",
            array($userId, $productCode, $key));

        return $value;
    }

    /**
     * Sets the memory for the given key.  If the key does not exist a new one will be created.
     * You can pass userId and productCode if you want memory for a user or product that is not the default.
     * TODO If you pass a $value of null, then treat that as a sign to delete the key if it exists.
     *
     * @param $key
     * @param $value
     * @param optional productCode, userId
     * @return bool The function will return false if the database query fails for some reason
     */
    public function set($key, $value, $userId = null, $productCode = null) {
    	if (!$userId)
    		$userId = $this->userId;
    	if (!$productCode)
    		$productCode = $this->productCode;

    	if (is_null($value)) {
    		$bindingParams = array($userId, $productCode, $key);
    		$success = $this->db->Execute("DELETE FROM T_Memory WHERE F_UserID=? AND F_ProductCode=? AND F_Key=?", $bindingParams);
    		$rc = !($success == false);
    		
    	} else {
	        $success = $this->db->Replace("T_Memory",
            array("F_UserID" => $userId, "F_ProductCode" => $productCode, "F_Key" => $key, "F_Value" => $value),
            array("F_UserID", "F_ProductCode", "F_Key"), true);
            $rc = ($success > 0);
    	}

        return $rc;
    }
    
    /**
     * Get all matching keys from a user's memory, no matter what product.
     * return: recordset
     */
    public function getAllKeys($key, $userId = null) {
    	if (!$userId)
    		$userId = $this->userId;

		$sql = <<<EOD
			SELECT *
			FROM T_Memory m
			WHERE m.F_UserID = ?
			AND m.F_Key = ?
EOD;
		$bindingParams = array($userId, $key);
		return $this->db->Execute($sql, $bindingParams);
		
    }
    
    /**
     * Get all of a user's memory for this product
     * 
     */
    public function getWholeMemory($userId = null, $productCode = null) {
    	if (!$userId)
    		$userId = $this->userId;
    	if (!$productCode)
    		$productCode = $this->productCode;
    		
		$sql = <<<EOD
			SELECT F_Key as k, F_Value as v
			FROM T_Memory m
			WHERE m.F_UserID = ?
			AND m.F_ProductCode = ?
EOD;
		$bindingParams = array($userId, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		$memory = array();
		if ($rs) {
			while ($dbObj = $rs->FetchNextObj()) {
				$memory[$dbObj->k] = $dbObj->v;
			}
		}
		return $memory;
    }
    
    /**
     * Delete the user's memory, to a greater or lesser degree.
     * 
     */
    public function forget($userId = null, $productCode = null, $key = null) {
    	if (!$userId)
    		$userId = $this->userId;
    	
    	$sql = "DELETE FROM T_Memory WHERE F_UserID=?";
		$bindingParams = array($userId);
    	if ($productCode) {
    		$sql .= " AND F_ProductCode=?";
    		$bindingParams[] = $productCode;
   		}
    	if ($key) {
    		$sql .= " AND F_Key=?";
    		$bindingParams[] = $key;
   		}
		return $this->db->Execute($sql, $bindingParams);
    }
    /**
     * Forget everything you know
     */
    public function amnesia($userId = null) {
    	return $this->forget($userId);
    }
    
}