GRANT ALL PRIVILEGES ON *. * TO 'root'@'%' WITH GRANT OPTION;
CREATE USER 'catalog_user'@'%' IDENTIFIED BY 'TXlzcWwzMjFDYXRhbG9n';
CREATE USER 'order_user'@'%' IDENTIFIED BY 'TXlzcWwzMjFPcmRlcg==';
GRANT CREATE ON polardb_catalog.* TO 'catalog_user'@'%' WITH GRANT OPTION;
GRANT CREATE ON polardb_catalog.* TO 'order_user'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON polardb_catalog.books TO 'catalog_user'@'%'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON polardb_catalog.catalog_service_flyway_schema_history TO 'catalog_user'@'%'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON polardb_catalog.orders TO 'order_user'@'%'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON polardb_catalog.order_service_flyway_schema_history TO 'order_user'@'%' WITH GRANT OPTION;