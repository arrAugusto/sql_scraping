-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 04-08-2024 a las 20:17:34
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `scraping_shop`
--
CREATE DATABASE IF NOT EXISTS `scraping_shop` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `scraping_shop`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `GET_LOG_LECTURA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_LOG_LECTURA` (IN `fechaLectura` VARCHAR(20))   BEGIN

SELECT log.PK_UUID_LOG_LECTURA, ifnull(log.estado_productos, 0) AS 'estado_productos',

(SELECT COUNT(*) FROM tbl_categorias cat
INNER JOIN tbl_urls_paginadas paginas ON cat.PK_UUID_CATEGORIA = paginas.FK_UUID_CATEGORIA
WHERE cat.FK_UUID_LOG_LECTURA = log.PK_UUID_LOG_LECTURA
) AS 'number_pages' 
,
(SELECT count(*) FROM scraping_shop.tbl_urls_for_page forPage
where forPage.FK_UUID_LOG_LECTURA = log.PK_UUID_LOG_LECTURA) as 'number_urls_products'

FROM scraping_shop.log_lectura log
WHERE 
log.fechaYHora_lectura BETWEEN CONCAT(fechaLectura, ' 00:00:00') AND CONCAT(fechaLectura, ' 23:59:59')
ORDER BY log.fechaYHora_lectura ASC;



END$$

DROP PROCEDURE IF EXISTS `GET_PAGINAS_LECTURA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_PAGINAS_LECTURA` (IN `p_pagina` INT, IN `p_FK_UUID_LOG_LECTURA` VARCHAR(36))   BEGIN

SELECT pagina.url_pagina, pagina.PK_UUID_PAGINA, pagina.FK_UUID_CATEGORIA, cat.FK_UUID_LOG_LECTURA FROM scraping_shop.tbl_urls_paginadas pagina
INNER JOIN tbl_categorias cat ON  pagina.FK_UUID_CATEGORIA =  cat.PK_UUID_CATEGORIA 
WHERE cat.FK_UUID_LOG_LECTURA = p_FK_UUID_LOG_LECTURA
LIMIT 100 OFFSET p_pagina;


END$$

DROP PROCEDURE IF EXISTS `GET_URLS_PRODUCTS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_URLS_PRODUCTS` (IN `pagina` INT, IN `p_FK_UUID_LOG_LECTURA` VARCHAR(36))   BEGIN

SELECT url_for_page, PK_UUID_FOR_PAGE, FK_UUID_LOG_LECTURA, FK_UUID_PAGINA FROM scraping_shop.tbl_urls_for_page 
WHERE FK_UUID_LOG_LECTURA = p_FK_UUID_LOG_LECTURA
LIMIT 100 offset pagina;


END$$

DROP PROCEDURE IF EXISTS `INSERT_CATEGORIA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_CATEGORIA` (IN `p_tienda` VARCHAR(45), IN `p_id_tienda` VARCHAR(15), IN `p_categoria` VARCHAR(75), IN `p_nombre_categoria` VARCHAR(125), IN `p_url_categoria` VARCHAR(450), IN `p_fechaYHora_categoria` VARCHAR(50), IN `p_FK_UUID_LOG_LECTURA` VARCHAR(36), IN `p_PK_UUID_CATEGORIA` VARCHAR(36))   BEGIN

INSERT INTO `scraping_shop`.`tbl_categorias`
(
`tienda`,
`id_tienda`,
`categoria`,
`nombre_categoria`,
`url_categoria`,
`fechaYHora_categoria`,
`FK_UUID_LOG_LECTURA`,
`PK_UUID_CATEGORIA`)
VALUES
(
p_tienda,
p_id_tienda,
p_categoria,
p_nombre_categoria,
p_url_categoria,
p_fechaYHora_categoria,
p_FK_UUID_LOG_LECTURA,
p_PK_UUID_CATEGORIA
);

END$$

DROP PROCEDURE IF EXISTS `INSERT_DESCRIPTION`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_DESCRIPTION` (IN `p_descripcion` VARCHAR(500), IN `p_FK_UUID_PRODUCTO` VARCHAR(36))   BEGIN

INSERT INTO `scraping_shop`.`tbl_descripcion`
(
`descripcion`,
`FK_UUID_PRODUCTO`)
VALUES
(
p_descripcion,
p_FK_UUID_PRODUCTO);


END$$

DROP PROCEDURE IF EXISTS `INSERT_ESPECIFICACIONES`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_ESPECIFICACIONES` (IN `p_especificacion` VARCHAR(550), IN `p_descripcion` VARCHAR(550), IN `p_FK_UUID_PRODUCTO` VARCHAR(36))   BEGIN

INSERT INTO `scraping_shop`.`tbl_especificaciones`
(
`especificacion`,
`descripcion`,
`FK_UUID_PRODUCTO`)
VALUES
(
p_especificacion,
p_descripcion,
p_FK_UUID_PRODUCTO);


END$$

DROP PROCEDURE IF EXISTS `INSERT_LOG_CAT_LECTURA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_LOG_CAT_LECTURA` (IN `p_uuid_lectura_diaria` VARCHAR(36), IN `estado_categoria` INT)   BEGIN


INSERT INTO `scraping_shop`.`log_lectura`
(
`PK_UUID_LOG_LECTURA`,
`estado_categoria`,
`fechaYHora_lectura`)
VALUES
(
p_uuid_lectura_diaria,
estado_categoria,
SYSDATE());


END$$

DROP PROCEDURE IF EXISTS `INSERT_PRODUCTO_READ`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_PRODUCTO_READ` (IN `p_url_imagen_producto` VARCHAR(250), IN `p_url_marca` VARCHAR(250), IN `p_url_pagina` VARCHAR(250), IN `p_nombre` VARCHAR(250), IN `p_sku_value` VARCHAR(50), IN `p_sku` VARCHAR(50), IN `p_disponibildidad` VARCHAR(50), IN `p_precio` VARCHAR(15), IN `p_old_precio` VARCHAR(15), IN `p_oferta` VARCHAR(15), IN `p_fecahYHora` DATETIME, IN `p_PK_UUID_PRODUCTO` VARCHAR(36), IN `p_FK_UUID_PAGINA` VARCHAR(36), IN `p_FK_UUID_CATEGORIA` VARCHAR(36), IN `p_FK_UUID_LOG_LECTURA` VARCHAR(36))   BEGIN

INSERT INTO `scraping_shop`.`tbl_producto`
(
`url_imagen_producto`,
`url_marca`,
`url_pagina`,
`nombre`,
`sku_value`,
`sku`,
`disponibildidad`,
`precio`,
`old_precio`,
`oferta`,
`fecahYHora`,
`PK_UUID_PRODUCTO`,
`FK_UUID_PAGINA`,
`FK_UUID_CATEGORIA`,
`FK_UUID_LOG_LECTURA`)
VALUES
(
p_url_imagen_producto,
p_url_marca,
p_url_pagina,
p_nombre,
p_sku_value,
p_sku,
p_disponibildidad,
p_precio,
p_old_precio,
p_oferta,
p_fecahYHora,
p_PK_UUID_PRODUCTO,
p_FK_UUID_PAGINA,
p_FK_UUID_CATEGORIA,
p_FK_UUID_LOG_LECTURA
);


END$$

DROP PROCEDURE IF EXISTS `INSERT_URLS_PAGINADAS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_URLS_PAGINADAS` (IN `p_url_pagina` VARCHAR(450), IN `p_url_base` VARCHAR(450), IN `p_FK_UUID_CATEGORIA` VARCHAR(36), IN `p_PK_UUID_PAGINA` VARCHAR(36))   BEGIN

INSERT INTO `scraping_shop`.`tbl_urls_paginadas`
(
`url_pagina`,
`url_base`,
`FK_UUID_CATEGORIA`,
`PK_UUID_PAGINA`)
VALUES
(
p_url_pagina,
p_url_base,
p_FK_UUID_CATEGORIA,
p_PK_UUID_PAGINA);


END$$

DROP PROCEDURE IF EXISTS `INSERT_URL_FOR_PAGE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_URL_FOR_PAGE` (IN `p_url_for_page` VARCHAR(350), IN `p_url_page` VARCHAR(350), IN `p_fechaYHora` VARCHAR(20), IN `p_PK_UUID_FOR_PAGE` VARCHAR(36), IN `p_FK_UUID_PAGINA` VARCHAR(36), IN `p_FK_UUID_LOG_LECTURA` VARCHAR(36))   BEGIN

INSERT INTO `scraping_shop`.`tbl_urls_for_page`
(
`url_for_page`,
`url_page`,
`fechaYHora`,
`PK_UUID_FOR_PAGE`,
`FK_UUID_PAGINA`,
`FK_UUID_LOG_LECTURA`)
VALUES
(
p_url_for_page,
p_url_page,
p_fechaYHora,
p_PK_UUID_FOR_PAGE,
p_FK_UUID_PAGINA,
p_FK_UUID_LOG_LECTURA
);


END$$

DROP PROCEDURE IF EXISTS `UPDATE_LOG_CAT_LECTURA_CARGA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_LOG_CAT_LECTURA_CARGA` (IN `FK_UUID_LOG_LECTURA` VARCHAR(36))   BEGIN

SET @identity = (SELECT PK_UUID_LOG_LECTURA FROM log_lectura WHERE PK_UUID_LOG_LECTURA = FK_UUID_LOG_LECTURA);

UPDATE `scraping_shop`.`log_lectura`
SET
`estado_productos` = 1
WHERE `id` = @identity;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_lectura`
--

DROP TABLE IF EXISTS `log_lectura`;
CREATE TABLE `log_lectura` (
  `id` int(11) NOT NULL,
  `PK_UUID_LOG_LECTURA` varchar(36) DEFAULT NULL,
  `estado_categoria` int(11) DEFAULT NULL,
  `estado_productos` int(11) DEFAULT NULL,
  `fechaYHora_lectura` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `log_lectura`
--

TRUNCATE TABLE `log_lectura`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prueba`
--

DROP TABLE IF EXISTS `prueba`;
CREATE TABLE `prueba` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `prueba`
--

TRUNCATE TABLE `prueba`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_categorias`
--

DROP TABLE IF EXISTS `tbl_categorias`;
CREATE TABLE `tbl_categorias` (
  `id` int(11) NOT NULL,
  `tienda` varchar(45) DEFAULT NULL,
  `id_tienda` varchar(15) DEFAULT NULL,
  `categoria` varchar(75) DEFAULT NULL,
  `nombre_categoria` varchar(125) DEFAULT NULL,
  `url_categoria` varchar(450) DEFAULT NULL,
  `fechaYHora_categoria` datetime DEFAULT NULL,
  `FK_UUID_LOG_LECTURA` varchar(36) DEFAULT NULL,
  `PK_UUID_CATEGORIA` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `tbl_categorias`
--

TRUNCATE TABLE `tbl_categorias`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_descripcion`
--

DROP TABLE IF EXISTS `tbl_descripcion`;
CREATE TABLE `tbl_descripcion` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `FK_UUID_PRODUCTO` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `tbl_descripcion`
--

TRUNCATE TABLE `tbl_descripcion`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_especificaciones`
--

DROP TABLE IF EXISTS `tbl_especificaciones`;
CREATE TABLE `tbl_especificaciones` (
  `id` int(11) NOT NULL,
  `especificacion` varchar(550) DEFAULT NULL,
  `descripcion` varchar(550) DEFAULT NULL,
  `FK_UUID_PRODUCTO` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `tbl_especificaciones`
--

TRUNCATE TABLE `tbl_especificaciones`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_producto`
--

DROP TABLE IF EXISTS `tbl_producto`;
CREATE TABLE `tbl_producto` (
  `id` int(11) NOT NULL,
  `url_imagen_producto` varchar(250) DEFAULT NULL,
  `url_marca` varchar(250) DEFAULT NULL,
  `url_pagina` varchar(250) DEFAULT NULL,
  `nombre` varchar(250) DEFAULT NULL,
  `sku_value` varchar(50) DEFAULT NULL,
  `sku` varchar(50) DEFAULT NULL,
  `disponibildidad` varchar(50) DEFAULT NULL,
  `precio` varchar(15) DEFAULT NULL,
  `old_precio` varchar(15) DEFAULT NULL,
  `oferta` varchar(15) DEFAULT NULL,
  `fecahYHora` datetime DEFAULT NULL,
  `PK_UUID_PRODUCTO` varchar(36) DEFAULT NULL,
  `FK_UUID_PAGINA` varchar(36) DEFAULT NULL,
  `FK_UUID_CATEGORIA` varchar(36) DEFAULT NULL,
  `FK_UUID_LOG_LECTURA` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `tbl_producto`
--

TRUNCATE TABLE `tbl_producto`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_urls_for_page`
--

DROP TABLE IF EXISTS `tbl_urls_for_page`;
CREATE TABLE `tbl_urls_for_page` (
  `id` int(11) NOT NULL,
  `url_for_page` varchar(350) DEFAULT NULL,
  `url_page` varchar(350) DEFAULT NULL,
  `fechaYHora` datetime DEFAULT NULL,
  `PK_UUID_FOR_PAGE` varchar(36) DEFAULT NULL,
  `FK_UUID_PAGINA` varchar(36) DEFAULT NULL,
  `FK_UUID_LOG_LECTURA` varchar(36) DEFAULT NULL,
  `tbl_urls_for_pagecol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `tbl_urls_for_page`
--

TRUNCATE TABLE `tbl_urls_for_page`;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_urls_paginadas`
--

DROP TABLE IF EXISTS `tbl_urls_paginadas`;
CREATE TABLE `tbl_urls_paginadas` (
  `id` int(11) NOT NULL,
  `url_pagina` varchar(450) DEFAULT NULL,
  `url_base` varchar(450) DEFAULT NULL,
  `FK_UUID_CATEGORIA` varchar(36) DEFAULT NULL,
  `PK_UUID_PAGINA` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncar tablas antes de insertar `tbl_urls_paginadas`
--

TRUNCATE TABLE `tbl_urls_paginadas`;
--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `log_lectura`
--
ALTER TABLE `log_lectura`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_uuid_lectura_diaria` (`PK_UUID_LOG_LECTURA`),
  ADD KEY `idx_estado_categoria` (`estado_categoria`),
  ADD KEY `idx_fechaYHora_lectura` (`fechaYHora_lectura`),
  ADD KEY `idx_estado_categoria_fechaYHora` (`estado_categoria`,`fechaYHora_lectura`);

--
-- Indices de la tabla `prueba`
--
ALTER TABLE `prueba`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_PK_UUID_CATEGORIA` (`PK_UUID_CATEGORIA`),
  ADD KEY `FK_UUID_LOG_LECTURA` (`FK_UUID_LOG_LECTURA`);

--
-- Indices de la tabla `tbl_descripcion`
--
ALTER TABLE `tbl_descripcion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tbl_especificaciones`
--
ALTER TABLE `tbl_especificaciones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tbl_producto`
--
ALTER TABLE `tbl_producto`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tbl_urls_for_page`
--
ALTER TABLE `tbl_urls_for_page`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_uuid_log_lectura` (`FK_UUID_LOG_LECTURA`);

--
-- Indices de la tabla `tbl_urls_paginadas`
--
ALTER TABLE `tbl_urls_paginadas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_categoria` (`FK_UUID_CATEGORIA`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `log_lectura`
--
ALTER TABLE `log_lectura`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1316;

--
-- AUTO_INCREMENT de la tabla `tbl_descripcion`
--
ALTER TABLE `tbl_descripcion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tbl_especificaciones`
--
ALTER TABLE `tbl_especificaciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tbl_producto`
--
ALTER TABLE `tbl_producto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tbl_urls_for_page`
--
ALTER TABLE `tbl_urls_for_page`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tbl_urls_paginadas`
--
ALTER TABLE `tbl_urls_paginadas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  ADD CONSTRAINT `tbl_categorias_ibfk_1` FOREIGN KEY (`FK_UUID_LOG_LECTURA`) REFERENCES `log_lectura` (`PK_UUID_LOG_LECTURA`);

--
-- Filtros para la tabla `tbl_urls_for_page`
--
ALTER TABLE `tbl_urls_for_page`
  ADD CONSTRAINT `fk_uuid_log_lectura` FOREIGN KEY (`FK_UUID_LOG_LECTURA`) REFERENCES `log_lectura` (`PK_UUID_LOG_LECTURA`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `tbl_urls_paginadas`
--
ALTER TABLE `tbl_urls_paginadas`
  ADD CONSTRAINT `fk_categoria` FOREIGN KEY (`FK_UUID_CATEGORIA`) REFERENCES `tbl_categorias` (`PK_UUID_CATEGORIA`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
