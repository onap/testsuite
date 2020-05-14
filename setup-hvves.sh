#!/bin/bash

#
# Generate HV-VES SSL related certs.
# Copy the stuff to HV-VES and Robot pods.
#
NAMESPACE=${NAMESPACE:-onap}
DIR=${DIR:"/tmp"}

HVVESPOD=$(kubectl -n $NAMESPACE get pods --no-headers=true -o custom-columns=:metadata.name | grep hv-ves)


generate_ca_key_cert () {
openssl genrsa -out $1/ca.key 2048
openssl req -new -x509 -days 36500 -key $1/ca.key -out $1/ca.pem -subj /CN=dcae-hv-ves-ca.onap
}

generate_server_key_csr () {
openssl genrsa -out $1/server.key 2048
openssl req -new -key $1/server.key -out $1/server.csr -subj /CN=dcae-hv-ves-collector.onap
}

generate_client_key_csr () {
openssl genrsa -out $1/client.key 2048
openssl req -new -key $1/client.key -out $1/client.csr -subj /CN=dcae-hv-ves-client.onap
}

sign_server_and_client_cert () {
openssl x509 -req -days 36500 -in $1/server.csr -CA $1/ca.pem -CAkey $1/ca.key -out $1/server.pem -set_serial 00
openssl x509 -req -days 36500 -in $1/client.csr -CA $1/ca.pem -CAkey $1/ca.key -out $1/client.pem -set_serial 00
}

create_pkcs12_ca_and_server () {
openssl pkcs12 -export -out $1/ca.p12 -inkey $1/ca.key -in $1/ca.pem -passout pass:
openssl pkcs12 -export -out $1/server.p12 -inkey $1/server.key -in $1/server.pem -passout pass:
}

copy_server_certs_to_hvves () {
for f in {ca.p12,server.p12}
do
kubectl cp $1/$f $2/$3:$4
done
}

copy_client_certs_to_robot () {
for f in {ca.pem,client.key,client.pem}
do
kubectl cp $1/$f $2/$3:$4
done
}

cleanup () {
rm -f $1/{ca,server,client}.???
}


generate_ca_key_cert "$DIR"
generate_server_key_csr "$DIR"
generate_client_key_csr "$DIR"
sign_server_and_client_cert "$DIR"
create_pkcs12_ca_and_server "$DIR"
copy_server_certs_to_hvves "$DIR" "$NAMESPACE" "$HVVESPOD" "$DIR"
cleanup "$DIR"
