*** Settings ***
Documentation	  The main interface for interacting with MUSIC. It handles low level stuff like managing the http request library and MUSIC required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities

*** Variables ***
${MUSIC_HEALTH_CHECK_PATH}        /MUSIC/rest/v2/version
${MUSIC_CASSA_HEALTH_CHECK_PATH}        /MUSIC/rest/v2/service/musicHealthCheck
${MUSIC_ENDPOINT}     ${GLOBAL_MUSIC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MUSIC_IP_ADDR}:${GLOBAL_MUSIC_SERVER_PORT}
