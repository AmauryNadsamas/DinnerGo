# Restaurant Ordering App – Flutter + PHP + MySQL

Aplicación móvil completa para la gestión de pedidos en un restaurante.
Incluye selección de mesa, catálogo de platillos, carrito dinámico, confirmación de pedido y backend con API en PHP.

---

## Tecnologías utilizadas

### Frontend (App móvil)

* Flutter 3.x
* Dart
* animate_do
* curved_navigation_bar
* HTTP REST API

### Backend

* PHP 8
* MySQL
* MAMP (Mac)

---

## Características principales

* Selección de mesa (disponible u ocupada)
* Catálogo de platillos organizados por categorías
* Buscador en tiempo real
* Vista detallada del platillo mediante overlay
* Agregar platillos al pedido
* Modificar cantidad
* Eliminar artículos
* Confirmación del pedido con contraseña
* Registro automático en historial
* Liberación de mesa al finalizar
* Consumo de API mediante HTTP
* Manejo de validaciones y mensajes dinámicos

---

## Estructura del repositorio

```
restaurant-ordering-app/
 ├─ lib/                # Código Flutter
 ├─ assets/             # Imágenes y recursos
 ├─ backend_php/        # API backend desarrollada en PHP
 ├─ database/
 │   └─ restaurant.sql  # Base de datos lista para importar
 ├─ screenshots/        # Capturas de pantalla
 ├─ README.md           # Documentación
 └─ pubspec.yaml
```

---

## Instalación y ejecución

### 1. Clonar el repositorio

```
git clone https://github.com/TU_USUARIO/TU_REPO.git
```

---

### 2. Instalar dependencias de Flutter

```
flutter pub get
```

---

### 3. Configurar el backend (PHP y MySQL)

1. Instalar MAMP
2. Copiar la carpeta:

```
backend_php/
```

en:

```
/Applications/MAMP/htdocs/restaurant/
```

3. Abrir phpMyAdmin:

```
http://localhost:8888/phpMyAdmin
```

4. Crear una base de datos llamada:

```
restaurant
```

5. Importar el archivo:

```
database/restaurant.sql
```

---

### 4. Configurar la IP local en Flutter

En los archivos que consumen API, por ejemplo:

* home.dart
* cart.dart
* login.dart
* mesas.dart

Actualizar la IP:

```
http://192.168.X.X:8888/restaurant/get_platillos.php
```

Para obtener tu IP local en Mac:

```
ifconfig | grep inet
```

Usa la IP que empiece con 192.168.

---

## Capturas de pantalla



```
/screenshots
```

Ejemplo de uso en el README:

```
### Pantalla de inicio
screenshots/inicio.png

### Selección de mesa
screenshots/mesas.png

### Catálogo
screenshots/catalogo.png

### Carrito
screenshots/carrito.png
```

---

## Autor

Amaury Hernández  
Desarrollador Mobile y Fullstack Junior  
GitHub: https://github.com/AmauryNadsamas

---

## Notas adicionales

Este proyecto fue diseñado como un sistema completo para la administración de pedidos dentro de un restaurante.
Cuenta con interfaz intuitiva, animaciones suaves y comunicación directa con un backend ligero desarrollado en PHP.
Está estructurado para ser fácil de revisar y de implementar en un entorno local mediante MAMP.

