# arm32v7-mariadb-alpine

This [docker image](https://hub.docker.com/r/michaelkilian/arm32v7-mariadb-alpine) is based
on [Alpine Linux](https://alpinelinux.org/) to be as minimal as possible and was designed
for a raspberry pi 3.

## Why Alpine Linux?

Alpine Linux is built around musl libc and busybox.
This makes it smaller and more resource efficient than traditional GNU/Linux distributions.
A container requires no more than 8 MB and a minimal installation to disk requires around
130 MB of storage. Not only do you get a fully-fledged Linux environment but a large
selection of packages from the repository.

## Why MariaDB Server?

MariaDB Server is one of the most popular database servers in the world.
It’s made by the original developers of MySQL and guaranteed to stay open source.
Notable users include Wikipedia, WordPress.com and Google.

MariaDB turns data into structured information in a wide array of applications,
ranging from banking to websites. It is an enhanced, drop-in replacement for MySQL.
MariaDB is used because it is fast, scalable and robust, with a rich ecosystem of
storage engines, plugins and many other tools make it very versatile for a wide
variety of use cases.

MariaDB is developed as open source software and as a relational database it provides an
SQL interface for accessing data. The latest versions of MariaDB also include GIS and JSON features.

## Features

- Minimal size and layers
- Low memory usage
- Open Source replacement (MariaDB instead of MySQL)

## Environment Variables

Main environment variables of MariaDB.

**`MYSQL_DATABASE`**

> specify the name of the database


**`MYSQL_USER`**

> specify the User for the database

**`MYSQL_PASSWORD`**

> specify the User password for the database

**`MYSQL_ROOT_PASSWORD`**

> specify the root password for Mariadb

**``MYSQL_CHARSET``**

> default charset (utf8) for Mariadb

**``MYSQL_COLLATION``**

> default collation (utf8_general_ci) for Mariadb
>
> When setting charset, also make sure to choose a collation otherwise it will be the default.
>
> | Charset | Description | Default collation | max len |
> | --- | --- | --- | --- |
> big5 | Big5 Traditional Chinese | big5_chinese_ci | 2 |
> dec8 | DEC West European | dec8_swedish_ci | 1 |
> cp850 | DOS West European | cp850_general_ci | 1 |
> hp8 | HP West European | hp8_english_ci | 1 |
> koi8r | KOI8-R Relcom Russian | koi8r_gener 1al_ci | 1 |
> latin1 | cp1252 West European | latin1_swedish_ci | 1 |
> latin2 | ISO 8859-2 Central European | latin2_general_ci | 1 |
> swe7 | 7bit Swedish | swe7_swedish_ci | 1 |
> ascii | US ASCII | ascii_general_ci | 1 |
> ujis | EUC-JP Japanese | ujis_japanese_ci | 3 |
> sjis | Shift-JIS Japanese | sjis_japanese_ci | 2 |
> hebrew | ISO 8859-8 Hebrew | hebrew_general_ci | 1 |
> tis620 | TIS620 Thai | tis620_thai_ci | 1 |
> euckr | EUC-KR Korean | euckr_korean_ci | 2 |
> koi8u | KOI8-U Ukrainian | koi8u_general_ci | 1 |
> gb2312 | GB2312 Simplified Chinese | gb2312_chinese_ci | 2 |
> greek | ISO 8859-7 Greek | greek_general_ci | 1 |
> cp1250 | Windows Central European | cp1250_general_ci | 1 |
> gbk | GBK Simplified Chinese | gbk_chinese_ci | 2 |
> latin5 | ISO 8859-9 Turkis | latin5_turkish_ci | 1 |
> armscii8 | ARMSCII-8 Armenian | armscii8_general_ci | 1 |
> utf8 | UTF-8 Unicode | utf8_general_ci | 3 |
> ucs2 | UCS-2 Unicode | ucs2_general_ci | 2 |
> cp866 | DOS Russian | cp866_general_ci | 1 |
> keybcs2 | DOS Kamenicky Czech-Slovak | key 1bcs2_general_ci | |
> macce | Mac Central European | macce_general_ci | 1 |
> macroman | Mac West European | macroman_general_ci | 1 |
> cp852 | DOS Central European | cp852_general_ci | 1 |
> latin7 | ISO 8859-13 Baltic | latin7_general_ci | 1 |
> utf8mb4 | UTF-8 Unicode | utf8mb4_general_ci | 4 |
> cp1251 | Windows Cyrillic | cp1251_general_ci | 1 |
> utf16 | UTF-16 Unicode | utf16_general_ci | 4 |
> utf16le | UTF-16LE Unicode | utf16le_general_ci | 4 |
> cp1256 | Windows Arabic | cp1256_general_ci | 1 |
> cp1257 |  Windows Baltic | cp1257_general_ci | 1 |
> utf32 | UTF-32 Unicode | utf32_general_ci | 4 |
> binary | Binary pseudo charset | binary | 1 |
> geostd8 | GEOSTD8 Georgian | geostd8_general_ci | 1 |
> cp932 | SJIS for Windows Japanese | cp932_japanese_ci | 2 |
> eucjpms | UJIS for Windows Japanese | eucjpms_japanese_ci | 3 |

## Volumes

- `/var/lib/mysql` - Database files
- `/var/lib/mysql/mysql-bin` - MariaDB logs

## Commands

When a container is started for the first time, a new database with the specified name will be
created and initialized with the provided configuration variables. Furthermore, it will execute
files with extensions .sh, .sql and .sql.gz that are found in `/docker-entrypoint-initdb.d`.

- `--character-set-server=utf8mb4`
- `--collation-server=utf8mb4_unicode_ci`
- `--explicit-defaults-for-timestamp=1`

SQL files will be imported by default to the database specified by the `MYSQL_DATABASE` variable.

## Example

> Do **not** use this example in a production environment without changing the credentials!

```yaml
version: '3'

services:
  mysql:
    image: michaelkilian/arm32v7-mariadb-alpine
    restart: always
    command: ['--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci']
    environment:
      MYSQL_ROOT_PASSWORD: tbsp4RC9Pk5sRb5nQNXQDffL7nCTAJjr
      MYSQL_USER: someuser
      MYSQL_PASSWORD: AYUaFW5zhQvNzHHcv2q67gzfmMtvmpAD
      MYSQL_DATABASE: some-database
    ports:
      - '3306:3306'
    volumes:
      - ./mysql:/var/lib/mysql
```

## Credits

- To the people who wrote the run script.
