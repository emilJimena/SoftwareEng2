<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include("../db.php"); // adjust path to your database connection

try {
    $addons = [
        'sizes' => [],
        'crusts' => [],
        'dips' => [],
        'stuffed' => [],
        'pizzaAddons' => [],
        'pastaAddons' => [],
        'riceAddons' => []
    ];

    $tables = [
        'sizes' => 'sizes',
        'crusts' => 'crusts',
        'dips' => 'dips',
        'stuffed' => 'stuffed',
        'pizzaAddons' => 'pizza_addons'
    ];

    foreach ($tables as $key => $table) {
        $res = $conn->query("SELECT name, price FROM $table");
        if ($res) {
            while ($row = $res->fetch_assoc()) {
                $addons[$key][$row['name']] = (float)$row['price'];
            }
        }
    }

    // Pasta addons
    $res = $conn->query("SELECT category, name, price FROM pasta_addons");
    if ($res) {
        while ($row = $res->fetch_assoc()) {
            if (!isset($addons['pastaAddons'][$row['category']])) {
                $addons['pastaAddons'][$row['category']] = [];
            }
            $addons['pastaAddons'][$row['category']][$row['name']] = (float)$row['price'];
        }
    }

    // Rice addons
    $res = $conn->query("SELECT category, name, price FROM rice_addons");
    if ($res) {
        while ($row = $res->fetch_assoc()) {
            if (!isset($addons['riceAddons'][$row['category']])) {
                $addons['riceAddons'][$row['category']] = [];
            }
            $addons['riceAddons'][$row['category']][$row['name']] = (float)$row['price'];
        }
    }

    echo json_encode($addons);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
