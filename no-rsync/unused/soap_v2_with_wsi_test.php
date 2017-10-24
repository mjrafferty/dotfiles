<?php
try {
  $client = new SoapClient('http://mage1.mjrafferty.org/api/v2_soap/?wsdl', array('trace' => 1, 'connection_timeout' => 120));

	$sessionId = $client->login((object)array('username' => 'mjraffer', 'apiKey' => 'MaximsPerilLoosedAscend2549'));

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

	$result = $client->catalogProductUpdate((object)array('sessionId' => $sessionId->result, 'productId' => '905',
		'productData' => ((object)array(
			'name' => 'Product name updated',
			'status' => '1',
		))));

	var_dump($result->result);

}
catch (Exception $e) {
	var_dump($e);
}
$client->endSession($session);
?>
