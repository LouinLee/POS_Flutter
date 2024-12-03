<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

include 'morder_detail.php';

$orderDetailModel = new MOrderDetail();

$request_method = $_SERVER["REQUEST_METHOD"];

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit();
}

switch ($request_method) {
    case 'GET':
        if (isset($_GET['order_id'])) {
            // Fetch order details by order_id
            $order_id = $_GET['order_id'];
            echo json_encode($orderDetailModel->getOrderDetailsByOrderId($order_id));
        } else {
            // Fetch all order details
            echo json_encode($orderDetailModel->getAllOrderDetails());
        }
        break;    

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        echo json_encode($orderDetailModel->createOrderDetail($data));
        break;

    case 'PUT':
        $order_detail_id = $_GET['order_detail_id'];
        $data = json_decode(file_get_contents("php://input"), true);
        echo json_encode($orderDetailModel->updateOrderDetail($order_detail_id, $data));
        break;

    case 'DELETE':
        $order_detail_id = $_GET['order_detail_id'];
        echo json_encode($orderDetailModel->deleteOrderDetail($order_detail_id));
        break;

    default:
        header("HTTP/1.1 405 Method Not Allowed");
        echo json_encode(["success" => false, "message" => "Method Not Allowed"]);
        break;
}
?>
