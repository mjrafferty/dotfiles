<?php
try {
  $client = new SoapClient('http://'.$argv[1].'/api/v2_soap?wsdl=1', array('trace' => 1, 'connection_timeout' => 120));

  $session = $client->login($argv[2], $argv[3]);

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  $result = $client->catalogProductList($session);

  var_dump($result);

}
catch (Exception $e) {
  var_dump($e);
}
$client->endSession($session);
?>
