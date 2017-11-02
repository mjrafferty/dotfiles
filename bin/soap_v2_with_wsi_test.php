<?php
try {
  $client = new SoapClient('http://'.$argv[1].'/api/v2_soap/?wsdl', array('trace' => 1, 'connection_timeout' => 120));

  $sessionId = $client->login((object)array('username' => $argv[2], 'apiKey' => $argv[3]));

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  $result = $client->catalogProductList((object)array('sessionId' => $sessionId->result, 'filters' => null));

	var_dump($result->result);
  $client->endSession($sessionId);

}
catch (Exception $e) {
	var_dump($e);
}
?>
