<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include("../db.php");
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$input = json_decode(file_get_contents('php://input'), true);

// --- Get menu_id & quantity ---
$menu_id = intval($input['menu_id'] ?? 0);
$quantity = floatval($input['quantity'] ?? 1); // default to 1 if not provided

if ($menu_id <= 0) {
    echo json_encode(['success' => false, 'message' => 'Menu ID is required']);
    exit;
}

try {
    $deductions = [];

    // --- 1. Fetch ingredients for this menu item ---
    $stmt = $conn->prepare("
        SELECT material_id, quantity
        FROM menu_ingredients
        WHERE menu_id = ?
    ");
    $stmt->bind_param("i", $menu_id);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $material_id = intval($row['material_id']);
        $deductions[$material_id] = floatval($row['quantity']) * $quantity; // multiply by cart quantity
    }

    if (empty($deductions)) {
        echo json_encode(['success' => false, 'message' => 'No ingredients found for this menu item']);
        exit;
    }

    // --- 2. Deduct from inventory ---
    $conn->begin_transaction();
    foreach ($deductions as $material_id => $qty) {
        $stmt = $conn->prepare("
            UPDATE raw_materials
            SET quantity = quantity - ?
            WHERE id = ?
        ");
        $stmt->bind_param("di", $qty, $material_id);
        $stmt->execute();
    }
    $conn->commit();

    echo json_encode(['success' => true, 'deductions' => $deductions]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
