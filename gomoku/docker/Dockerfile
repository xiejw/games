# vim: filetype=dockerfile
FROM xiejw/baseimage

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-pip python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install --upgrade \
    pip \
    setuptools

RUN pip3 install keras==2.3.1 tensorflow==1.14

RUN mkdir -p /workdir/cmd /workdir/.build

COPY cmd/play_with_human.py /workdir/cmd
COPY lib     /workdir/lib

COPY docker/run.sh /workdir

# Passed by `build` command line flag
ARG WEIGHT_FILE

COPY ${WEIGHT_FILE} /workdir/.build/weights.h5

WORKDIR /workdir

CMD ["bash", "run.sh"]
