CREATE DATABASE polardb_catalog;
CREATE USER 'catalog_user'@'%' IDENTIFIED BY 'Y2F0YWxvZ191c2VyCg==';
CREATE USER 'order_user'@'%' IDENTIFIED BY 'b3JkZXJfdXNlcgo=';
GRANT CREATE on polardb_catalog.* TO 'catalog_user'@'%';
GRANT CREATE on polardb_catalog.* TO 'order_user'@'%';
GRANT ALL PRIVILEGES ON polardb_catalog.books, polardb_catalog.catalog__flyway_schema_history TO 'catalog_user'@'%';
GRANT ALL PRIVILEGES ON polardb_catalog.orders, polardb_catalog.order__flyway_schema_history TO 'order_user'@'%';
