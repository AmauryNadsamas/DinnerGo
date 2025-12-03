-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:8889
-- Tiempo de generación: 03-12-2025 a las 07:49:20
-- Versión del servidor: 8.0.40
-- Versión de PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `restaurant`
--
CREATE DATABASE IF NOT EXISTS `restaurant` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `restaurant`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito`
--

DROP TABLE IF EXISTS `carrito`;
CREATE TABLE `carrito` (
  `id` int NOT NULL,
  `numero_mesa` int NOT NULL,
  `nombre_platillo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `cantidad` int DEFAULT '1',
  `precio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `carrito`
--

INSERT INTO `carrito` (`id`, `numero_mesa`, `nombre_platillo`, `observaciones`, `cantidad`, `precio`) VALUES
(1, 4, 'Ensalada Fresca', '', 1, 55.00),
(2, 4, 'Hamburguesa Clásica', '', 1, 120.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_pedidos`
--

DROP TABLE IF EXISTS `historial_pedidos`;
CREATE TABLE `historial_pedidos` (
  `id` int NOT NULL,
  `numero_mesa` int NOT NULL,
  `items` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mesas`
--

DROP TABLE IF EXISTS `mesas`;
CREATE TABLE `mesas` (
  `id` int NOT NULL,
  `estado` enum('disponible','ocupada') COLLATE utf8mb4_unicode_ci DEFAULT 'disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mesas`
--

INSERT INTO `mesas` (`id`, `estado`) VALUES
(1, 'disponible'),
(2, 'disponible'),
(3, 'disponible'),
(4, 'disponible'),
(5, 'disponible'),
(6, 'disponible'),
(7, 'disponible'),
(8, 'disponible'),
(9, 'disponible'),
(10, 'disponible');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `platillos`
--

DROP TABLE IF EXISTS `platillos`;
CREATE TABLE `platillos` (
  `id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `ingredients` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `category` enum('Entradas','Principal','Postres','Bebidas') COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `platillos`
--

INSERT INTO `platillos` (`id`, `title`, `description`, `ingredients`, `image`, `price`, `category`) VALUES
(1, 'Hamburguesa Clásica', 'Pan artesanal, carne jugosa y queso cheddar.', 'Carne, pan, queso, tomate, lechuga', 'http://192.168.0.41:8888/restaurant/assets/assets/img/burger.png', 120.00, 'Principal'),
(2, 'Papas a la Francesa', 'Crujientes y sazonadas.', 'Papas, sal, aceite', 'http://192.168.0.41:8888/restaurant/assets/assets/img/fries.png', 45.00, 'Entradas'),
(3, 'Ensalada Fresca', 'Verduras frescas con aderezo ligero.', 'Lechuga, tomate, pepino, aderezo', 'http://192.168.0.41:8888/restaurant/assets/assets/img/salad.png', 55.00, 'Entradas'),
(4, 'Sandwich Especial', 'Sandwich con jamón, queso y vegetales.', 'Pan, jamón, queso, tomate, lechuga', 'http://192.168.0.41:8888/restaurant/assets/assets/img/sandwich.png', 65.00, 'Principal'),
(5, 'Sopa del Día', 'Receta especial del chef.', 'Caldo, verduras, especias', 'http://192.168.0.41:8888/restaurant/assets/assets/img/soup.png', 50.00, 'Entradas'),
(6, 'Pasta Alfredo', 'Pasta cremosa con queso parmesano.', 'Pasta, crema, parmesano', 'http://192.168.0.41:8888/restaurant/assets/assets/img/pasta.png', 110.00, 'Principal'),
(7, 'Steak a la Parrilla', 'Carne asada jugosa y suave.', 'Carne de res, sal, pimienta', 'http://192.168.0.41:8888/restaurant/assets/assets/img/steak.png', 180.00, 'Principal'),
(8, 'Pizza Especial', 'Pizza artesanal con toppings variados.', 'Masa, queso, salsa, toppings', 'http://192.168.0.41:8888/restaurant/assets/assets/img/pizza.png', 140.00, 'Principal'),
(9, 'Pizza Media Orden', 'Ideal para compartir.', 'Masa, queso, salsa', 'http://192.168.0.41:8888/restaurant/assets/assets/img/pizza_half.png', 80.00, 'Entradas'),
(10, 'Postre de Chocolate', 'Pastel suave y dulce.', 'Cacao, harina, azúcar', 'http://192.168.0.41:8888/restaurant/assets/assets/img/postres.png', 60.00, 'Postres'),
(11, 'Sushi Clásico', 'Rollos frescos preparados al momento.', 'Arroz, pescado, algas', 'http://192.168.0.41:8888/restaurant/assets/assets/img/sushi.png', 95.00, 'Principal'),
(12, 'Sushi Premium', 'Rollos especiales con ingredientes selectos.', 'Arroz, pescado premium', 'http://192.168.0.41:8888/restaurant/assets/assets/img/sushi2.jpg', 130.00, 'Principal'),
(13, 'Tacos Especiales', 'Tacos estilo casero con guarnición.', 'Tortilla, carne, cebolla, cilantro', 'http://192.168.0.41:8888/restaurant/assets/assets/img/tacos.png', 70.00, 'Principal'),
(14, 'Agua de Limonada', 'Refrescante y natural.', 'Limón, agua, azúcar', 'http://192.168.0.41:8888/restaurant/assets/assets/img/limonada.png', 30.00, 'Bebidas'),
(15, 'Agua de Fresa', 'Dulce y fresca.', 'Fresa, agua, azúcar', 'http://192.168.0.41:8888/restaurant/assets/assets/img/aguafresa.png', 30.00, 'Bebidas'),
(16, 'Bebida Especial', 'Bebida fría de la casa.', 'Ingredientes secretitos', 'http://192.168.0.41:8888/restaurant/assets/assets/img/especial.png', 35.00, 'Bebidas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `id` int NOT NULL,
  `usuario` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contrasena` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('admin','mesero','super') COLLATE utf8mb4_unicode_ci DEFAULT 'mesero',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `usuario`, `contrasena`, `rol`, `creado_en`) VALUES
(1, 'admin', '1234', 'admin', '2025-12-03 05:56:16'),
(2, 'mesero1', '1234', 'mesero', '2025-12-03 05:56:16'),
(3, 'mesero2', '1234', 'mesero', '2025-12-03 05:56:16'),
(4, 'superuser', '1234', 'super', '2025-12-03 05:56:16');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD PRIMARY KEY (`id`),
  ADD KEY `numero_mesa` (`numero_mesa`);

--
-- Indices de la tabla `historial_pedidos`
--
ALTER TABLE `historial_pedidos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `numero_mesa` (`numero_mesa`);

--
-- Indices de la tabla `mesas`
--
ALTER TABLE `mesas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `platillos`
--
ALTER TABLE `platillos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario` (`usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `carrito`
--
ALTER TABLE `carrito`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `historial_pedidos`
--
ALTER TABLE `historial_pedidos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `mesas`
--
ALTER TABLE `mesas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `platillos`
--
ALTER TABLE `platillos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD CONSTRAINT `carrito_ibfk_1` FOREIGN KEY (`numero_mesa`) REFERENCES `mesas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `historial_pedidos`
--
ALTER TABLE `historial_pedidos`
  ADD CONSTRAINT `historial_pedidos_ibfk_1` FOREIGN KEY (`numero_mesa`) REFERENCES `mesas` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
