<?php
/**
 * $Header$
 *
 * @version $Revision: 224513 $
 * @package Log
 */

/**
 * The Log_graylog class is a concrete implementation of the Log abstract
 * class that logs messages to a graylog server.
 * 
 */
class Log_graylog extends Log
{
    /**
     * String containing the name of the log file.
     * @var string
     * @access private
     */
    var $_server = 'http://127.0.0.1:12001';

    /**
     * Constructs a new Log_graylog object.
     *
     * @param string $name     Ignored.
     * @param string $ident    The identity string.
     * @param array  $conf     The configuration array.
     * @param int    $level    Log messages up to and including this level.
     * @access public
     */
    function Log_graylog($server, $ident = '', $conf = array(),
                      $level = PEAR_LOG_DEBUG)
    {
        $this->_id = md5(microtime());
        $this->_server = $server;
        $this->_ident = $ident;
        $this->_mask = Log::UPTO($level);

        register_shutdown_function(array(&$this, '_Log_graylog'));
    }

	// gh#857. Let you change the graylog server
	function setTarget($server) {
		$this->_server = $server;
	}
    function getTarget() {
        return $this->_server;
    }

    /**
     * Destructor
     */
    function _Log_graylog() {
    }

    /**
     * Logs $message to the output window.  The message is also passed along
     * to any Log_observer instances that are observing this Log.
     *
     * @param mixed  $message  String or object containing the message to log.
     * @param string $priority The priority of the message.  Valid
     *                  values are: PEAR_LOG_EMERG, PEAR_LOG_ALERT,
     *                  PEAR_LOG_CRIT, PEAR_LOG_ERR, PEAR_LOG_WARNING,
     *                  PEAR_LOG_NOTICE, PEAR_LOG_INFO, and PEAR_LOG_DEBUG.
     * @return boolean  True on success or false on failure.
     * @access public
     */
    function log($message, $priority = null) {
        /* If a priority hasn't been specified, use the default value. */
        if ($priority === null) {
            $priority = $this->_priority;
        }

        /* Abort early if the priority is above the maximum logging level. */
        if (!$this->_isMasked($priority)) {
            return false;
        }

        /* Extract the string representation of the message. */
        $msgText = $this->_extractMessage($message);
        $gelfString = array("version"=>"1.1","host"=>"backend","short_message"=>$msgText,"level"=>$priority);

        /* Extract the data from the message that will go as parameters to gelf */
        $msgData = $this->_extractData($message);
        if ($msgData) {
            foreach ($msgData as $k => $j)
                $gelfString['_' . $k] = $j;
        }

        $serializedObj = json_encode($gelfString);

        // Initialize the cURL session
        $ch = curl_init();
        // If you try to set the timeout it will timeout, but the gelf does not end up in graylog.
        $curlOptions = array(CURLOPT_HEADER => false,
            CURLOPT_FAILONERROR => false,
            CURLOPT_FOLLOWLOCATION => false,
            CURLOPT_RETURNTRANSFER => false,
            CURLOPT_CONNECTTIMEOUT_MS => 0,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $serializedObj,
            CURLOPT_URL => $this->getTarget()
        );
        curl_setopt_array($ch, $curlOptions);

        // Execute the cURL session, no need to wait for response, just fire and forget
        $success = curl_exec ($ch);
        curl_close($ch);

        /* Notify observers about this log message. */
        $this->_announce(array('priority' => $priority, 'message' => $message));

        return $success;
    }

}
