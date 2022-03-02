# Ves-client

# How to deploy on lab

1. Copy files from helm/ves-client to lab
 
     `scp -i <path to key file .pem> -r <path to>/ves-client ubuntu@<RKE_NODE_IP>:<remote path to>/ves-client  `
2. Log into the RKE

3. Update helm dependencies
    
    `cd ./ves-client`
    `helm dependency update`

4. Install chart on your lab
    
    `helm install ves-client ./ves-client -f oom/kubernetes/registry.yaml`
    
# How to use ves-client
    
<https://gerrit.onap.org/r/gitweb?p=integration/simulators/nf-simulator/ves-client.git;a=blob_plain;f=README.md;hb=HEAD>
    
 