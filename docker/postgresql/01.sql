CREATE DATABASE polardb_catalog;
CREATE USER catalog_user WITH ENCRYPTED PASSWORD 'TXlzcWwzMjFDYXRhbG9n';
CREATE USER order_user WITH ENCRYPTED PASSWORD 'TXlzcWwzMjFPcmRlcg==';
GRANT ALL PRIVILEGES ON DATABASE polardb_catalog TO catalog_user;
GRANT ALL PRIVILEGES ON DATABASE polardb_catalog TO order_user;
GRANT ALL PRIVILEGES ON polardb_catalog.books TO catalog_user;
GRANT ALL PRIVILEGES ON polardb_catalog.catalog_service_flyway_schema_history TO catalog_user;
GRANT ALL PRIVILEGES ON polardb_catalog.orders TO order_user;
GRANT ALL PRIVILEGES ON polardb_catalog.order_service_flyway_schema_history TO order_user;