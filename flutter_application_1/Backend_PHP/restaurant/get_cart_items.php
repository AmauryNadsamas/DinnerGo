<?php
require "conexion.php";

$data = json_decode(file_get_contents("php://input"), true);
$mesa = $data["numero_mesa"];

$sql = $conn->prepare("SELECT * FROM carrito WHERE numero_mesa = ?");
$sql->bind_param("i", $mesa);
$sql->execute();
$result = $sql->get_result();

$items = [];
while ($row = $result->fetch_assoc()) {
    $items[] = $row;
}

echo json_encode(["success" => true, "data" => $items]);
?>
