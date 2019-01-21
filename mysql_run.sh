#!/bin/bash
set -eo pipefail
shopt -s nullglob

DATADIR=/var/lib/mysql/
#ISFIRSTTIME=false

startMySQLDaemon(){
#/usr/bin/mysqld_safe --datadir="$DATADIR" --user=mysql ;
cd '/usr' && mysqld --datadir="$DATADIR" --user=mysql &
}

startMySQL(){
#/usr/bin/mysqld_safe --datadir="$DATADIR" --user=mysql ;
cd '/usr' && mysqld --datadir="$DATADIR" --user=mysql;
}

stopMySQL(){
#mysqladmin -u root shutdown ;
killall mysqld ;
pkill mysqld ;
}

if [ ! -d "$DATADIR/mysql" ]; then
cd '/usr' && mysql_install_db --user=mysql --ldata=/var/lib/mysql/ --basedir=/usr ;
#cd '/usr' && mysql_upgrade;
fi

chown -R mysql:mysql "$DATADIR" ;
startMySQLDaemon ;

echo "MySQL server starting...."
query=$(cat <<-EOSQL
use mysql;
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOSQL
) ;
echo $query
cd '/usr' && mysql -uroot -e "$query";
stopMySQL ;
startMySQL ;