# Stage 1: Build static musl dependencies and FFmpeg
FROM alpine:3.20 AS builder

RUN apk add --no-cache \
    build-base \
    nasm \
    yasm \
    git \
    pkgconf \
    cmake \
    coreutils

# 1. Compile static x264
RUN git clone --depth 1 --branch stable https://code.videolan.org/videolan/x264.git /src/x264 \
    && cd /src/x264 \
    && ./configure \
        --prefix=/usr/local \
        --enable-static \
        --enable-pic \
        --disable-cli \
        --disable-shared \
    && make -j$(nproc) \
    && make install

# 2. Clone and compile FFmpeg release
# Flag pangkas --disable-everything: hanya aktifkan codec & filter yang dipakai Vidme
ENV FFMPEG_VERSION=7.1

RUN git clone --depth 1 --branch n${FFMPEG_VERSION} https://github.com/FFmpeg/FFmpeg.git /src/ffmpeg \
    && cd /src/ffmpeg \
    && ./configure \
        --prefix=/usr/local \
        --pkg-config-flags="--static" \
        --extra-cflags="-Os -fdata-sections -ffunction-sections" \
        --extra-ldflags="-static -Wl,--gc-sections" \
        --disable-everything \
        --disable-doc \
        --disable-htmlpages \
        --disable-manpages \
        --disable-podpages \
        --disable-txtpages \
        --disable-network \
        --disable-autodetect \
        --disable-ffplay \
        --enable-ffmpeg \
        --enable-ffprobe \
        --enable-protocol=file,pipe \
        --enable-demuxer=mov,mp4,m4a,3gp,3g2,mj2,matroska,webm,image2,concat \
        --enable-muxer=mp4,webm,matroska,image2 \
        --enable-decoder=h264,hevc,aac,mjpeg \
        --enable-encoder=libx264,mjpeg \
        --enable-gpl \
        --enable-libx264 \
        --enable-parser=h264,hevc,aac,mjpeg \
        --enable-filter=scale,crop,split,select,xstack,fps,format,setsar,setpts,concat \
    && make -j$(nproc) \
    && make install \
    && strip -s /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Stage 2: Minimal image containing only static binaries
FROM scratch

COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=builder /usr/local/bin/ffprobe /usr/local/bin/ffprobe

ENTRYPOINT ["/usr/local/bin/ffmpeg"]
