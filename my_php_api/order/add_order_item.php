<?php
include 'db.php'; // your DB connection

// Get POST data
$data = json_decode(file_get_contents('php://input'), true);

$order_id = $data['order_id'] ?? 0;
$menu_item = $data['menu_item'] ?? '';
$category = $data['category'] ?? '';
$quantity = $data['quantity'] ?? 1;
$size = $data['size'] ?? '';
$price = $data['price'] ?? 0.0;
$addons = isset($data['addons']) ? json_encode($data['addons']) : json_encode([]);

$sql = "INSERT INTO order_items (order_id, menu_item, category, quantity, size, price, addons)
        VALUES (?, ?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("issiids", $order_id, $menu_item, $category, $quantity, $size, $price, $addons);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $stmt->error]);
}
?>
