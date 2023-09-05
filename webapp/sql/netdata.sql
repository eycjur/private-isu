-- netdataからアクセスするユーザーを作成
CREATE USER 'netdata'@'%';
GRANT USAGE, REPLICATION CLIENT, PROCESS ON *.* TO 'netdata'@'%';
FLUSH PRIVILEGES;
