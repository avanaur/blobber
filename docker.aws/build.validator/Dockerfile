ARG image_tag
FROM golang:1.11.4-alpine3.8 as validator_build

RUN apk add --update --no-cache build-base linux-headers git cmake bash perl grep

# Install Herumi's cryptography
RUN apk add gmp gmp-dev openssl-dev && \
    cd /tmp && \
    wget -O - https://github.com/herumi/mcl/archive/master.tar.gz | tar xz && \
    wget -O - https://github.com/herumi/bls/archive/master.tar.gz | tar xz && \
    mv mcl* mcl && \
    mv bls* bls && \
    make -C mcl -j $(nproc) lib/libmclbn256.so install && \
    cp mcl/lib/libmclbn256.so /usr/local/lib && \
    make -C bls -j $(nproc) install && \
    rm -R /tmp/mcl && \
    rm -R /tmp/bls

ENV SRC_DIR=/0chain
ENV GO111MODULE=on

# Download the dependencies:
# Will be cached if we don't change mod/sum files
COPY ./code/go/0chain.net/core/go.mod          ./code/go/0chain.net/core/go.sum          $SRC_DIR/go/0chain.net/core/
COPY ./code/go/0chain.net/validatorcore/go.mod     ./code/go/0chain.net/validatorcore/go.sum     $SRC_DIR/go/0chain.net/validatorcore/
COPY ./code/go/0chain.net/validator/go.mod     ./code/go/0chain.net/validator/go.sum     $SRC_DIR/go/0chain.net/validator/

WORKDIR $SRC_DIR/go/0chain.net/validator
RUN go mod download


#Add the source code
ADD ./code/go/0chain.net $SRC_DIR/go/0chain.net

ARG image_tag
ARG go_build_mode
ARG go_bls_tag
RUN go build -v -tags ${go_build_mode} -tags ${go_bls_tag} -ldflags "-X 0chain.net/core/build.BuildTag=${image_tag}"

# Copy the build artifact into a minimal runtime image:
FROM golang:1.11.4-alpine3.8
RUN apk add gmp gmp-dev openssl-dev
COPY --from=validator_build  /usr/local/lib/libmcl*.so \
                        /usr/local/lib/libbls*.so \
                        /usr/local/lib/
ENV APP_DIR=/0chain
WORKDIR $APP_DIR
COPY --from=validator_build $APP_DIR/go/0chain.net/validator/validator $APP_DIR/bin/validator

#Store all files and run environment under 0chain userid.
RUN addgroup -g 2000 -S 0chain && adduser -u 2000 -S 0chain -G 0chain
USER 0chain:0chain
