<?php
require "conexion.php";

$sql = "SELECT * FROM platillos";
$result = $conn->query($sql);

$platillos = [];
while ($row = $result->fetch_assoc()) {
    $platillos[] = $row;
}

echo json_encode(["success" => true, "data" => $platillos]);
?>
