<?php
require "conexion.php";

$data = json_decode(file_get_contents("php://input"), true);

$mesa = $data["numero_mesa"];
$nombre = $data["nombre_platillo"];
$obs = $data["observaciones"];
$cantidad = $data["cantidad"];
$precio = $data["precio"];

$sqlCheck = $conn->prepare("SELECT id FROM carrito WHERE numero_mesa = ? AND nombre_platillo = ?");
$sqlCheck->bind_param("is", $mesa, $nombre);
$sqlCheck->execute();
$resCheck = $sqlCheck->get_result();

if ($resCheck->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "El platillo ya está en el pedido, modifique la cantidad en el carrito."]);
    exit;
}

$sql = $conn->prepare("INSERT INTO carrito (numero_mesa, nombre_platillo, observaciones, cantidad, precio) VALUES (?, ?, ?, ?, ?)");
$sql->bind_param("issid", $mesa, $nombre, $obs, $cantidad, $precio);

if ($sql->execute()) {
    echo json_encode(["success" => true, "message" => "Platillo agregado."]);
} else {
    echo json_encode(["success" => false, "message" => "Error al agregar."]);
}
?>
