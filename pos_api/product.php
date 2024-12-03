<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Include the MProduct model for CRUD operations
include 'mproduct.php';

// Create an instance of the MProduct class
$productModel = new MProduct();

// Get the request method
$request_method = $_SERVER["REQUEST_METHOD"];

// Handling OPTIONS request from front-end
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit();
}

// Routing based on HTTP request method
switch ($request_method) {
    case 'GET':
        // Handle GET request for fetching products
        if (isset($_GET['product_id'])) {
            // Fetch a specific product by product_id
            $product_id = $_GET['product_id'];
            echo json_encode($productModel->getProductById($product_id));
        } else {
            // Fetch all products
            echo json_encode($productModel->getProducts());
        }
        break;

    case 'POST':
        // Handle POST request for creating a new product
        $data = json_decode(file_get_contents("php://input"), true);
        echo json_encode($productModel->createProduct($data));
        break;

    case 'PUT':
        // Handle PUT request for updating an existing product
        if (isset($_GET['product_id'])) {
            $product_id = $_GET['product_id'];
            $data = json_decode(file_get_contents("php://input"), true);
            echo json_encode($productModel->updateProduct($product_id, $data));
        } else {
            echo json_encode(["success" => false, "message" => "Product ID is required for update"]);
        }
        break;

    case 'DELETE':
        // Handle DELETE request for deleting a product
        if (isset($_GET['product_id'])) {
            $product_id = $_GET['product_id'];
            echo json_encode($productModel->deleteProduct($product_id));
        } else {
            echo json_encode(["success" => false, "message" => "Product ID is required for deletion"]);
        }
        break;

    default:
        // Method Not Allowed
        header("HTTP/1.1 405 Method Not Allowed");
        echo json_encode(["success" => false, "message" => "Method Not Allowed"]);
        break;
}
