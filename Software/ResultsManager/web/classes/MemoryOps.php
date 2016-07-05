<?php
class MemoryOps {

	/**
	 * This class manages the user's memory. This is used for storing product specific information
	 * that needs to be retained between sessions.
	 * 
	 * Memories are stored by userId and productCode, then key. The value is any JSON object.
	 */
	
	var $db;
	private $productCode;
	private $userId;
	
	function __construct($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
		
		$this->productCode = Session::get('productCode');
		$this->userId = Session::get('userID');
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	public function changeDB($db) {
		$this->db = $db;
	}

    /**
     * Gets the memory for the given key as a PHP object. If the key is not found this will return null.  The user and product
     * are inferred from the session.
     * You can pass userId and productCode if you want memory for a user or product that is not the default
     *
     * @param $key
     * @param optional productCode, userId
     * @return array|bool|float|int|mixed|null|stdClass|string
     */
    public function get($key, $productCode = null, $userId = null) {
    	if (!$userId)
    		$userId = $this->userId;
    	if (!$productCode)
    		$productCode = $this->productCode;
    		
        $value = $this->db->GetOne("SELECT F_Value FROM T_Memory WHERE F_UserID=? AND F_ProductCode=? AND F_Key=?",
            array($userId, $productCode, $key));
        // Return arrays rather than objects. Could use serialize if we really want both. 
        // Or use the fact that _explictType will be set for our Bento classes
        // http://stackoverflow.com/questions/2281973/json-encode-json-decode-returns-stdclass-instead-of-array-in-php 
        return json_decode($value, true);
    }

    /**
     * Sets the memory for the given key.  If the key does not exist a new one will be created.  The user and product are
     * inferred from the session.
     * You can pass userId and productCode if you want memory for a user or product that is not the default.
     * TODO If you pass a $value of null, then treat that as a sign to delete the key if it exists.
     *
     * @param $key
     * @param $value
     * @param optional productCode, userId
     * @return bool The function will return false if the database query fails for some reason
     */
    public function set($key, $value, $productCode = null, $userId = null) {
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
            array("F_UserID" => $userId, "F_ProductCode" => $productCode, "F_Key" => $key, "F_Value" => json_encode($value)),
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
    public function getWholeMemory($productCode = null, $userId = null) {
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
		
		//$memory = new Memory();
		$memory = array();
		if ($rs) {
			while ($dbObj = $rs->FetchNextObj()) {
				$memory[$dbObj->k] = json_decode($dbObj->v, true);
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
    
	/**
	 * Get the whole of the user's memory (all products if not specified).
	 * Not used yet.
	 * 
	public function getAll($productCode = null, $userId = null) {
    	if (!$userId)
    		$userId = $this->userId;
    	if (!$productCode)
    		$productCode = $this->productCode;
    		
		$sql = <<<EOD
			SELECT *
			FROM T_Memory m
			WHERE m.F_UserID = ?
EOD;
		$bindingParams = array($userId);
		if ($productCode != 'all') {
			$sql .= ' AND F_ProductCode=?';
			$bindingParams[] = $productCode;
		}
		
		$rs = $this->db->Execute($sql, $bindingParams);
		
		$memory = array();
		if ($rs && ($rs->RecordCount() > 0)) {
			while ($dbObj = $rs->FetchNextObj()) {
				$memory[$dbObj->F_Key] = json_decode($dbObj->F_Value);
			}
		}
		return $memory;
	}
	*/
}