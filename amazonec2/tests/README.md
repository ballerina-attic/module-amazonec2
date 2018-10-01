# Ballerina Amazon EC2 Connector Test

The Amazon EC2 connector allows you to access the Amazon EC2 REST API through ballerina.

## Compatibility
| Ballerina Version | Amazon EC2 API Version |
|-------------------|----------------------  |
| 0.982.0           | 2016-11-15             |

###### Running tests

1. Create `ballerina.conf` file in `package-amazonec2`, with following keys and provide values for the variables.
    
    ```.conf
    ACCESS_KEY_ID="<your_access_key_id>"
    SECRET_ACCESS_KEY="<your_secret_access_key_id>"
    REGION="<your_current_region>"
    IMAGE_ID="<The ID of the AMI, which is required to launch an instance>"
    SOURCE_IMAGE_ID="<The ID of the AMI to copy>"
    SOURCE_REGION="<The name of the region that contains the AMI to copy>"
    ```
2. Navigate to the folder package-amazonec2

3. Run tests :

    ```ballerina
    ballerina init
    ballerina test amazonec2 --config ballerina.conf
    ```
```