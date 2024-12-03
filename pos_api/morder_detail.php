<?php
include 'db.php';

class MOrderDetail
{

    // Fetch all order details
    public function getAllOrderDetails()
    {
        global $conn;
        $query = "SELECT * FROM `Order_detail`";
        $result = $conn->query($query);

        $order_details = [];
        while ($row = $result->fetch_assoc()) {
            $order_details[] = $row;
        }

        return ['success' => true, 'data' => $order_details];
    }

    // Fetch order details by order ID
    public function getOrderDetailsByOrderId($order_id)
    {
        global $conn;
        $query = "SELECT * FROM `Order_detail` WHERE order_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $order_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $order_details = [];
        while ($row = $result->fetch_assoc()) {
            $order_details[] = $row;
        }

        return ['success' => true, 'data' => $order_details];
    }

    public function createOrderDetail($data)
    {
        global $conn;

        $order_detail_id = $data['order_detail_id'];
        $order_id = $data['order_id'];
        $product_id = $data['product_id'];
        $quantity = (int) $data['quantity'];  // Ensure it's an integer

        // Fetch the price and current stock from the Product table based on product_id
        $getProductQuery = "SELECT price, quantity AS stock FROM `Product` WHERE product_id = ?";
        $stmt = $conn->prepare($getProductQuery);
        $stmt->bind_param("s", $product_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows == 0) {
            return ["success" => false, "message" => "Product ID does not exist"];
        }

        $row = $result->fetch_assoc();
        $price = $row['price'];
        $stock = $row['stock'];

        // Check if there is enough stock
        if ($quantity > $stock) {
            return ["success" => false, "message" => "Not enough stock available"];
        }

        // Calculate the subtotal
        $subtotal = $quantity * $price;

        // Insert the order detail into the Order_detail table
        $stmt = $conn->prepare("INSERT INTO `Order_detail` (order_detail_id, order_id, product_id, quantity, price, subtotal) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssdid", $order_detail_id, $order_id, $product_id, $quantity, $price, $subtotal);

        if ($stmt->execute()) {
            // Update the stock in the Product table
            $newStock = $stock - $quantity;
            $updateStockQuery = "UPDATE `Product` SET quantity = ? WHERE product_id = ?";
            $stmt = $conn->prepare($updateStockQuery);
            $stmt->bind_param("ds", $newStock, $product_id);
            if ($stmt->execute()) {
                // Update the total price in the Order table
                $updateOrderQuery = "UPDATE `Order` SET total_price = (SELECT SUM(subtotal) FROM `Order_detail` WHERE order_id = ?) WHERE order_id = ?";
                $stmt = $conn->prepare($updateOrderQuery);
                $stmt->bind_param("ss", $order_id, $order_id);
                if ($stmt->execute()) {
                    return ["success" => true, "message" => "Order detail created, stock updated, and total price updated successfully"];
                } else {
                    return ["success" => false, "message" => "Failed to update total price"];
                }
            } else {
                return ["success" => false, "message" => "Failed to update stock"];
            }
        } else {
            return ["success" => false, "message" => "Failed to create order detail"];
        }
    }


    // Tambahkan logika stok di updateOrderDetail
    public function updateOrderDetail($order_detail_id, $data)
    {
        global $conn;

        // Ambil data lama dari order detail
        $stmt = $conn->prepare("SELECT product_id, quantity FROM `Order_detail` WHERE order_detail_id = ?");
        $stmt->bind_param("s", $order_detail_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 0) {
            return ["success" => false, "message" => "Order detail not found"];
        }

        $currentData = $result->fetch_assoc();
        $oldProductId = $currentData['product_id'];
        $oldQuantity = $currentData['quantity'];

        $product_id = isset($data['product_id']) ? $data['product_id'] : $oldProductId;
        $quantity = isset($data['quantity']) ? $data['quantity'] : $oldQuantity;

        // Jika produk berubah, tambahkan kembali stok lama dan kurangi stok baru
        if ($product_id !== $oldProductId) {
            // Tambahkan kembali stok produk lama
            $stmt = $conn->prepare("UPDATE `Product` SET quantity = quantity + ? WHERE product_id = ?");
            $stmt->bind_param("ds", $oldQuantity, $oldProductId);
            $stmt->execute();

            // Kurangi stok produk baru
            $stmt = $conn->prepare("UPDATE `Product` SET quantity = quantity - ? WHERE product_id = ?");
            $stmt->bind_param("ds", $quantity, $product_id);
            $stmt->execute();
        } else {
            // Update stok produk berdasarkan selisih quantity
            $diff = $quantity - $oldQuantity;
            $stmt = $conn->prepare("UPDATE `Product` SET quantity = quantity - ? WHERE product_id = ?");
            $stmt->bind_param("ds", $diff, $product_id);
            $stmt->execute();
        }

        // Perbarui data order detail
        $priceQuery = "SELECT price FROM `Product` WHERE product_id = ?";
        $stmt = $conn->prepare($priceQuery);
        $stmt->bind_param("s", $product_id);
        $stmt->execute();
        $price = $stmt->get_result()->fetch_assoc()['price'];

        $subtotal = $quantity * $price;

        $stmt = $conn->prepare("UPDATE `Order_detail` SET product_id = ?, quantity = ?, price = ?, subtotal = ? WHERE order_detail_id = ?");
        $stmt->bind_param("sdids", $product_id, $quantity, $price, $subtotal, $order_detail_id);

        if ($stmt->execute()) {
            // Update total price di tabel Order
            $stmt = $conn->prepare("UPDATE `Order` SET total_price = (SELECT SUM(subtotal) FROM `Order_detail` WHERE order_id = ?) WHERE order_id = (SELECT order_id FROM `Order_detail` WHERE order_detail_id = ?)");
            $stmt->bind_param("ss", $data['order_id'], $order_detail_id);
            $stmt->execute();

            return ["success" => true, "message" => "Order detail and stock updated successfully"];
        } else {
            return ["success" => false, "message" => "Failed to update order detail"];
        }
    }
    
    public function deleteOrderDetail($order_detail_id)
    {
        global $conn;

        // Get the order_id for the order_detail being deleted
        $getOrderQuery = "SELECT order_id FROM `Order_detail` WHERE order_detail_id = ?";
        $stmt = $conn->prepare($getOrderQuery);
        $stmt->bind_param("s", $order_detail_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $order_id = $result->fetch_assoc()['order_id'];

        // Delete the order detail
        $stmt = $conn->prepare("DELETE FROM `Order_detail` WHERE order_detail_id = ?");
        $stmt->bind_param("s", $order_detail_id);

        if ($stmt->execute()) {
            // After deletion, update the total price in the Order table
            // If no order details are left, set total_price to 0
            $updateOrderQuery = "UPDATE `Order` SET total_price = 
                                 (SELECT IFNULL(SUM(subtotal), 0) FROM `Order_detail` WHERE order_id = ?) 
                                 WHERE order_id = ?";
            $stmt = $conn->prepare($updateOrderQuery);
            $stmt->bind_param("ss", $order_id, $order_id);
            if ($stmt->execute()) {
                return ['success' => true, 'message' => 'Order detail deleted and total price updated'];
            } else {
                return ['success' => false, 'message' => 'Failed to update total price'];
            }
        } else {
            return ['success' => false, 'message' => 'Failed to delete order detail'];
        }
    }
}
