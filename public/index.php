<?php

define('BASE_PATH', dirname(__DIR__));
define('BASE_URL', 'http://localhost/uas_petshop/public/');

require_once BASE_PATH . '/config/database.php';
require_once BASE_PATH . '/config/app.php';
require_once BASE_PATH . '/core/Database.php';
require_once BASE_PATH . '/core/Model.php';
require_once BASE_PATH . '/core/Controller.php';
require_once BASE_PATH . '/core/Router.php';

session_start();

$router = new Router();
$router->dispatch();