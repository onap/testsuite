*** Settings ***
| Documentation | Security validation                                    |
| ...           | This suite requires declaring ${ACTUAL_NODEPORTS_FILE} |
| Default tags  | security                                               |
| Library       | OperatingSystem                                        |
| Library       | ONAPLibrary.JSON                                       |

*** Variables ***
| ${EXPECTED_NODEPORTS_FILE} | ../assets/security/ExpectedNodePorts.json |

*** Test Cases ***
Validate present NodePorts
|   | ${expected_nodeports}=       | Get file               | ${EXPECTED_NODEPORTS_FILE} |
|   | ${actual_nodeports}=         | Get file               | ${ACTUAL_NODEPORTS_FILE}   |
|   | JSON should contain sub JSON | ${expected_node_ports} | ${actual_node_ports}       |
