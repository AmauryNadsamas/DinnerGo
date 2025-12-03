 <?php
 error_reporting(E_ALL);
ini_set('display_errors', 1);
require "conexion.php";



$data = json_decode(file_get_contents("php://input"), true);

$usuario = $data["usuario"];
$pass = $data["contrasena"];

$sql = $conn->prepare("SELECT * FROM usuarios WHERE usuario=? AND contrasena=?");
$sql->bind_param("ss", $usuario, $pass);
$sql->execute();
$res = $sql->get_result();

if ($res->num_rows == 1) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => "Usuario o contraseña incorrectos"]);
}
?>
