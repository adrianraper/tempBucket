<?php
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    //$json = json_decode('{"command":"login","email":"dandy@email","password":"password","productCode":63}');

    echo json_encode(router($json));
} catch (Exception $e) {
    header(':', false, 500);
    echo json_encode(array("error" => $e->getMessage()));
}

// Router
function router($json) {
    switch ($json->command) {
        case "login": return login();
        case "scoreWrite": return scoreWrite();
        default: throw new Exception("Unknown command");
    }
}

function login() {
	return [
		"user" => [
        		"email" => "test@test.com",
        		"fullName" => "Test Account",
        		"studentID" => "123456"
		],
		"sessionID" => "123456789",
		"tests" => [
			[
				"id" => "ilatest-run-12345",
				"contentName" => "ila",
				"description" => "The ILA test content run 12345.",
                "startTimestamp" => "2016-08-20 09:00:00",
                "endTimestamp" => null
			]
		]
	];	
}

function scoreWrite() {
	return [
		"sessionID" => (string)time()
	];
}
