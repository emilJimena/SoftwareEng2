<?php
header("Content-Type: application/json");
include("../db.php");

$input = json_decode(file_get_contents('php://input'), true);
$addonIds = $input['addon_ids'] ?? [];

if (empty($addonIds)) {
    echo json_encode([]);
    exit;
}

$ids = implode(',', array_map('intval', $addonIds));

$sql = "SELECT ma.addon_id, rm.name AS material_name, ma.quantity
        FROM menu_addons ma
        JOIN raw_materials rm ON ma.material_id = rm.id
        WHERE ma.addon_id IN ($ids)";

$result = mysqli_query($conn, $sql);
$data = [];

while ($row = mysqli_fetch_assoc($result)) {
    $addon_id = $row['addon_id'];
    if (!isset($data[$addon_id])) $data[$addon_id] = [];
    $data[$addon_id][$row['material_name']] = floatval($row['quantity']);
}

echo json_encode($data);
?>
