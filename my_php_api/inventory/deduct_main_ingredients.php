<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include("../db.php");
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$input = json_decode(file_get_contents('php://input'), true);

// --- Get menu_id, selected_addon_ids & quantity ---
$menu_id = intval($input['menu_id'] ?? 0);
$selected_addons = $input['selected_addon_ids'] ?? [];
$quantity = floatval($input['quantity'] ?? 1); // default to 1 if not provided

if ($menu_id <= 0) {
    echo json_encode(['success' => false, 'message' => 'Menu ID is required']);
    exit;
}

if (!is_array($selected_addons) || empty($selected_addons)) {
    echo json_encode(['success' => false, 'message' => 'No addons provided']);
    exit;
}

try {
    $deductions = [];

    // --- 1. Fetch addon ingredients ---
    $placeholders = implode(',', array_fill(0, count($selected_addons), '?'));
    $types = 'i' . str_repeat('i', count($selected_addons));
    $query = "
        SELECT material_id, quantity
        FROM menu_addons
        WHERE menu_id = ?
          AND addon_id IN ($placeholders)
    ";

    $stmt = $conn->prepare($query);
    $params = array_merge([$menu_id], $selected_addons);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $material_id = intval($row['material_id']);
        $deductions[$material_id] = ($deductions[$material_id] ?? 0) + (floatval($row['quantity']) * $quantity);
    }

    if (empty($deductions)) {
        echo json_encode(['success' => false, 'message' => 'No materials found for these addons']);
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
