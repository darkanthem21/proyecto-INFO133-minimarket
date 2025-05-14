-- Archivo: crear_base.sql (Corregido)
-- Asegúrate de estar conectado a tu base de datos 'sistema_inventario_db'

-- Eliminar tablas existentes para una nueva creación limpia (opcional, pero útil durante el desarrollo)
DROP TABLE IF EXISTS Detalle_Compras CASCADE;
DROP TABLE IF EXISTS Detalle_Ventas CASCADE;
DROP TABLE IF EXISTS Compras CASCADE;
DROP TABLE IF EXISTS Ventas CASCADE;
DROP TABLE IF EXISTS Productos CASCADE;
DROP TABLE IF EXISTS Proveedores CASCADE;
DROP TABLE IF EXISTS Trabajadores CASCADE;
DROP TABLE IF EXISTS Categorias CASCADE;

\echo 'Tablas anteriores eliminadas (si existían).'

-- Tabla: Categorias
CREATE TABLE Categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);
\echo 'Tabla Categorias creada.'

-- Tabla: Trabajadores
CREATE TABLE Trabajadores (
    id_trabajador SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    rol VARCHAR(100)
);
\echo 'Tabla Trabajadores creada.'

-- Tabla: Proveedores
CREATE TABLE Proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(255) UNIQUE
);
\echo 'Tabla Proveedores creada.'

-- Tabla: Productos
CREATE TABLE Productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    unidad_de_medida VARCHAR(50),
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 0,
    id_categoria INT NOT NULL,
    CONSTRAINT fk_categoria
        FOREIGN KEY(id_categoria)
        REFERENCES Categorias(id_categoria)
        ON DELETE RESTRICT -- O ON DELETE SET NULL, dependiendo de la lógica de negocio
);
CREATE INDEX idx_productos_id_categoria ON Productos(id_categoria);
\echo 'Tabla Productos creada e indexada.'

-- Tabla: Ventas
CREATE TABLE Ventas (
    id_venta SERIAL PRIMARY KEY,
    fecha TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Corregido: datetime a TIMESTAMP
    monto_total DECIMAL(10, 2) NOT NULL,
    id_trabajador INT NOT NULL,
    CONSTRAINT fk_trabajador_venta
        FOREIGN KEY(id_trabajador)
        REFERENCES Trabajadores(id_trabajador)
);
CREATE INDEX idx_ventas_id_trabajador ON Ventas(id_trabajador);
\echo 'Tabla Ventas creada e indexada.'

-- Tabla: Compras
CREATE TABLE Compras (
    id_compra SERIAL PRIMARY KEY,
    fecha TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Corregido: datetime a TIMESTAMP
    monto_total DECIMAL(10, 2) NOT NULL,
    id_proveedor INT NOT NULL,
    id_trabajador INT NOT NULL,
    CONSTRAINT fk_proveedor_compra
        FOREIGN KEY(id_proveedor)
        REFERENCES Proveedores(id_proveedor),
    CONSTRAINT fk_trabajador_compra
        FOREIGN KEY(id_trabajador)
        REFERENCES Trabajadores(id_trabajador)
);
CREATE INDEX idx_compras_id_proveedor ON Compras(id_proveedor);
CREATE INDEX idx_compras_id_trabajador ON Compras(id_trabajador);
\echo 'Tabla Compras creada e indexada.'

-- Tabla: Detalle_Ventas (Tabla de unión para Productos y Ventas)
CREATE TABLE Detalle_Ventas (
    id_detalle_venta SERIAL PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL, -- Precio al momento de la venta
    CONSTRAINT fk_venta_detalle
        FOREIGN KEY(id_venta)
        REFERENCES Ventas(id_venta)
        ON DELETE CASCADE, -- Si se elimina una venta, se eliminan sus detalles
    CONSTRAINT fk_producto_detalle_venta
        FOREIGN KEY(id_producto)
        REFERENCES Productos(id_producto)
        ON DELETE RESTRICT, -- No permitir eliminar un producto si está en detalles de venta
    CONSTRAINT uq_venta_producto UNIQUE (id_venta, id_producto) -- Para evitar duplicados del mismo producto en la misma venta
);
CREATE INDEX idx_detalle_ventas_id_venta ON Detalle_Ventas(id_venta);
CREATE INDEX idx_detalle_ventas_id_producto ON Detalle_Ventas(id_producto);
\echo 'Tabla Detalle_Ventas creada e indexada.'

-- Tabla: Detalle_Compras (Tabla de unión para Productos y Compras)
CREATE TABLE Detalle_Compras (
    id_detalle_compra SERIAL PRIMARY KEY,
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL, -- Precio al momento de la compra
    CONSTRAINT fk_compra_detalle
        FOREIGN KEY(id_compra)
        REFERENCES Compras(id_compra)
        ON DELETE CASCADE, -- Si se elimina una compra, se eliminan sus detalles
    CONSTRAINT fk_producto_detalle_compra
        FOREIGN KEY(id_producto)
        REFERENCES Productos(id_producto)
        ON DELETE RESTRICT, -- No permitir eliminar un producto si está en detalles de compra
    CONSTRAINT uq_compra_producto UNIQUE (id_compra, id_producto) -- Para evitar duplicados del mismo producto en la misma compra
);
CREATE INDEX idx_detalle_compras_id_compra ON Detalle_Compras(id_compra);
CREATE INDEX idx_detalle_compras_id_producto ON Detalle_Compras(id_producto);
\echo 'Tabla Detalle_Compras creada e indexada.'

\echo 'Esquema de tablas creado exitosamente.'
