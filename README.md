# Ballerina Amazon EC2 Connector

The Amazon EC2 connector allows you to access the Amazon EC2 REST API through ballerina.
The following section provide you the details on connector operations.

## Compatibility
| Ballerina Language Version | Amazon EC2 API version  |
| -------------------------- | --------------------   |
| 0.983.0                    | 2016-11-15             |


The following sections provide you with information on how to use the Ballerina Amazon EC2 connector.

- [Contribute To Develop](#contribute-to-develop)
- [Working with Amazon EC2 Connector Actions](#Working-with-Amazon-EC2-Connector)
- [Sample](#sample)

### Contribute To develop

Clone the repository by running the following command 
```shell
git clone https://github.com/wso2-ballerina/module-amazonec2.git
```

### Working with Amazon EC2 Connector

First, import the `wso2/amazonec2` module into the Ballerina project.

```ballerina
import wso2/amazonec2;
```

In order for you to use the Amazon EC2 Connector, first you need to create a Amazon EC2 Client endpoint.

```ballerina
   endpoint amazonec2:Client amazonEC2Client {
        accessKeyId: "",
        secretAccessKey: "",
        region: "",
        clientConfig:{}
    };
```

##### Sample

```ballerina
import ballerina/io;
import wso2/amazonec2;

function main(string... args) {
    endpoint amazonec2:Client amazonEC2Client {
        accessKeyId: "",
        secretAccessKey: "",
        region: "",
        clientConfig:{}
    };

   var describeInstancesResponse = amazonEC2Client->describeInstances();
   match describeInstancesResponse {
         amazonec2:EC2Instance[] insts => {
             io:println(" Successfully describe the instances : ");
             io:println(insts);
         }
         amazonec2:AmazonEC2Error e => io:println(e);
   }
}
```