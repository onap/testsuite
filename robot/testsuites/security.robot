*** Settings ***
| Documentation | Security validation                                    |
| ...           | This suite requires declaring ${ACTUAL_NODEPORTS_FILE} |
| Default tags  | security                                               |
| Library       | Collections                                            |
| Library       | OperatingSystem                                        |

*** Variables ***
| ${EXPECTED_NODEPORTS_FILE} | ../assets/security/ExpectedNodePorts.json |

*** Test Cases ***
Validate present NodePorts
|   | ${expected_nodeports}=       | Load JSON file         | ${EXPECTED_NODEPORTS_FILE} |
|   | ${actual_nodeports}=         | Load JSON file         | ${ACTUAL_NODEPORTS_FILE}   |
|   | Dictionaries should be equal | ${expected_node_ports} | ${actual_node_ports}       |

*** Keywords ***
Load JSON file
|   | [Arguments] | ${file}  |                           |      |
|   | ${json}=    | Get file | ${file}                   |      |
|   | ${data}=    | Evaluate | json.loads('''${json}''') | json |
|   | [Return]    | ${data}  |                           |      |
