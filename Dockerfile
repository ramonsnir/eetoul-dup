FROM trenpixster/elixir:1.1.1
RUN apt-get update
RUN apt-get install -y cmake python zlib1g-dev
WORKDIR /opt
ADD install_libgit2.sh /opt/
RUN bash install_libgit2.sh
ADD test_eetoul.sh /opt/
CMD bash test_eetoul.sh