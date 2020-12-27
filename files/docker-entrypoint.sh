#!/usr/bin/env sh

export CLR_RED_BOLD='\033[1;31m'
export CLR_GREEN_BOLD='\033[1;32m'
export CLR_YELLOW_BOLD='\033[1;33m'
export CLR_PURPLE_BOLD='\033[1;35m'
export CLR_CYAN_BOLD='\033[1;36m'
export CLR_RESET='\033[0m'

mysql_printf() {
  MYSQL_PRINTF_FORMAT=''

  case "${1}" in
    1)
      MYSQL_PRINTF_FORMAT="${CLR_CYAN_BOLD}INFO"
      ;;
    2)
      MYSQL_PRINTF_FORMAT="${CLR_GREEN_BOLD}NOTICE"
      ;;
    3)
      MYSQL_PRINTF_FORMAT="${CLR_YELLOW_BOLD}WARNING"
      ;;
    4)
      MYSQL_PRINTF_FORMAT="${CLR_RED_BOLD}ERROR"
      ;;
    *)
      mysql_printf 3 "first parameter has to be the message level (1-4)\n"
      return
      ;;
  esac

  printf -- "[${CLR_PURPLE_BOLD}arm32v7-mariadb-alpine${CLR_RESET}] [${MYSQL_PRINTF_FORMAT}${CLR_RESET}] ${2}" "${@:3}"

  unset MYSQL_PRINTF_FORMAT
}


for i in /scripts/pre-init.d/*sh
do
  if test -e "${i}"; then
    mysql_printf 2 "pre-init.d - processing %s\n" ${i}

    . "${i}"
  fi
done

if ! test -d "/run/mysqld"; then
  mysql_printf 1 "${CLR_YELLOW_BOLD}mysqld${CLR_RESET} not found, creating...\n"

  mkdir -p /run/mysqld
fi

# fix permissions always on startup
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if ! test -d "/var/lib/mysql/mysql"; then
  mysql_printf 1 "${CLR_YELLOW_BOLD}MySQL${CLR_RESET} data directory not found, creating...\n"

  mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

  if test -z "${MYSQL_ROOT_PASSWORD}"; then
    mysql_printf 3 "missing environment variable: ${CLR_RED_BOLD}MYSQL_ROOT_PASSWORD${CLR_RESET}\n"
    mysql_printf 2 "creating initial root password...\n"

    MYSQL_ROOT_PASSWORD=`pwgen 16 1`


    mysql_printf 1 "created root password: ${CLR_RED_BOLD}${MYSQL_ROOT_PASSWORD}${CLR_RESET}\n"
  fi

  MYSQL_DATABASE=${MYSQL_DATABASE:-""}
  MYSQL_USER=${MYSQL_USER:-""}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

  tfile=`mktemp`
  if ! test -f "${tfile}"; then
    mysql_printf 4 "failed to create file via ${CLR_RED_BOLD}mktemp${CLR_RESET}\n"
  fi

  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

  if ! test -z "${MYSQL_DATABASE}"; then
    if [[ -z "${MYSQL_CHARSET}" || -z "${MYSQL_COLLATION}" ]]; then
      mysql_printf 1 "using default values for ${CLR_CYAN_BOLD}MYSQL_CHARSET${CLR_RESET} and ${CLR_CYAN_BOLD}MYSQL_COLLATION${CLR_RESET}\n"

      MYSQL_CHARSET='utf8'
      MYSQL_COLLATION='utf8_general_ci'
    fi

    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET ${MYSQL_CHARSET} COLLATE ${MYSQL_COLLATION};" >> $tfile
  fi

  if ! test -z "${MYSQL_USER}"; then
    if test -z "${MYSQL_PASSWORD}"; then
      mysql_printf 3 "missing environment variable: ${CLR_RED_BOLD}MYSQL_PASSWORD${CLR_RESET}\n"
      mysql_printf 2 "creating initial password for user ${MYSQL_USER}...\n"

      MYSQL_PASSWORD=`pwgen 16 1`


      mysql_printf 1 "created password for ${MYSQL_USER}: ${CLR_RED_BOLD}${MYSQL_PASSWORD}${CLR_RESET}\n"
    fi

    mysql_printf 2 "creating user ${CLR_YELLOW_BOLD}${MYSQL_USER}${CLR_RESET} with password ${CLR_YELLOW_BOLD}${MYSQL_PASSWORD}${CLR_RESET}\n"

    echo "GRANT ALL ON \`$MYSQL_DATABASE\` . * to '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" >> $tfile
    echo "GRANT ALL ON \`$MYSQL_DATABASE\` . * to '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" >> $tfile
    echo "SET PASSWORD FOR '${MYSQL_USER}'@'localhost'=PASSWORD('${MYSQL_PASSWORD}');"
    echo "FLUSH PRIVILEGES;" >> $tfile
  fi

  /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
  rm -f $tfile

  for f in /docker-entrypoint-initdb.d/*;
  do
    case "${f}" in
      *.sql)
        mysql_printf 2 "running ${f}\n"
        /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "${f}";
        ;;
      *.sql.gz)
        mysql_printf 2 "running ${f}\n"
        gunzip -c "${f}" | /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "${f}"
        ;;
      *)
        mysql_printf 2 "ignoring or emptry entrypoint init db: ${f}\n"
        ;;
    esac
  done

  printf -- "\n\n"
  mysql_printf 2 "${CLR_PURPLE_BOLD}MySQL${CLR_RESET} init process done. Ready for startup!\n\n"

fi

for i in /scripts/pre-exec.d/*sh
do
  if test -e "${i}"; then
    mysql_printf 2 "pre-exec.d - processing %s\n" ${i}

    . ${i}
  fi
done

exec /usr/bin/mysqld --user=mysql --console --skip-name-resolve --skip-networking=0 $@
