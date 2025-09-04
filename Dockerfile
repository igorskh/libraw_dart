FROM debian:trixie-slim AS base

RUN apt update && apt install -y build-essential cmake git wget

RUN git clone https://github.com/LibRaw/LibRaw.git
WORKDIR /LibRaw
RUN git checkout 0.21.4

WORKDIR /
RUN git clone https://github.com/LibRaw/LibRaw-cmake.git
WORKDIR /LibRaw-cmake

RUN mkdir build && cd build
WORKDIR /LibRaw-cmake/build
RUN cmake -DBUILD_SHARED_LIBS=ON -DENABLE_OPENMP=OFF -DLIBRAW_PATH=/LibRaw ..
RUN make

FROM dart:3.9.2 AS runner

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

COPY --from=base /LibRaw-cmake/build/libraw.so.23.0.0 /app/bin/libraw.so

RUN dart pub get --offline
RUN dart analyze

CMD ["dart", "run", "bin/libraw_dart.dart"]