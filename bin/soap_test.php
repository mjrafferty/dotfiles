<?php
	try {
	$client = new SoapClient('https://mage1.mjrafferty.org/api/soap?wsdl=1', array('trace' => 1, 'connection_timeout' => 120));

	$session = $client->login(array(
					'username' => 'mjraffer',
					'apiKey' => 'MaximsPerilLoosedAscend2549')
	);

	}
	catch (Exception $e) {
			var_dump($e);
	}
	echo $client->__getLastResponse();
	echo $client->__getLastRequest();
	$result = $client->call($session, 'product.list');
	var_dump($result);
?>
