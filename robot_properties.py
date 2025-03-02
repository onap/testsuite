# The robot tests require a global variables file that
# contains environment specific values like service names and credentials.
# You'll find the real values in the OOM robot chart.
# When executed locally, these values are different and need to be adjusted
# to the environment they are running in.
GLOBAL_INJECTED_SO_BPMN_IP_ADDR = '127.0.0.1'
GLOBAL_AAI_SERVER_PROTOCOL = 'http'
GLOBAL_INJECTED_AAI_IP_ADDR = 'aai.onap'
GLOBAL_AAI_SERVER_PORT = '80'
GLOBAL_AAI_AUTHENTICATION = ('AAI','AAI')
GLOBAL_SDC_SERVER_PROTOCOL = 'http'
GLOBAL_DCAE_HVVES_SERVER_NAME= 'dcae-ves-collector.onap'
GLOBAL_DCAE_HVVES_SERVER_PORT= '8080'
GLOBAL_KAFKA_BOOTSTRAP_SERVICE= 'onap-strimzi-kafka-bootstrap.onap'
GLOBAL_KAFKA_USER= 'strimzi-kafka-admin'
