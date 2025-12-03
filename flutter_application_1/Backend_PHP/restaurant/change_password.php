<?php
require "conexion.php";

$data = json_decode(file_get_contents("php://input"), true);

$usuario = $data["usuario"];
$nuevo = $data["nueva_contrasena"];
$adminPass = $data["admin_contrasena"];

$sqlAdmin = $conn->prepare("SELECT id FROM usuarios WHERE contrasena=? AND rol='admin'");
$sqlAdmin->bind_param("s", $adminPass);
$sqlAdmin->execute();
$resAdmin = $sqlAdmin->get_result();

if ($resAdmin->num_rows == 0) {
    echo json_encode(["success" => false, "message" => "Contraseña de administrador incorrecta"]);
    exit;
}

$sql = $conn->prepare("UPDATE usuarios SET contrasena=? WHERE usuario=?");
$sql->bind_param("ss", $nuevo, $usuario);

if ($sql->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => "Error"]);
}
?>
