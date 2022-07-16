CREATE DATABASE polardb_catalog;
CREATE USER catalog_user WITH PASSWORD 'Y2F0YWxvZ191c2VyCg==';
CREATE USER order_user WITH PASSWORD 'b3JkZXJfdXNlcgo=';
GRANT CREATE ON DATABASE polardb_catalog TO catalog_user;
GRANT CREATE ON DATABASE polardb_catalog TO order_user;
-- GRANT ALL ON TABLE books TO catalog_user;
-- GRANT ALL ON TABLE catalog_service_flyway_schema_history TO catalog_user;
-- GRANT ALL ON TABLE orders TO order_user;
-- GRANT ALL ON TABLE order_service_flyway_schema_history TO order_user;
