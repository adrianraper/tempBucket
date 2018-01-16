<?php
    $json = json_decode(file_get_contents('php://input'));
    $protocol = (stristr(strtolower($_SERVER['SERVER_PROTOCOL']),'https')) ? 'https://' : 'http://';
    $host = $_SERVER['SERVER_NAME'];
    $port = $_SERVER['SERVER_PORT'];
    $gateway = 'ExternalLoginGateway.php';
    $folder = '/Software/ResultsManager/web/amfphp/services/';
    $newURL = $protocol.$host.':'.$port.$folder.$gateway;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_POST, TRUE);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($json));
    curl_setopt($ch, CURLOPT_URL, $newURL);
    curl_setopt($ch, CURLOPT_HEADER, true);
    $headers = getallheaders();
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    if (isset($headers['Cookie'])) {
        curl_setopt($ch, CURLOPT_COOKIE, $headers['Cookie']);
    }
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    $response = curl_exec($ch);
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $headers = substr($response, 0, $header_size);
    $body = substr($response, $header_size);

    $headerArray = explode(PHP_EOL, $headers);

    /* Process response headers. */
    foreach($headerArray as $header){
        $colonPos = strpos($header, ':');
        if ($colonPos !== FALSE) {
            $headerName = substr($header, 0, $colonPos);

            /* Ignore content headers, let the webserver decide how to deal with the content. */
            if (trim($headerName) == 'Content-Encoding') continue;
            if (trim($headerName) == 'Content-Length') continue;
            if (trim($headerName) == 'Transfer-Encoding') continue;
            if (trim($headerName) == 'Location') continue;
        }
        header($header, FALSE);
    }

    echo $body;
    curl_close($ch);
    exit;
    