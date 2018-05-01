<?php
try {

  ; v1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  $client = new SoapClient('http://'.$argv[1].'/api/soap/?wsdl', array('trace' => 1, 'connection_timeout' => 120));
  $session = $client->login($argv[2], $argv[3]);

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  $result = $client->call($session, 'product.list');

  ; v2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  $client = new SoapClient('http://'.$argv[1].'/api/v2_soap?wsdl=1', array('trace' => 1, 'connection_timeout' => 120));
  $session = $client->login($argv[2], $argv[3]);

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  $result = $client->catalogProductList($session);

  ; v2 wsi ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  $client = new SoapClient('http://'.$argv[1].'/api/v2_soap/?wsdl', array('trace' => 1, 'connection_timeout' => 120));
  $session = $client->login((object)array('username' => $argv[2], 'apiKey' => $argv[3]));

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  $result = $client->catalogProductList((object)array('session' => $session->result, 'filters' => null));
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  var_dump($result->result);

}
catch (Exception $e) {

  var_dump($e);

}

$client->endSession($session);

?>
