<?php

include 'db.php';

class MProduct
{
    // Fetch all products
    public function getProducts()
    {
        global $conn;
        $query = "SELECT * FROM Product";
        $result = $conn->query($query);

        $products = [];
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }

        return [
            'success' => true,
            'data' => $products
        ];
    }

    // Fetch a specific product by ID
    public function getProductById($product_id)
    {
        global $conn;
        $query = "SELECT * FROM Product WHERE product_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $product_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $product = $result->fetch_assoc();

        return $product ? ['success' => true, 'data' => $product] : ['success' => false, 'message' => 'Product not found'];
    }

    // Create a new product
    public function createProduct($data)
    {
        global $conn;

        // Make sure to assign the decoded JSON to a variable
        $product_id = $data['product_id'];
        $product_name = $data['product_name'];
        $quantity = $data['quantity'];
        $price = $data['price'];

        $stmt = $conn->prepare("INSERT INTO Product (product_id, product_name, quantity, price) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssdd", $product_id, $product_name, $quantity, $price);

        if ($stmt->execute()) {
            return ["success" => true, "message" => "Product created successfully"];
        } else {
            return ["success" => false, "message" => "Failed to create Product"];
        }
    }

    // Update an existing product
    public function updateProduct($product_id, $data)
    {
        global $conn;

        // Ensure $data is actually an array
        if (is_array($data)) {
            // Extract updated values from $data
            $new_product_id = $data['new_product_id'];
            $product_name = $data['product_name'];
            $quantity = $data['quantity'];
            $price = $data['price'];

            // Prepare the SQL query to update the product details
            $stmt = $conn->prepare("UPDATE Product SET product_id = ?, product_name = ?, quantity = ?, price = ? WHERE product_id = ?");
            $stmt->bind_param("ssdds", $new_product_id, $product_name, $quantity, $price, $product_id);

            if ($stmt->execute()) {
                return ["success" => true, "message" => "Product updated successfully"];
            } else {
                return ["success" => false, "message" => "Failed to update Product"];
            }

            $stmt->close();
        } else {
            return ["success" => false, "message" => "Invalid data format"];
        }
    }

    // Delete a product
    public function deleteProduct($product_id)
    {
        global $conn;
        $stmt = $conn->prepare("DELETE FROM Product WHERE product_id = ?");
        $stmt->bind_param("s", $product_id);

        if ($stmt->execute()) {
            return ['success' => true, 'message' => 'Product deleted successfully'];
        } else {
            return ['success' => false, 'message' => 'Failed to delete Product'];
        }
    }

    // Update the stock for a specific product // IDK IF THIS IS USED OR NOT RN
    public function updateProductStock($product_id, $new_stock)
    {
        global $conn;
        $stmt = $conn->prepare("UPDATE Product SET quantity = ? WHERE product_id = ?");
        $stmt->bind_param("ds", $new_stock, $product_id);
        $stmt->execute();
    }
}
