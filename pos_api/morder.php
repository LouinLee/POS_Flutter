<?php
include 'db.php';

class MOrder
{
    // Fetch all orders
    public function getOrders()
    {
        global $conn;
        $query = "SELECT * FROM `Order`";
        $result = $conn->query($query);

        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = $row;
        }

        return ['success' => true, 'data' => $orders];
    }

    // Fetch a specific order by ID
    public function getOrderById($order_id)
    {
        global $conn;
        $query = "SELECT * FROM `Order` WHERE order_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $order_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $order = $result->fetch_assoc();
        return $order ? ['success' => true, 'data' => $order] : ['success' => false, 'message' => 'Order not found'];
    }

    // Create a new order
    public function createOrder($data)
    {
        global $conn;

        $order_id = $data['order_id'];
        $total_price = 0;  // Set total price to 0 by default
        $order_date = isset($data['order_date']) ? $data['order_date'] : date("Y-m-d");  // Set current date if not provided

        $stmt = $conn->prepare("INSERT INTO `Order` (order_id, total_price, order_date) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $order_id, $total_price, $order_date);

        if ($stmt->execute()) {
            return ["success" => true, "message" => "Order created successfully"];
        } else {
            return ["success" => false, "message" => "Failed to create order"];
        }
    }

    // Update order details
    public function updateOrder($order_id, $data)
    {
        global $conn;

        // Check if the new order_id is passed in the data
        if (isset($data['new_order_id'])) {
            $new_order_id = $data['new_order_id'];
        } else {
            return ['success' => false, 'message' => 'New order ID is required'];
        }

        // If new_order_id is different from the old order_id, proceed with the update
        if ($order_id != $new_order_id) {
            // Step 1: Update the order_id in the Order table
            $updateOrderQuery = "UPDATE `Order` SET order_id = ? WHERE order_id = ?";
            $stmt = $conn->prepare($updateOrderQuery);
            $stmt->bind_param("ss", $new_order_id, $order_id);
            if ($stmt->execute()) {
                return ['success' => true, 'message' => 'Order updated successfully'];
            } else {
                return ['success' => false, 'message' => 'Failed to update order ID in Order table'];
            }
        } else {
            return ['success' => false, 'message' => 'The new order_id cannot be the same as the old one'];
        }
    }

    // Delete an order
    public function deleteOrder($order_id)
    {
        global $conn;

        // Step 1: Delete related records in order_detail table
        $deleteOrderDetailQuery = "DELETE FROM `order_detail` WHERE order_id = ?";
        $stmt = $conn->prepare($deleteOrderDetailQuery);
        $stmt->bind_param("s", $order_id);
        $stmt->execute();

        // Step 2: Delete the order from the Order table
        $stmt = $conn->prepare("DELETE FROM `Order` WHERE order_id = ?");
        $stmt->bind_param("s", $order_id);

        if ($stmt->execute()) {
            return ['success' => true, 'message' => 'Order deleted successfully'];
        } else {
            return ['success' => false, 'message' => 'Failed to delete order'];
        }
    }
}
