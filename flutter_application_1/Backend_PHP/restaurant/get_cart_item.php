<?php
require "conexion.php";
$data = json_decode(file_get_contents("php://input"), true);

$mesa = $data["numero_mesa"];
$id = $data["id"];

$sql = $conn->prepare("DELETE FROM carrito WHERE numero_mesa = ? AND id = ?");
$sql->bind_param("ii", $mesa, $id);

if ($sql->execute()) {
    echo json_encode(["success" => true, "message" => "Eliminado"]);
} else {
    echo json_encode(["success" => false, "message" => "Error"]);
}
?>
