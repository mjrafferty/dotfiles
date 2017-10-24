<?php
try {
  $client = new SoapClient('http://mage1.mjrafferty.org/api/v2_soap?wsdl=1', array('trace' => 1, 'connection_timeout' => 120));

  $session = $client->login('mjraffer', 'MaximsPerilLoosedAscend2549');

  echo $client->__getLastRequest();
  echo $client->__getLastResponse();

  //$result = $client->call($session, 'product.list',"");
  //$result = $client->catalogProductList($session, "");
  $result = $client->catalogProductUpdate($session, '905', array(
    'stock_data' => array(
      'qty' => '20',
      'is_in_stock' => '1',
      'manage_stock' => '1',
      'notify_stock_qty' => '5'
    )));

  var_dump($result);

}
catch (Exception $e) {
  var_dump($e);
}
$client->endSession($session);
?>
