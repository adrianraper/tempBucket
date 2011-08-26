<?PHP
include_once("XMLQuery.php");
$Query	= new XMLQuery();
$vars		= $Query->vars;

include_once("dbPath.php");
$Db 		= new DB($vars);

include_once("dbLicence.php");
$Licence	= new LICENCE();

include_once("queryLicence.php");

// Depends if you have one or two databases - it is usual to have just one
//$Db->open("connection");
$Db->open("xxxx");

$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

switch ( strtoupper( $vars['METHOD'] ) ) {
    case 'GETLICENCESLOT':
	$rC = getLicenceSlot($vars, $node);
        break;

    case 'DROPLICENCE':
        $rC = dropLicence($vars, $node);
        break;

    case 'HOLDLICENCE':
        $rC = updateLicence($vars, $node);
        break;

    case 'FAILLICENCESLOT':
        $rC = failLicenceSlot($vars, $node);
        break;

    default:
        $node .= "<err code='101'>No method sent</err>";
        break;
}

$node .= "</db>";
print($node);

$Db->disconnect();
?>