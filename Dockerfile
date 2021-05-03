# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jisokang <jisokang@student.42seoul.kr>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/04/28 22:15:41 by jisokang          #+#    #+#              #
#    Updated: 2021/05/03 22:17:52 by jisokang         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM	debian:buster
# 프로젝트를 시작할 베이스 image 를 지정한다.
# 우리 과제에서는 `debian:buster`로 설정.

LABEL	maintainer="jisokang <jisokang@student.42seoul.kr>"
# LABEL 명령은 이미지의 버전 정보, 작성자, 코멘트와 같이 이미지 상세 정보를 작성해두기 위한 명령 입니다.
# https://nirsa.tistory.com/70
# maintainer = Docker image를 생성한 사람/기관

RUN		apt-get update && apt-get -y upgrade && apt-get -y install \
		nginx \
		vim \
		openssl \
		php7.3-fpm \
		mariadb-server \
		php-mysql \
		wget

COPY	./src/run.sh ./

# COPY [src] [dst]
# src를 dst로 복사

EXPOSE	80 443
# 이 컨테이너가 해당 포트를 사용할 예정임을 사용자에게 알려준다.
# 실제로 포트를 열기 위해서는 run 명령어에서 -p 옵션을 사용해야한다.

CMD		bash run.sh
# 생성된 컨테이너를 실행할 명령어를 지정한다.
