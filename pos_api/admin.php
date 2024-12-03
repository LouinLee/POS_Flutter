<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Include the MAdmin model for CRUD operations
include 'madmin.php';

// Create an instance of the MAdmin class
$adminModel = new MAdmin();

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
        // Handle GET request for fetching admins
        if (isset($_GET['admin_id'])) {
            // Fetch a specific admin by admin_id
            $admin_id = $_GET['admin_id'];
            echo json_encode($adminModel->getAdminById($admin_id));
        } else {
            // Fetch all admins
            echo json_encode($adminModel->getAdmins());
        }
        break;

    case 'POST':
        // Handle POST request for creating a new admin
        $data = json_decode(file_get_contents("php://input"), true);
        echo json_encode($adminModel->createAdmin($data));
        break;

    case 'PUT':
        // Handle PUT request for updating an existing admin
        if (isset($_GET['admin_id'])) {
            $admin_id = $_GET['admin_id'];
            $data = json_decode(file_get_contents("php://input"), true);
            echo json_encode($adminModel->updateAdmin($admin_id, $data));
        } else {
            echo json_encode(["success" => false, "message" => "Admin ID is required for update"]);
        }
        break;

    case 'DELETE':
        // Handle DELETE request for deleting an admin
        if (isset($_GET['admin_id'])) {
            $admin_id = $_GET['admin_id'];
            echo json_encode($adminModel->deleteAdmin($admin_id));
        } else {
            echo json_encode(["success" => false, "message" => "Admin ID is required for deletion"]);
        }
        break;

    default:
        // Method Not Allowed
        header("HTTP/1.1 405 Method Not Allowed");
        echo json_encode(["success" => false, "message" => "Method Not Allowed"]);
        break;
}
