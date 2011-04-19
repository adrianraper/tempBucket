<?php
class DB {
    function DB() {
	// settings for running MySQL: host = server name, user = user name, pass = password, base = database prefix
	$this->host = "dock"; $this->user = "root"; $this->pass = "clarity"; $this->base  = "003";

	$this->link = @mysql_connect($this->host, $this->user, $this->pass);
    }

    function open($base) {
        // Save database name
        $this->base .= $base;
        // And select it
        @mysql_select_db($this->base, $this->link) or die(mysql_error());
    }

    function disconnect() {
        // Just do nothing
    }

    function dbPrepare($str) {
        return mysql_escape_string($str);
    }

    function query($query) {
        if(!$result = mysql_query($query, $this->link))
            die("MySQL says: <b>" . mysql_error() . "</b>.<br>
                 For the query: <b>" . $query . "</b>");
        else {
            $this->num_rows        = @mysql_num_rows($result);
            $this->affected_rows   = @mysql_affected_rows($this->link);
            //$this->last_insert_id  = @mysql_insert_id($this->link);
            $this->num_fields      = @mysql_num_fields($result);

            unset($this->result);
            for($i = 0; $i < $this->num_rows; $i++)
                $this->result[]        = @mysql_fetch_array($result, MYSQL_ASSOC);
        }
    }

    function getError() {
        return mysql_error();
    }
}

?>