FROM debian:latest
RUN apt-get -y update && apt-get -y install lua5.1 lua-socket lua-sec
ADD test.lua /home/user/bin/test.lua
CMD ["lua", "/home/user/bin/test.lua"]
