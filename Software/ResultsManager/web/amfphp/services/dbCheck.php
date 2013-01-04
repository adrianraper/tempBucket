<?php
/*
 * To see if you can connect to the database.
 */
require_once(dirname(__FILE__)."/MinimalService.php");
$thisService = new MinimalService();

// Done in config.php
date_default_timezone_set('UTC');

header('Content-Type: text/plain; charset=utf-8');

/*
 * Action for the script
 */
// Load the passed data
$sql = 	<<<EOD
	SELECT *
	FROM T_DatabaseVersion
	ORDER BY F_VersionNumber DESC;
EOD;
try {
	$rs = $thisService->db->Execute($sql);
	if ($rs) {
		while ($dbObj = $rs->FetchNextObj()) {
			echo "version=".$dbObj->F_VersionNumber.' date='.$dbObj->F_ReleaseDate."\n";
		}	
	} else {
		echo "Select failed";
	}
} catch (Exception $e) {
	echo $e->getMessage();
/*
	$sql = 	<<<EOD
		CREATE TABLE [T_DatabaseVersion](
			[F_VersionNumber] [int] NOT NULL,
			[F_ReleaseDate] [datetime] NOT NULL,
			[F_Comments] [nvarchar] NULL
		);
EOD;
	$rs = $conn->Execute($sql);
	$sql = 	<<<EOD
		INSERT INTO [T_DatabaseVersion] VALUES (1,'2007-01-01 00:00:00','original');
EOD;
*/
}	
		
flush();
exit(0);
