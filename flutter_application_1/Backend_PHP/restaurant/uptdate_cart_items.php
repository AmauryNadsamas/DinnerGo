<?php
require "conexion.php";
$data = json_decode(file_get_contents("php://input"), true);

$items = $data["items"];

foreach ($items as $i) {
    $sql = $conn->prepare("UPDATE carrito SET observaciones=?, cantidad=?, precio=? WHERE id=?");
    $sql->bind_param("sidi", $i["observaciones"], $i["cantidad"], $i["precio"], $i["id"]);
    $sql->execute();
}

echo json_encode(["success" => true, "message" => "Carrito actualizado."]);
?>
