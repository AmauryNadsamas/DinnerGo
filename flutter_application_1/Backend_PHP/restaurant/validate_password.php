<?php
require "conexion.php";

$data = json_decode(file_get_contents("php://input"), true);
$pass = $data["password"];

$sql = $conn->prepare("SELECT id FROM usuarios WHERE contrasena = ?");
$sql->bind_param("s", $pass);
$sql->execute();
$result = $sql->get_result();

echo json_encode(["valid" => $result->num_rows > 0]);
?>
