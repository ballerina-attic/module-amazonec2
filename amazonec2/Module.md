Connects to Amazon EC2 from Ballerina.

# Module Overview

The Amazon EC2 connector allows you to work with EC2 instances, security group, Image and Volume operations through the Amazon EC2 REST API.

**Instance Operations**

The `wso2/amazonec2` module contains operations that work with instances. You can launch, describe, and terminate the
instances with these operations.

**Security Group Operations**

The `wso2/amazonec2` module contains operations that work with security groups. You can create and delete the
security groups with these operations.

**Volume Operations**

The `wso2/amazonec2` module contains operations that work with Volume. You can create, attach and detach the
volume with these operations.

**Image Operations**

The `wso2/amazonec2` module contains operations that work with Amazon EC2 AMIs. You can create, describe, deRegister and copy the
AMIs with these operations.

## Compatibility
|                    |    Version     |
|:------------------:|:--------------:|
| Ballerina Language |   0.990.0      |
| Amazon EC2 API     |   2016-11-15   |

## Sample

First, import the `wso2/amazonec2` module into the Ballerina project.

```ballerina
import wso2/amazonec2;
```
The Amazon EC2 connector can be instantiated using the accessKeyId, secretAccessKey and region,
in the Amazon EC2 client config.

**Obtaining Access Keys to Run the Sample**

 1. Create a amazon account by visiting <https://aws.amazon.com/ec2/>
 2. Obtain the following parameters
   * Access key ID.
   * Secret access key.
   * Desired Server region.

You can now enter the credentials in the Amazon EC2 client config:
```ballerina
amazonec2:AmazonEC2Configuration amazonec2Config = {
    accessKeyId: "",
    secretAccessKey: "",
    region: "",
    clientConfig:{}
};

amazonec2:Client amazonEC2Client = new(amazonec2Config);
```
The `runInstances` function launches the specified number of instances using an AMI for which you have permissions.
You can specify the maximum number of instances to launch and the minimum number of instances to launch.

   `var runInstancesResponse = amazonEC2Client->runInstances(imgId, maxCount, minCount);`

If the instance started successfully, the response from the `runInstances` function is a `EC2Instance` array with
one or more launched instance ids. If it is unsuccessful, the response is a `error`.

```ballerina
if (newInstances is error) {
    test:assertFail(msg = < string > insts.detail().message);
} else {
    io:println("Successfully run the instance : ");
    io:println(newInstances);
    arr = newInstances;
}
```

The `describeInstances` function describes one or more of your instances. It returns a `EC2Instance` array
with reservation ids if it is successful or the response is a `error`.

```ballerina
if (describeInstances is error) {
    test:assertFail(msg = < string > describeInstances.detail().message);
} else {
    io:println("Successfully describe the instance : ");
    io:println(describeInstances);
}
```
The `terminateInstances` function shuts down one or more instances. It returns a `EC2Instance` array
with terminated instance ids if it is successful or the response is a `error`.

```ballerina
if (terminated is error) {
    test:assertFail(msg = < string > terminated.detail().message);
} else {
    io:println(" Successfully terminate the instance : ");
    io:println(terminated);
    string instanceId = (terminated[0].id);
    test:assertNotEquals(instanceId, null, msg = "Failed to terminate the instances");
}
```

The `createImage` function will create an image. It returns a `Image` object
with created image id if it is successful or the response is a `error`.

```ballerina
if (newImage is amazonec2:Image) {
    io:println(" Successfully create a new image : ");
    id = newImage.imageId;
    io:println(newImage);
} else {
    test:assertFail(msg = <string>newImage.detail().message);
}
```

The `describeImages` function will describe the images . It returns an `Image` array
with image details if it is successful or the response is a `error`.

```ballerina
if (describeInstances is error) {
    test:assertFail(msg = < string > describeInstances.detail().message);
} else {
     io:println("Successfully describe the instance : ");
     io:println(describeInstances);
}
```

The `describeImageAttribute` function will describe an image with specified attributes . It returns an `ImageAttribute` response based on the attribute name if it is successful or the response is a `error`.

```ballerina
if (imageAttributeResponse is amazonec2:ImageAttribute) {
    io:println(" Successfully describes an image with an attribute : ");
    io:println(imageAttributeResponse);
} else {
    test:assertFail(msg = <string>imageAttributeResponse.detail().message);
}
```

The `deRegisterImage` function will deregisters the specified AMI.
After you deregister an AMI, it can't be used to launch new instances;
however,it doesn't affect any instances that you've already launched from the AMI.
It returns true as a service response if it is successful or the response is a `error`.

```ballerina
if (deRegisterImage is amazonec2:EC2ServiceResponse) {
    io:println(" Successfully de register the image : ");
    io:println(deRegisterImage);
} else {
    test:assertFail(msg = <string>deRegisterImage.detail().message);
}

```
The `copyImage` function will Initiates the copy of an AMI from the specified source region to the current region.
 It returns an `Image` object with copied image details if it is successful or the response is a `error`.

```ballerina
if (copyImage is amazonec2:Image) {
    io:println(" Successfully copy the image to the current region : ");
    io:println(copyImage);
} else {
    test:assertFail(msg = <string>copyImage.detail().message);
}
```
The `createVolume` creates an EBS volume that can be attached to an instance in the same Availability Zone.
 It returns `Volume` object with created volume details if it is successful or the response is a `error`.

```ballerina
if (newVolume is amazonec2:Volume) {
    io:println(" Successfully create a new volume : ");
    volumeId = newVolume.volumeId;
    io:println(newVolume);
} else {
    test:assertFail(msg = <string>newVolume.detail().message);
}
```

The `attachVolume` attaches an EBS volume to a running or stopped instance and exposes it to the instance with the specified device name.
 It returns an `AttachmentInfo` object with attachment details if it is successful or the response is a `error`.

```ballerina
if (attachmentInfo is amazonec2:AttachmentInfo ) {
    io:println(" Successfully attaches volume : ");
    io:println(attachmentInfo);
} else {
    test:assertFail(msg = <string>attachmentInfo.detail().message);
}
```
The `detachVolume` detaches an EBS volume from an instance.
 It returns an `AttachmentInfo` object with specified details if it is successful or the response is a `error`.

```ballerina
if (detachmentInfo is amazonec2:AttachmentInfo) {
    io:println(" Successfully detach the volume : ");
    io:println(detachmentInfo);
}else {
    test:assertFail(msg = <string>detachmentInfo.detail().message);
}
```

The `createSecurityGroup` creates a security group.
It returns `SecurityGroup` object with group id if it is successful or the response is a `error`.

```ballerina
if (securityGroup is amazonec2:SecurityGroup) {
    io:println(" Successfully create a new security group : ");
    io:println(securityGroup);
    testGroupId = securityGroup.groupId;
} else {
     test:assertFail(msg = <string>securityGroup.detail().message);
}

```

The `deleteSecurityGroup` deletes a security group. Can specify either the security group name or the security group ID.
But group id is required for a non default VPC.
It returns an true as an service response if it is successful or the response is a `error`.

```ballerina
if (deleteSecurityGroupResponse is amazonec2:EC2ServiceResponse) {
    io:println(" Successfully  delete the security group : ");
    io:println(deleteSecurityGroupResponse);
} else {
    test:assertFail(msg = <string>deleteSecurityGroupResponse.detail().message);
}
```
## Example 1
```ballerina
import ballerina/io;
import wso2/amazonec2;
import ballerina/runtime;

amazonec2:AmazonEC2Configuration amazonec2Config = {
    accessKeyId: "",
    secretAccessKey: "",
    region: "",
    clientConfig:{}
};

amazonec2:Client amazonEC2Client = new(amazonec2Config);

public function main() {

    amazonec2:EC2Instance[] arr;
    string imgId = "ami-0d5b";

    var newInstances = amazonEC2Client->runInstances(imgId, 1, 1);
    if (newInstances is error) {
        test:assertFail(msg = < string > insts.detail().message);
    } else {
        io:println("Successfully run the instance : ");
        io:println(newInstances);
        arr = newInstances;
    }

    runtime:sleep(20000); // wait for a bit before terminating the new instance

    string[] instIds = arr.map(function (amazonec2:EC2Instance inst) returns (string) {return inst.id;});

    var describeInstances = amazonEC2Client->describeInstances(instIds[0]);
    if (describeInstances is error) {
        test:assertFail(msg = < string > describeInstances.detail().message);
    } else {
         io:println("Successfully describe the instance : ");
         io:println(describeInstances);
    }

    var terminated = amazonEC2Client->terminateInstances(instIds[0]);
    if (terminated is error) {
        test:assertFail(msg = < string > terminated.detail().message);
    } else {
        io:println(" Successfully terminate the instance : ");
        io:println(terminated);
        string instanceId = (terminated[0].id);
        test:assertNotEquals(instanceId, null, msg = "Failed to terminate the instances");
    }
}
```

**Note**

To test the following sample, create `ballerina.conf` file inside `sample location`, with following keys and provide values for the variables.

```
    ACCESS_KEY_ID="<your_access_key_id>"
    SECRET_ACCESS_KEY="<your_secret_access_key_id>"
    REGION="<your_current_region>"
    IMAGE_ID="<The ID of the AMI, which is required to launch an instance>"
    SOURCE_IMAGE_ID="<The ID of the AMI to copy>"
    SOURCE_REGION="<The name of the region that contains the AMI to copy>"
```


## Example 2
```ballerina
import ballerina/io;
import wso2/amazonec2;
import ballerina/runtime;
import ballerina/config;

amazonec2:AmazonEC2Configuration amazonec2Config = {
    accessKeyId: "",
    secretAccessKey: "",
    region: "",
    clientConfig:{}
};

amazonec2:Client amazonEC2Client = new(amazonec2Config);

public function main() {
    string accessKeyId = config:getAsString("ACCESS_KEY_ID");
    string secretAccessKey = config:getAsString("SECRET_ACCESS_KEY");
    string region = config:getAsString("REGION");
    string imageId = config:getAsString("IMAGE_ID");
    string sourceImageId = config:getAsString("SOURCE_IMAGE_ID");
    string sourceRegion = config:getAsString("SOURCE_REGION");
    string groupName = "Test Ballerina Group"; // Rename the group name if you wanted create a group with different name.
    string imageName = "Test Ballerina AMI"; // Rename the image name if you wanted create a AMI with different name.
    string deviceName = "/dev/sdh"; // The device name (for example, /dev/sdh or xvdh).

    callAmazonEC2Methods(accessKeyId, secretAccessKey, region, imageId, groupName, deviceName, imageName, sourceImageId, sourceRegion);
}

function callAmazonEC2Methods(string accessKeyId, string secretAccessKey, string region,
                              string imageId, string groupName, string deviceName,
                              string imageName, string sourceImageId, string sourceRegion) {
    
    amazonec2:EC2Instance[] arr;
    string testGroupId;
    string zoneName;
    string[] instIds;

    var newSecurityGroup = amazonEC2Client->createSecurityGroup(groupName, "Test Ballerina Group in AmazonEC2 instance");
    if (securityGroup is amazonec2:SecurityGroup) {
         io:println(" Successfully create a new security group : ");
         io:println(securityGroup);
         testGroupId = securityGroup.groupId;
    } else {
         test:assertFail(msg = <string>securityGroup.detail().message);
    }

    var newInstances = amazonEC2Client->runInstances(imageId, 1, 1, securityGroupId = [testGroupId]);
    if (newInstances is error) {
        test:assertFail(msg = < string > newInstances.detail().message);
    } else {
         io:println("Successfully run the instance : ");
         io:println(newInstances);
         arr = newInstances;
         instIds = arr.map(function (amazonec2:EC2Instance newInstances) returns (string) {return inst.id;});
         zoneName = newInstances[0].zone;
    }

    runtime:sleep(60000); // wait a bit until launch an instance.

    var describeInstances = amazonEC2Client->describeInstances(instIds[0]);
    if (describeInstances is error) {
        test:assertFail(msg = < string > describeInstances.detail().message);
    } else {
        io:println("Successfully describe the instance : ");
        io:println(describeInstances);
    }

    var newImage = amazonEC2Client->createImage(instIds[0], imageName);
    string id;
    if (newImage is amazonec2:Image) {
        io:println(" Successfully create a new image : ");
        id = newImage.imageId;
        io:println(newImage);
    } else {
        test:assertFail(msg = <string>newImage.detail().message);
    }

    runtime:sleep(60000);// wait until the image creates.
    var deRegisterImage = amazonEC2Client->deRegisterImage(untaint id);
    if (deRegisterImage is amazonec2:EC2ServiceResponse) {
        io:println(" Successfully de register the image : ");
        io:println(deRegisterImage);
    } else {
        test:assertFail(msg = <string>deRegisterImage.detail().message);
    }

    var describeImageResponse = amazonEC2Client->describeImages(imageId);
    if (describeImageResponse is error) {
        test:assertFail(msg = <string>describeImageResponse.detail().message);
    } else {
        io:println(" Successfully describe the image : ");
        io:println(describeImageResponse);
    }

    var imageAttributeResponse = amazonEC2Client->describeImageAttribute(imageId, "description");
    if (imageAttributeResponse is amazonec2:ImageAttribute) {
        io:println(" Successfully describes an image with an attribute : ");
        io:println(imageAttributeResponse);
    } else {
        test:assertFail(msg = <string>imageAttributeResponse.detail().message);
    }

    var copyImage = amazonEC2Client->copyImage("Copy_Image", sourceImageId, sourceRegion);
    if (copyImage is amazonec2:Image) {
        io:println(" Successfully copy the image to the current region : ");
        io:println(copyImage);
    } else {
        test:assertFail(msg = <string>copyImage.detail().message);
    }

    var newVolume = amazonEC2Client->createVolume(zoneName, size = 8);

    string volumeId;
    if (newVolume is amazonec2:Volume) {
        io:println(" Successfully create a new volume : ");
        volumeId = newVolume.volumeId;
        io:println(newVolume);
    } else {
        test:assertFail(msg = <string>newVolume.detail().message);
    }

    runtime:sleep(60000);// wait for a bit before attaching to a new volume until it creates.

    var attachmentInfo = amazonEC2Client->attachVolume(deviceName, instIds[0], volumeId);
    if (attachmentInfo is amazonec2:AttachmentInfo ) {
        io:println(" Successfully attaches volume : ");
        io:println(attachmentInfo);
    } else {
        test:assertFail(msg = <string>attachmentInfo.detail().message);
    }

    runtime:sleep(60000); // wait for a bit before detaching the new volume until the attachment completes.
    var detachmentInfo = amazonEC2Client->detachVolume(volumeId);
    if (detachmentInfo is amazonec2:AttachmentInfo) {
        io:println(" Successfully detach the volume : ");
        io:println(detachmentInfo);
    }else {
        test:assertFail(msg = <string>detachmentInfo.detail().message);
    }

    var terminated = amazonEC2Client->terminateInstances(instIds[0]);
    if (terminated is error) {
        test:assertFail(msg = < string > terminated.detail().message);
    } else {
        io:println(" Successfully terminate the instance : ");
        io:println(terminated);
        string instanceId = (terminated[0].id);
        test:assertNotEquals(instanceId, null, msg = "Failed to terminate the instances");
    }


    runtime:sleep(100000); // wait for a bit before delete security group until the instance get terminates

    var deleteSecurityGroupResponse = amazonEC2Client->deleteSecurityGroup(groupId = testGroupId);
    if (deleteSecurityGroupResponse is amazonec2:EC2ServiceResponse) {
        io:println(" Successfully  delete the security group : ");
        io:println(deleteSecurityGroupResponse);
    } else {
        test:assertFail(msg = <string>deleteSecurityGroupResponse.detail().message);
    }
}
```