<?php
/*
 * http://www.phpbuilder.com/articles/application-architecture/security/using-a-json-web-token-in-php.html
 */
class AuthenticationCops {
	
	function AuthenticationCops($db) {
        $this->db = $db;
        $this->copyOps = new CopyOps();
	}

    const KEY = 'clarity-couloir-authentication-key';

	/**
	 * Check that the token is valid
	 */
	public function createToken($payload = []) {
        $token = array(
            "iss" => "http://dock.projectbench",
            "iat" => time());
        $token = array_merge($token, $payload);
        return Firebase\JWT\JWT::encode($token, $this::KEY, 'HS256');
    }

    public function getPayloadFromToken($token) {
	    try {
            $payload = Firebase\JWT\JWT::decode($token, $this::KEY, array('HS256'));
        } catch (Exception $e) {
            throw $this->copyOps->getExceptionForId("errorTokenInvalid");
        }
        return $payload;
    }

    // Specialised function to pull out a session id from the token, if it exists
    public function getSessionId($token) {
	    $payload = $this->getPayloadFromToken($token);
        return (isset($payload->sessionId)) ? $payload->sessionId : false;
    }

    // Many functions want the full session based on the session id in the token
    public function getSession($token) {
        $payload = $this->getPayloadFromToken($token);
        $sessionId = (isset($payload->sessionId)) ? $payload->sessionId : false;
        if (!$sessionId)
            throw $this->copyOps->getExceptionForId("errorLostSession");

        $sql = <<<EOD
            SELECT * FROM T_SessionTrack
        	WHERE F_SessionID=?
EOD;
        $bindingParams = array($sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            $session = new SessionTrack($rs->FetchNextObj());
        } else {
            throw $this->copyOps->getExceptionForId("errorLostSession");
        }

        return $session;
    }
}