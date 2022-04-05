#!/bin/bash
#
# license: GPL V2.0
# version: 1.3.5
# script author: Koshuba V - stvixfree@gmail.com
# 2022
## only pgsql & mysql
#

## dependencies scripts
#<tools_script>
pkgdep=( "postgresql-client" "mariadb-client" "pigz" );	# packages
get_tools=( "pg_dump" "mysqldump" "pigz"  ); 		# tools for script
#</tools_script>

## only pgsql & mysql
## the array database name
DBDATA=( "dbname1" "dbname2" "dbname3" );
## the array backup paths
BACKPATH=( "/arhiv" "/arhiv" "/arhiv" );
## the array login for databases
LOGINDB=( "dblogin1" "dblogin2" "dblogin3" );
## the array pass for databases
PASSWDB=( "dbpass1" "dbpass2" "dbpass2" );
## the array type databases
TYPEDB=( "pgsql" "pgsql" "mysql" )
## the array hosts
HOSTDB=( "127.0.0.1" "127.0.0.1" "10.1.0.1" )
## log file
LOG_FILE="/var/log/syslog.log";
#
## email admin
adminmail="admindb@mydomen.ru";
#
MESS_OK="Резервное копирвание базы $DBNAME выполнено"; # Backup database $ DBNAME done
MESS_FAIL="Ошибка резервного копирования базы $DBNAME"; # Backup database $ DBNAME error
dbname="none";
#########################################################

#<Fn_get-tools>
function getTools() {

for ((itools=0; itools != ${#get_tools[@]}; itools++))
 do
checktool=$(whereis -b ${get_tools[$itools]}|awk '/^'${get_tools[$itools]}':/{print $2}')
if [[ $checktool = "" ]];
    then
        sudo apt install ${pkgdep[$itools]};
fi
checktool=$(whereis -b ${get_tools[$itools]}|awk '/^'${get_tools[$itools]}':/{print $2}')
if [[ $checktool != "" ]];
    then
        eval get_${get_tools[$itools]}=$(whereis -b ${get_tools[$itools]}|awk '/^'${get_tools[$itools]}':/{print $2}');
        list_tools[${#list_tools[@]}]="$(whereis -b ${get_tools[$itools]}|awk '/^'${get_tools[$itools]}':/{print $2}')";
    else
        echo "Sorry, there are no required packages to work, please install: ${pkgdep[@]}"
        exit 0;
fi
done
backDB;
}

function backDB() {
for ((dbinx=0; dbinx != ${#DBDATA[@]}; dbinx++))
    do
    rdate=$(date +%d-%m-%y_%H-%M);
    dbname=${DBDATA[$dbinx]};
    rpath=${BACKPATH[$dbinx]};
    dbtype=${TYPEDB[$dbinx]};
    dblogin=${LOGINDB[$dbinx]}
    dbpass=${PASSWDB[$dbinx]}
    dbhost=${HOSTDB[$dbinx]}
    cd $rpath;
    if [ "$dbtype" = "pgsql" ];
     then
        if [ ! -d $rpath/$dbname ];
            then
            mkdir -p $rpath/$dbname;
            fi
        if sudo PGPASSWORD=$dbpass pg_dump -C --host=$dbhost --username=$dblogin --dbname=$dbname > $rpath/$dbname/$dbname"_"$rdate.sql
            then
                tar -cJf $rpath/$dbname/$dbname"_"$rdate.tar.xz $rpath/$dbname/$dbname"_"$rdate.sql;
                rm $rpath/$dbname/$dbname"_"$rdate.sql;
                echo "$(date) -- backup pgbase $MESS_OK">>$LOG_FILE
                date|mailx -a "Content-Type: text/plain; charset=UTF-8" -s "$(date) -- backup pgbase $MESS_OK" $adminmail
        else
                echo "$(date) -- backup pgbase $MESS_FAIL">>$LOG_FILE
                date|mailx -a "Content-Type: text/plain; charset=UTF-8" -s "$(date) -- backup pgbase $MESS_FAIL" $adminmail
        fi
    fi
    if [ "$dbtype" = "mysql" ];
     then
        if [ ! -d $rpath/$dbname ];
            then
            mkdir -p $rpath/$dbname;
            fi
        if sudo mysqldump -v -h$dbhost -u$dblogin -p$dbpass $dbname > $rpath/$dbname/$dbname"_"$rdate.sql
            then
                tar -cJf $rpath/$dbname/$dbname"_"$rdate.tar.xz $rpath/$dbname/$dbname"_"$rdate.sql;
                rm $rpath/$dbname/$dbname"_"$rdate.sql;
                echo "$(date) -- backup mysqlbase $MESS_OK">>$LOG_FILE
                date|mailx -a "Content-Type: text/plain; charset=UTF-8" -s "$(date) -- backup mysqlbase $MESS_OK" $adminmail
            else
                echo "$(date) -- backup mysqlbase $MESS_FAIL">>$LOG_FILE
                date|mailx -a "Content-Type: text/plain; charset=UTF-8" -s "$(date) -- backup mysqlbase $MESS_FAIL" $adminmail
    fi  fi
    cd;
done
}

getTools;

exit 0
