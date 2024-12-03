<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // Allows all origins, you can specify your Flutter app's URL here
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT"); // Allow HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With"); // Allow necessary headers

include 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_GET['action'] ?? '';
    $data = json_decode(file_get_contents("php://input"), true);

    if ($action === 'register') {
        registerAdmin($data);
    } elseif ($action === 'login') {
        loginAdmin($data);
    }
}

function registerAdmin($data)
{
    global $conn;
    $name = $data['name'];
    $email = $data['email'];
    $password = password_hash($data['password'], PASSWORD_BCRYPT);

    $stmt = $conn->prepare("INSERT INTO Admin (admin_id, name, email, password) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $data['admin_id'], $name, $email, $password);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Registration successful"]);
    } else {
        echo json_encode(["success" => false, "message" => "Registration failed"]);
    }
    $stmt->close();
}

function loginAdmin($data)
{
    global $conn;
    $email = $data['email'];
    $password = $data['password'];

    $stmt = $conn->prepare("SELECT password FROM Admin WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->bind_result($hashedPassword);
    $stmt->fetch();

    if ($hashedPassword && password_verify($password, $hashedPassword)) {
        echo json_encode(["success" => true, "message" => "Login successful"]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid credentials"]);
    }
    $stmt->close();
}
