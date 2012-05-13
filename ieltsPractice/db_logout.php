<?php

// Just clear all session records
session_start();
session_unset();
session_destroy();

header("location: index.php");

?>