<?php
try {
  $client = new SoapClient('http://mage1.mjrafferty.org/api/soap/?wsdl', array('trace' => 1, 'connection_timeout' => 120));

  $session = $client->login('mjraffer', 'MaximsPerilLoosedAscend2549');

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  $result = $client->call($session, 'product.list');

  var_dump($result);

}
catch (Exception $e) {
  var_dump($e);
}
$client->endSession($session);
?>
