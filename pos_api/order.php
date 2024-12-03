<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

include 'morder.php';

$orderModel = new MOrder();

$request_method = $_SERVER["REQUEST_METHOD"];

// Handling OPTIONS request from front-end
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit();
}

switch ($request_method) {
    case 'GET':
        if (isset($_GET['order_id'])) {
            $order_id = $_GET['order_id'];
            echo json_encode($orderModel->getOrderById($order_id));
        } else {
            echo json_encode($orderModel->getOrders());
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        echo json_encode($orderModel->createOrder($data));
        break;

    case 'PUT':
        if (isset($_GET['order_id'])) {
            $order_id = $_GET['order_id'];
            $data = json_decode(file_get_contents("php://input"), true);
            echo json_encode($orderModel->updateOrder($order_id, $data));
        }
        break;

    case 'DELETE':
        if (isset($_GET['order_id'])) {
            $order_id = $_GET['order_id'];
            echo json_encode($orderModel->deleteOrder($order_id));
        }
        break;

    default:
        header("HTTP/1.1 405 Method Not Allowed");
        echo json_encode(["success" => false, "message" => "Method Not Allowed"]);
        break;
}
