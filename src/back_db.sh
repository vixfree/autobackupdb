#!/bin/bash
## only pgsql & mysql
## the array database name
DBDATA=( "base1" "base2" );
## the array backup paths
BACKPATH=( "/backup/db" "/backup/db" );
## the array login for databases
LOGINDB=( "dblogin1" "dblogin2" );
## the array pass for databases
PASSWDB=( "mypassdb1" "mypassdb2" );
## the array type databases
TYPEDB=( "pgsql" "mysql" )
## log file
LOG_FILE="/var/log/syslog.log";
## messages
MESS_OK="Резервное копирвание базы $DBNAME выполнено"; # Backup database $ DBNAME done
MESS_FAIL="Ошибка резервного копирования базы $DBNAME"; # Backup database $ DBNAME error
## intermediate values
dbname="none";
#########################################################
function backDB() {
for ((dbinx=0; dbinx != ${#DBDATA[@]}; dbinx++))
    do
    rdate=$(date +%d%m%y);
    dbname=${DBDATA[$dbinx]};
    rpath=${BACKPATH[$dbinx]};
    dbtype=${TYPEDB[$dbinx]};
    dblogin=${LOGINDB[$dbinx]}
    dbpass=${PASSWDB[$dbinx]}
    if [ "$dbtype" = "pgsql" ];
     then
	sudo -u postgres pg_dump -C $dbname > $rpath/$dbname"_"$rdate.sql
	tar -cJf $rpath/$dbname"_"$rdate.tar.xz $rpath/$dbname"_"$rdate.sql;
	rm $rpath/$dbname"_"$rdate.sql;
	echo "$(date) -- backup pgbase $MESS_OK">>$LOG_FILE
    fi
    if [ "$dbtype" = "mysql" ];
     then
	mysqldump -u $dblogin -p$dbpass $dbname| gzip > $rpath/$dbname"_"$rdate.sql.gz
	echo "$(date) -- backup mysqlbase $MESS_OK">>$LOG_FILE
    fi
done
}

if [ ! -d $BACKPATH ];
     then
	mkdir -p $BACKPATH;
fi

backDB;

exit 0
