FROM nginx:1.24

# TimeZoneをAsia/Tokyoに設定する
ENV TZ Asia/Tokyo
RUN echo "${TZ}" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata