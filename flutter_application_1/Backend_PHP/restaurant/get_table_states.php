<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Content-Type: application/json");

require "conexion.php";

$query = "SELECT id, estado FROM mesas";
$result = $conn->query($query);

if (!$result) {
    echo json_encode([
        "success" => false,
        "message" => "Error en consulta: " . $conn->error
    ]);
    exit;
}

$tables = [];

while ($row = $result->fetch_assoc()) {
    $tables[] = [
    "id" => intval($row["id"]),
    "estado" => $row["estado"]
];

}

echo json_encode([
    "success" => true,
    "tables" => $tables
]);
