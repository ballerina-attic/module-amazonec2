# Ballerina Amazon ec2 Connector Test

The Amazon ec2 connector allows you to access the Amazon ec2 REST API through ballerina.

## Compatibility
| Ballerina Version | Amazon ec2 API Version |
|-------------------|----------------------  |
| 0.982.0           | 2016-11-15             |

###### Running tests

1. Create `ballerina.conf` file in `package-amazonec2`, with following keys and provide values for the variables.
    
    ```.conf
    ACCESS_KEY_ID=""
    SECRET_ACCESS_KEY=""
    REGION=""
    IMAGE_ID=""
    SOURCE_IMAGE_ID=""
    SOURCE_REGION=""
    ```
2. Navigate to the folder package-amazonec2

3. Run tests :

    ```ballerina
    ballerina init
    ballerina test amazonec2 --config ballerina.conf
    ```
```