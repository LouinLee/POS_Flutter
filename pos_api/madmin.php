<?php

include 'db.php';

class MAdmin
{
    // Fetch all Admins
    public function getAdmins()
    {
        global $conn;
        $query = "SELECT * FROM Admin";
        $result = $conn->query($query);

        $admins = [];
        while ($row = $result->fetch_assoc()) {
            $admins[] = $row;
        }

        return [
            'success' => true,
            'data' => $admins
        ];
    }

    // Fetch a specific Admin by ID
    public function getAdminById($admin_id)
    {
        global $conn;
        $query = "SELECT * FROM Admin WHERE admin_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $admin_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $admin = $result->fetch_assoc();

        return $admin ? ['success' => true, 'data' => $admin] : ['success' => false, 'message' => 'Admin not found'];
    }

    // Create a new Admin
    public function createAdmin($data)
    {
        global $conn;
        // Make sure to assign the decoded JSON to a variable
        $admin_id = $data['admin_id'];
        $name = $data['name'];
        $email = $data['email'];
        $password = password_hash($data['password'], PASSWORD_BCRYPT);

        $stmt = $conn->prepare("INSERT INTO Admin (admin_id, name, email, password) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $admin_id, $name, $email, $password);

        if ($stmt->execute()) {
            return (["success" => true, "message" => "Admin created successfully"]);
        } else {
            return (["success" => false, "message" => "Failed to create Admin"]);
        }
    }

    // Update an Admin's details
    public function updateAdmin($admin_id, $data)
    {
        global $conn;

        // Ensure $data is actually an array
        if (is_array($data)) {
            // Extract updated values from $data
            $new_admin_id = $data['new_admin_id'];
            $name = $data['name'];
            $email = $data['email'];
            $password = password_hash($data['password'], PASSWORD_BCRYPT);

            // Prepare the SQL query to update the admin details
            $stmt = $conn->prepare("UPDATE Admin SET admin_id = ?, name = ?, email = ?, password = ? WHERE admin_id = ?");
            $stmt->bind_param("sssss", $new_admin_id, $name, $email, $password, $admin_id);

            // Execute the query
            if ($stmt->execute()) {
                return ["success" => true, "message" => "Admin updated successfully"];
            } else {
                return ["success" => false, "message" => "Failed to update Admin"];
            }

            $stmt->close();
        } else {
            return ["success" => false, "message" => "Invalid data format"];
        }
    }

    // Delete an Admin
    public function deleteAdmin($admin_id)
    {
        global $conn;
        $stmt = $conn->prepare("DELETE FROM Admin WHERE admin_id = ?");
        $stmt->bind_param("s", $admin_id);

        if ($stmt->execute()) {
            return ['success' => true, 'message' => 'Admin deleted successfully'];
        } else {
            return ['success' => false, 'message' => 'Failed to delete Admin'];
        }
    }
}
