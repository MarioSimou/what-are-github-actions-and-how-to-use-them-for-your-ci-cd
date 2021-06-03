FROM golang:alpine3.12 AS build

WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o /go/bin/hello ./cmd/hello/main.go

FROM gcr.io/distroless/base
COPY --from=build /go/bin/hello /go/bin/hello

EXPOSE 8080
CMD ["/go/bin/hello"]
