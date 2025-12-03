<?php
require "conexion.php";

$data = json_decode(file_get_contents("php://input"), true);
$mesa = $data["numero_mesa"];

$sql = $conn->prepare("DELETE FROM carrito WHERE numero_mesa = ?");
$sql->bind_param("i", $mesa);

if ($sql->execute()) {
    echo json_encode(["success" => true, "message" => "Mesa limpiada"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al limpiar"]);
}
?>
