<?php
/*
 * http://www.phpbuilder.com/articles/application-architecture/security/using-a-json-web-token-in-php.html
 */
use Firebase\JWT\JWT;

class AuthenticationCops {


	function AuthenticationCops($db) {
        $this->db = $db;
        $this->copyOps = new CopyOps();
	}

    const KEY = 'clarity-couloir-authentication-key';

	/**
	 * Create a token
	 */
	public function createToken($payload, $key = null) {
	    // If payload is a json object, convert it to an array
        if (!is_array($payload)) {
            $payload = json_decode(json_encode($payload), true);
        }
        $token = array(
            "iss" => "clarityenglish.com",
            "iat" => time());
        $key = ($key) ? $key : $this::KEY;
        $token = array_merge($token, $payload);
        return JWT::encode($token, $key, 'HS256');
    }

    public function getPayloadFromToken($token, $key = null) {
        $key = ($key) ? $key : $this::KEY;
	    try {
            $payload = JWT::decode($token, $key, array('HS256'));
        } catch (Exception $e) {
            throw $this->copyOps->getExceptionForId("errorTokenInvalid");
        }
        return $payload;
    }
    public function validateApiToken($token, $key) {
        try {
            $payload = JWT::decode($token, $key, array('HS256'));
        } catch (Exception $e) {
            throw $this->copyOps->getExceptionForId("errorApiTokenInvalid");
        }
        return true;
    }

    // m#316 Extract payload from an API token, no validation of the token
    public function getApiPayload($token) {
        $tks = explode('.', $token);
        list($headb64, $bodyb64, $cryptob64) = $tks;
        return JWT::jsonDecode(JWT::urlsafeB64Decode($bodyb64));
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
    // m#316 Lookup the api key for a prefix
    public function getAccountApiKey($id) {
	    switch (strtolower($id)) {
            case 'nms':
                $key = 'NMS-65483-81654915';
                break;
            case 'slsa':
                $key = 'SLSA-55904-84357611';
                break;
            case 'clarity':
            case 'dev':
                $key = 'averysecretkey';
                break;
            default:
                $key = $this::KEY;
                break;
        }
        return $key;
    }

    public function getDbVersion() {
        $sql = <<<EOD
            SELECT max(F_VersionNumber) as version FROM T_DatabaseVersion
EOD;
        $bindingParams = array();
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            return $rs->FetchNextObj()->version;
        } else {
            throw $this->copyOps->getExceptionForId("databaseError");
        }
    }
}