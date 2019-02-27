# backupdb


-----


* Скрипт на языке bash, для автоматизированных backup баз данных.
* Поддерживаются базы: postgresql, mysql

Праметры скрипта которые необходимо корректировать.
Формат должен быть такой же.

-----
```
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
```
