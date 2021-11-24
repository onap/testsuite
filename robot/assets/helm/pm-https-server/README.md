# PM HTTPS Server

# How to deploy on lab

1. Copy files from helm/pm-https-server to lab
 
     `scp -i <path to key file .pem> -r <path to>/pm-https-server ubuntu@<RKE_NODE_IP>:<remote path to>/pm-https-server `
2. Log into the RKE

3. Install chart on your lab
    
    `helm install pm-https-server ./pm-https-server`
 
# Checking if everything is working properly

1. Find service on which your application runs

    `kubectl get service | grep pm-https-server`
    
2. If service is running try to connect to server

    `curl -u demo:demo123456! <http://WORKER_IP:PM_HTTPS_SERVER_PORT>`
    
    if everything is working properly you should get response like below
    
    `<html><body><h1>It works!</h1></body></html>`
    
3. If step 2 ends with success try to upload file
    
    `curl -F "uploaded_file=@./resources/E_VES_bulkPM_IF_3GPP_3_example_1.xml.gz" -u demo:demo123456! http://WORKER_IP:PM_HTTPS_SERVER_PORT/upload.php`  
    
    When file will be successfully uploaded you should see information like this:
    
     `The file E_VES_bulkPM_IF_3GPP_3_example_1.xml.gz has been uploaded`  