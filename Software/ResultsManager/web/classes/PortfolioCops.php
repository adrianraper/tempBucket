<?php
class PortfolioCops {

	/**
	 * This class manages the user portfolio.
	 */
	
	var $db;

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

    /**
     * sss#364
     * Gets the portfolio items for this user in this course/unit
     * TODO If the uid only covers product or course, then pick up units in that combination
     */
    public function getPortfolio($userId, $uid) {

        $sql = <<<SQL
			SELECT *
			FROM T_Portfolio
			WHERE F_UID LIKE ?
			AND F_UserID=?
			AND F_Dropped IS NULL
            ORDER BY F_UID
SQL;

        $bindingParams = array($uid.'.%', $userId);
        $rs = $this->db->GetArray($sql, $bindingParams);

        return $rs;
    }
    /**
     * sss#364
     * Gets the portfolio items for this user in this course/unit
     * TODO If the uid only covers product or course, then pick up units in that combination
     */
    public function addToPortfolio($userId, $uid, $file, $thumbnail, $caption) {

        $sqlData[] = "(".$userId.", '".$uid."', '".$file."', '".$thumbnail."', '".$caption."', '".date('Y-m-d G:i:s')."')";
        $sql = <<<EOD
			INSERT INTO T_Portfolio (F_UserID,F_UID,F_File,F_Thumbnail,F_Caption,F_Datestamp)
			VALUES 
EOD;
        $sql .= implode(',', $sqlData);

        try {
            $rc = $this->db->Execute($sql);
        } catch (Exception $e) {
            if ($this->db->ErrorNo() == 1062)
                throw $this->copyOps->getExceptionForId("errorDatabaseDuplicateRecord", array("msg" => $this->db->ErrorMsg()));
            throw $e;
        }
        if (!$rc)
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
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
		
		if ($rs && $rs->RecordCount() > 0) {
            $memory = array();
			while ($dbObj = $rs->FetchNextObj()) {
				$memory[$dbObj->k] = $dbObj->v;
			}
		} else {
		   $memory = json_decode ("{}");
        }
		return $memory;
		//
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