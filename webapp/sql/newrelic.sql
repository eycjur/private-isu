-- newrelicからアクセスするユーザーを作成
# Create 'newrelic' user
CREATE USER 'newrelic' IDENTIFIED BY 'newrelic';

# Grant replication client privileges
GRANT REPLICATION CLIENT ON *.* TO 'newrelic';

# Grant select privileges
GRANT SELECT ON *.* TO 'newrelic';
