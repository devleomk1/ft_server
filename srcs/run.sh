# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    run.sh                                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jisokang <jisokang@student.42seoul.kr>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/05/04 14:40:21 by jisokang          #+#    #+#              #
#    Updated: 2021/05/08 16:46:55 by jisokang         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
# '#!'는 스크립트를 실행할 쉘을 지정하는 선언문이다.(주석 아님) /bin/bash로 실행하라는 뜻.

openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Gon/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt
# openssl은 Nginx등과 같은 웹서버에 HTTPS를 적용하기 위한 테스트용 SSL 인증서를 생성할 때 사용하는 프로그램이다.
# 	* rsa:4096  : SSL/TLS에 가장 많이 사용하는 공개키 알고리즘. 뒤의 숫자는 키 비트수
# 	* -days 365 : 인증서 유효기간
# 	* -nodes	: no des 개인키를 비밀번호로 보호하고 싶지 않을 때, 이 옵션을 생략하면 매번 비밀번호를 입력해야함.
# 	* -x509		: 이 옵션을 사용하면 인증서명요청 대신 Self Signed 인증서를 생성한다.
# 	* -subj ""	: 인증서 안에 들어갈 정보를 명시.
# 	* -keyout (~.key) : [개인키 이름]
# 	* -out (~.crt)	  : [인증서 이름]

# 전자서명인증관리체계 DN(고유 이름) 규격
# 	* CN(Common name)		: 가입자의 이름
# 	* C(Country name)		: 가입자가 속한 국가명, 반드시 ISO표준 2글자로 표현해야함
# 	* L(Locality name)		: 가입자가 속한 지역명
# 	* S(State name)			: 가입자가 속한 도시나 도명
# 	* O(Organization name)	: 가입자가 속한 조직명
# 	* OU(Organization Unit Name) : 가입자가 속한 하위 조직명

mv localhost.dev.crt etc/ssl/certs/
mv localhost.dev.key etc/ssl/private/

chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key
# chmod 600 : 소유자(User)만 읽고 쓰기 가능
# [u] [g] [o]
# rw- --- ---

cp -rp /tmp/default /etc/nginx/sites-available/
#copy replace

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz
tar -xvf phpMyAdmin-5.0.2-all-languages.tar.gz
# tar [OPTION...] [FILE]
# -x : tar 아카이브에서 파일 추출. (파일 풀 때 사용)
# -v : 처리되는 과정(파일 정보)을 자세하게 나열.
# -f : 대상 tar 아카이브 지정. (기본 옵션)
# tar -xvf : tar아카이브를 현재 디렉토리에 풀기
# https://recipes4dev.tistory.com/146
mv phpMyAdmin-5.0.2-all-languages phpmyadmin
mv phpmyadmin /var/www/html/
cp -rp /tmp/config.inc.php /var/www/html/phpmyadmin/

service mysql start
# mariaDB와 MySQL의 차이
# MariaDB의 실행 프로그램들과 유틸리티는 모두 MySQL과 이름이 동일하며, 호환된다.
# https://sir.kr/cm_free/1489073
mysql < var/www/html/phpmyadmin/sql/create_tables.sql -u root --skip-password
#''가 복사하면 다른 문자로 들어가니 주의!
echo "CREATE DATABASE IF NOT EXISTS wordpress;" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON *.* TO 'jisokang'@'localhost' IDENTIFIED BY '1234' WITH GRANT OPTION" | mysql -u root --skip-password
# MySQL 명령어
# DB에 사용자 및 권한 추가
# GRANT(수여하다)
# PRIVILEGES (특권)
# GRANT [권한종류] ON [대상DB] TO [계정명] IDENTIFIED BY [DB암호] [WITH GRANT OPTION];
# https://extbrain.tistory.com/44
# --------------------------------------------
# "FLUSH PRIVILEGES"를 하지 않아도 되는 이유!
# 위 명령어는 Grant 테이블을 reload함으로 변경사항을 바로 적용하는 명령어인데,
# INSERT, UPDATE와 같은 SQL문이 아닌 grant 명령어를 사용해서 사용자를 추가하거나 권한등을 변경하였다면 굳이 실행할 필요가 없습니다.
# http://www.webmadang.net/database/database.do?action=read&boardid=4003&page=1&seq=23


wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
mv wordpress/ /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress
# chown [-R] [user][:group] target
# 파일 소유권 변경(change owner)
# 서버에서 웹서비스를 구동할때 그 웹사이트를 구동하는 Owner(소유주)는 서버계정의 소유주가 아니라 Apache나 PHP의 www-data가 된다.
cp -rp /tmp/wp-config.php /var/www/html/wordpress

service nginx start
service php7.3-fpm start
service mysql restart

bash
