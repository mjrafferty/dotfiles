<?php
try {
  error_reporting(E_ALL | E_STRICT);
  ini_set('display_errors', 1);
  $proxy = new SoapClient('https://mage1.mjrafferty.org/api/v2_soap?wsdl=1', array('trace' => 1, 'connection_timeout' => 120));

  $session = $proxy->login(array(
    'username' => "mjraffer",
    'apiKey' => "MaximsPerilLoosedAscend2549"
  ));
  $sessionId = $session->result;

  $filters = array(
    'sku' => array('like'=>'zol%')
  );

  $products = $proxy->catalogProductList(array("sessionId" => $sessionId, "filters" => $filters));

  echo '<h1>Result</h1>';
  echo '<pre>';
  var_dump($products);
  echo '</pre>';

} catch (Exception $e) {
  echo '<h1>Error</h1>';
  echo '<p>' . $e->getMessage() . '</p>';
}
?>
