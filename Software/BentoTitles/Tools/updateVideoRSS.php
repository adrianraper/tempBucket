<?php

require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Answer.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/ConversionOps.php");

// If you want to see echo stmts, then use plainView
$plainView=false;
$batch=true;
if ($plainView) {
	header ('Content-Type: text/plain');
	$newline = "\n";
} else {
    //header ('Content-Type: text/xml');
	$newline = "<br/>";
}

/**
 * This script will read all the video rss files for a title (in a folder)
 * and tidy them up, this can include
 *  + adding a new channel
 *  + correcting a path
 *
 * Options: you could simply read a folder and edit all files in it, or you could drive from menu.xml.
 * The latter is much more complex (since you have to open each exercise in the title, then find all the rss files)
 * but is much more flexible as a model.
 */
$scriptPurpose = "addNetworkChannelToVideoRSS";
$scriptPurpose = "validateExerciseXML";
$scriptTitle = "CP1";
$scriptTitle = "AR";
$scriptTitle = "R2I";
$scriptTitle = "TB";

switch ($scriptTitle) {
    case "CP1":
        $contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/ClearPronunciation10-International';
        $menu = "menu-Sounds-FullVersion.xml";
        break;
    case "AR":
        $contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/ActiveReading10-NAmerican';
        //$contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/ActiveReading10-International';
        $menu = "menu-FullVersion.xml";
        break;
    case "TB":
        //$contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/TenseBuster10-NAmerican';
        $contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/TenseBuster10-International';
        $menu = "menu-FullVersion.xml";
        break;
    case "R2I":
        $contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/RoadToIELTS2-International';
        //$contentFolder = dirname(__FILE__).'/../../../../ContentBench/Content/RoadToIELTS2-Chinese';
        $menu = "menu-Academic-FullVersion.xml";
        break;
}

// Get the title folder and read menu.xml
if ($batch) {
    $menuFile = $contentFolder.'/'.$menu;
    echo "processing $menuFile $newline";
    $fullXML = simplexml_load_file($menuFile);
    $fullXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
    // this is our usual starting point
    $menuXML = $fullXML->head->script->menu;

    if ($scriptPurpose == 'addNetworkChannelToVideoRSS') {
        if ($scriptTitle == "CP1") {
            // CP1 also has video rss files directly in the menu videoHref
            $courseNodes = $fullXML->xpath("//xmlns:course");
            foreach ($courseNodes as $courseNode) {
                $rssFile = $contentFolder . '/' . $courseNode['videoHref'];
                echo $courseNode['videoHref'] . ": ";
                try {
                    updateRSSFile($rssFile);
                    echo " updated";
                } catch (Exception $e) {
                    echo $e->getMessage();
                }
                echo "$newline";
            }
        }
        if ($scriptTitle == "R2I") {
            // R2I also has video rss files directly in the menu
            $exerciseNodes = $fullXML->xpath("//xmlns:exercise[contains(@href,'.rss')]");
            foreach ($exerciseNodes as $exerciseNode) {
                $rssFile = $contentFolder . '/' . $exerciseNode['href'];
                echo $exerciseNode['href'] . ": ";
                try {
                    updateRSSFile($rssFile);
                    echo " updated";
                } catch (Exception $e) {
                    echo $e->getMessage();
                }
                echo "$newline";
            }
            // And it has a second file, links.xml, with candidates videos in.
            $extraFile = $contentFolder . '/links.xml';
            echo "processing $extraFile $newline";
            $extraXML = simplexml_load_file($extraFile);
            $extraNodes = $extraXML->xpath("//link");
            foreach ($extraNodes as $extraNode) {
                $rssFile = $contentFolder . '/' . $extraNode['href'];
                echo $extraNode['href'] . ": ";
                try {
                    updateRSSFile($rssFile);
                    echo " updated";
                } catch (Exception $e) {
                    echo $e->getMessage();
                }
                echo "$newline";
            }
        }
    }
    /**
     * Next section reads each exercise.xml from the menu and opens the exercise.xml
     *
     */
    $exerciseNodes = $fullXML->xpath("//xmlns:exercise[contains(@href,'.xml')]");
    foreach ($exerciseNodes as $exerciseNode) {
        $exerciseFile = $contentFolder.'/'.$exerciseNode['href'];
        $fullExerciseXML = simplexml_load_file($exerciseFile);
        if (!$fullExerciseXML) {
            echo "Could not load file " . $exerciseNode['href'] . "$newline";
            continue;
        }

        $fullExerciseXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

        switch ($scriptPurpose) {
            case "addNetworkChannelToVideoRSS";
                $videoNodes = $fullExerciseXML->xpath("//xmlns:item[contains(@href,'.rss')]");
                foreach ($videoNodes as $videoNode) {
                    $rssFile = $contentFolder . '/' . $videoNode['href'];
                    echo $videoNode['href'] . ": ";
                    try {
                        updateRSSFile($rssFile);
                        echo " updated";
                    } catch (Exception $e) {
                        echo $e->getMessage();
                    }
                    echo "$newline";
                }
                break;

            case "validateExerciseXML";
                $randomTests = $fullExerciseXML->xpath("//xmlns:questionBank");
                foreach ($randomTests as $randomTest) {
                    $questionBank = $contentFolder . '/' . $randomTest['href'];
                    //echo "checking $questionBank $newline";
                    try {
                        validateXML($questionBank);
                    } catch (Exception $e) {
                        echo "Could not load " . $randomTest['href'] . " from " . $exerciseNode['href'] . "$newline";
                    }
                }
                break;
        }
	}

	// In batch mode you have no interest in viewing an html rendering of the xml
	exit(0);
}

function validateXML($inFile) {
    global $newline;
    $fullXML = simplexml_load_file($inFile);
    if ($fullXML === false)
        throw new Exception("Could not load");
}

function updateRSSFile($inFile) {
    global $newline;
    $fullXML = simplexml_load_file($inFile);
    if ($fullXML === false)
        throw new Exception("Could not load");

    // Current objective - add in a network node with the appropriate streamname
    $networkChannel = $fullXML->xpath("channel[@name='network']");
    if ($networkChannel)
        throw new Exception("Already got a network channel");

    // get the model file name to use in the new network channel
    $existingStream = $fullXML->xpath("channel[@name='rackspace']/item/streamName | channel[@name='aws-streaming']/item/streamName");
    if (!$existingStream)
        throw new Exception("Could not pick up an mp4 name to use as model");
    $mp4Name = array_pop(explode('/',$existingStream[0]));

    // build a new node
    $networkChannel = $fullXML->addChild('channel');
    $networkChannel->addAttribute('name','network');
    $networkChannel->addAttribute('protocol','progressive-download');
    $networkChannel->addChild('host','{streamingMedia}');
    $itemNode = $networkChannel->addChild('item');
    $itemNode->addChild('streamName',$mp4Name);
    $itemNode->addChild('width','411');

    // save the new xml to the file
    $rc = $fullXML->asXML($inFile);
    if (!$rc)
        throw new Exception('could not save the file');
}

// It might help to display the output file in the browser (or the last of many)
//echo $outURL;
// This is fine, except that it means I lose my URL in the bar so replaying it is not so easy
//header('Location: '.$outURL);
echo <<< EOD
<html>
<head>
<script type="text/javascript">
window.open('$outURL');
</script>
</head>
<body />
EOD;
exit();
?>