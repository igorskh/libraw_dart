FROM dart:stable AS build

RUN apt-get update && apt-get install -y libraw-bin=0.21.4-2

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN cp /usr/lib/x86_64-linux-gnu/libraw.so.23 /app/bin/libraw.so

RUN dart pub get --offline
RUN dart analyze

CMD ["dart", "run", "bin/libraw_dart.dart"]