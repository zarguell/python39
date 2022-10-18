######################## Base Args ########################
ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=zarguell/ubi8
ARG BASE_TAG=latest

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as build

# ARG BASE_REGISTRY=registry1.dso.mil
# ARG BASE_IMAGE=ironbank/redhat/ubi/ubi8
# ARG BASE_TAG=8.6

RUN dnf upgrade -y --nodocs && \
    dnf install -y --nodocs \
       bzip2-devel \
       expat-devel \
       gcc \
       libffi-devel \
       libuuid-devel \
       make \
       openssl-devel \
       sqlite-devel \
       xz-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

COPY python.tar.gz /

RUN mkdir -p /usr/local/src/python && \
    tar -zxf python.tar.gz -C /usr/local/src/python --strip-components=1 && \
    cd /usr/local/src/python && \
    ./configure \
      --enable-loadable-sqlite-extensions \
      --enable-optimizations \
      --enable-option-checking=fatal \
      --enable-shared \
      --with-system-expat \
      --with-ensurepip && \
    make && \
    make altinstall

RUN find /usr/local -depth \
	\( \
		\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
		-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
	\) -exec rm -rf '{}' + && \
    echo '/usr/local/lib' > /etc/ld.so.conf && \
    ldconfig

COPY requirements.txt . 

RUN pip3.9 install -r requirements.txt 

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

RUN dnf update -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

ENV PATH /home/python/.local/bin:$PATH

COPY --from=build /usr/local/include/python3.9 /usr/local/include/python3.9
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/bin /usr/local/bin

RUN cd /usr/local/bin && \
    ln -s idle3.9 idle3 && \
    ln -s idle3 idle && \
    ln -s pydoc3.9 pydoc3 && \
    ln -s pydoc3 pydoc && \
    ln -s python3.9 python3 && \
    ln -s python3 python && \
    ln -s python3.9-config python3-config && \
    ln -s python3-config python-config && \
    ln -s easy_install-3.9 easy_install-3 && \
    ln -s easy_install-3 easy_install && \
    ln -s 2to3-3.9 2to3-3 && \
    ln -s 2to3-3 2to3 && \
    ln -s pip3.9 pip3 || true && \
    ln -s pip3 pip || true && \
    echo '/usr/local/lib' > /etc/ld.so.conf && \
    ldconfig

RUN groupadd -g 1001 python && \
    useradd -r -u 1001 -m -s /sbin/nologin -g python python

USER 1001

CMD ["python3"]

HEALTHCHECK NONE
