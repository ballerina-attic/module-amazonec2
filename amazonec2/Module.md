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

The `wso2/amazonec2` module contains operations that work with Amazon EC2 AMIs. You can create, describe, deregister and copy the
AMIs with these operations.

## Compatibility
|                    |    Version     |
|:------------------:|:--------------:|
| Ballerina Language |   0.991.0      |
| Amazon EC2 API     |   2016-11-15   |

## Sample

First, import the `wso2/amazonec2` module into the Ballerina project.

```ballerina
import wso2/amazonec2;
```
The Amazon EC2 connector can be instantiated using the accessKeyId, secretAccessKey, securityToken and region,
in the Amazon EC2 client config.

**Obtaining AWS credentials to Run the Sample**

## Signing Up for AWS

1. Navigate to this link <https://aws.amazon.com/>, and then choose Create an AWS Account.

   **Note:** If you previously signed in to the AWS Management Console using AWS account root user credentials, choose Sign in to a different account. If you previously signed in to the console using IAM credentials, choose Sign-in using root account credentials. Then choose Create a new AWS account.
2. Follow the online instructions - Part of the sign-up procedure involves receiving a phone call and entering a verification code using the phone keypad. AWS will notify you by email when your account is active and available for you to use.

You can follow one of the below explained ways to obtain AWS credentials.

### Obtaining user credentials

You can access the Amazon EC2 service using the root user credentials but these credentials allow full access to all resources in the account as you can't restrict permission for root user credentials. If you want to restrict certain resources and allow controlled access to AWS services then you can create IAM(Identity and Access Management) users in your AWS account. In that case :

1. Follow the steps below to get an AWS Access Key for your AWS root account:

    * Go to the AWS Management Console.
    * Hover over your company name in the right top menu and click "My Security Credentials".
    * Scroll to the "Access Keys" section.
    * Click on "Create New Access Key".
    * Copy both the Access Key ID (YOUR_AMAZON_EC2_KEY) and Secret Access Key (YOUR_AMAZON_EC2_SECRET).

2. Follow the steps below to get an AWS Access Key for an IAM user account:

    * Sign in to the AWS Management Console and open the IAM console.
    * In the navigation pane, choose Users.
    * Add a check mark next to the name of the desired user, and then choose User Actions from the top.
    * Click on Manage Access Keys.
    * Click on Create Access Key.
    * Click on Show User Security Credentials. Copy and paste the Access Key ID and Secret Access Key values, or click on Download Credentials to download the credentials in a CSV (file).

3. Obtain the following parameters
    * Access key ID.
    * Secret access key.
    * Desired Server region.

### Obtaining temporary security credentials using IAM roles

Temporary credentials are primarily used with IAM roles. You can request temporary credentials that have a more restricted set of permissions than your standard IAM user. A benefit of temporary credentials is that they expire automatically after a set period of time. You have control over the duration that the credentials are valid. Temporary security credentials work almost identically to the long-term access key credentials that your IAM users can use.
An application on the instance retrieves the security credentials provided by the role from the instance metadata item iam/security-credentials/role-name. The application is granted the permissions for the actions and resources that you've defined for the role through the security credentials associated with the role. These security credentials are temporary and we rotate them automatically.

1. Follow this doc <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html>, to launch an EC2 Instance.
2. Get the SSH key (.pem file) is provided by Amazon when you launch the instance.
3. Follow this doc to connect to your instance using an SSH client <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html#AccessingInstancesLinuxSSHClient>
4. Retrieve Security Credentials from your Instance Metadata. The following command retrieves the security credentials for an IAM role named ec2access.
    ```
    curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2access
    ```

   The following is example output.
    ```
    {
      "Code" : "Success",
      "LastUpdated" : "2012-04-26T16:39:16Z",
      "Type" : "AWS-HMAC",
      "AccessKeyId" : "<ACCESSKEY_ID>",
      "SecretAccessKey" : "<SECRETACCESSKEY>",
      "Token" : "<TOKEN>",
      "Expiration" : "2017-05-17T15:09:54Z"
    }
    ```

5. Obtain the following parameters
    * Access key ID.
    * Secret access key.
    * Token.
    * Desired Server region.

You can now enter the credentials in the Amazon EC2 client config:

```ballerina
amazonec2:AmazonEC2Configuration amazonec2Config = {
    accessKeyId: "",
    secretAccessKey: "",
    securityToken: "",
    region: ""
};

amazonec2:Client amazonEC2Client = new(amazonec2Config);
```

The `runInstances` remote function launches the specified number of instances using an AMI for which you have permissions.
You can specify the maximum number of instances to launch and the minimum number of instances to launch.

   `var runInstancesResponse = amazonEC2Client->runInstances(imgId, maxCount, minCount);`

If the instance started successfully, the response from the `runInstances` remote function is an `EC2Instance` array representing one or more launched instance(s) IDs.
If it is unsuccessful, the response is an `error`.

```ballerina
if (runInstancesResponse is amazonec2:EC2Instance[]) {
    io:println("Successfully ran instances: ", runInstancesResponse);
} else {
    io:println("Error: ", runInstancesResponse.detail().message);
}
```

The `describeInstances` remote function describes one or more of your instances. It returns an `EC2Instance` array with reservation IDs if it is successful or an `error` if unsuccessful.

```ballerina
var describeInstancesResponse = amazonEC2Client->describeInstances("ami-0ba4ce8cbsffd4e6333");
if (describeInstancesResponse is amazonec2:EC2Instance[]) {
    io:println("Instance descriptions: ", describeInstancesResponse);
} else {
    io:println("Error: ", describeInstancesResponse.detail().message);
}
```

The `terminateInstances` remote function shuts down one or more instances. It returns an `EC2Instance` array with terminated instance IDs if it is successful or an `error` if unsuccessful.

```ballerina
var terminationResponse = amazonEC2Client->terminateInstances("ami-0ba4ce8cbsffd4e6333");
if (terminationResponse is amazonec2:EC2Instance[]) {
    io:println("Successfully terminated instance(s): ", terminationResponse);
} else {
    io:println("Error: ", terminationResponse.detail().message);
}
```

The `createImage` remote function will create an image. It returns an `Image` object with the created image ID if it is successful or an `error` if unsuccessful.

```ballerina
var newImage = amazonEC2Client->createImage("ami-0ba4ce8cbsffd4e6333", "Test Image");
if (newImage is amazonec2:Image) {
    io:println("Successfully created a new image: ", newImage);
} else {
    io:println("Error: ", newImage.detail().message);
}
```

The `describeImages` remote function will describe the images. It returns an `Image` array with image details if it is successful or an `error` if unsuccessful.

```ballerina
var describeImageResponse = amazonEC2Client->describeImages("ami-0ba4ce8cb48ssfsfs");
if (describeImageResponse is amazonec2:Image[]) {
    io:println("Successfully described the image: ", describeImageResponse);
} else {
    io:println("Error: ", describeImageResponse.detail().message);
}
```

The `describeImageAttribute` remote function will describe an image with specified attributes. It returns an `ImageAttribute` object based on the attribute name if it is successful or an `error` if unsuccessful.

```ballerina
var imageAttributeResponse = amazonEC2Client->describeImageAttribute("ami-0ba4ce8cb48ssfsfs", "Description of Image");
if (imageAttributeResponse is amazonec2:ImageAttribute) {
    io:println("Successfully described an image with an attribute: ", imageAttributeResponse);
} else {
    io:println("Error: ", imageAttributeResponse.detail().message);
}
```

The `deregisterImage` remote function will deregister the specified AMI. After you deregister an AMI, it cannot be used to launch new instances. However, it doesn't affect any instances that you've already launched from the AMI.
It returns true as a service response if it is successful or an `error` if unsuccessful.

```ballerina
var deregisterImage = amazonEC2Client->deregisterImage("ami-0ba4ce8cb48ssfsfs");
if (deregisterImage is amazonec2:EC2ServiceResponse) {
    io:println("Successfully deregistered the image: ", deregisterImage);
} else {
    io:println("Error: ", deregisterImage.detail().message);
}
```

The `copyImage` remote function initiates the copying of an AMI from the specified source region to the current region.
 It returns an `Image` object with details of the copied image if it is successful or an `error` if unsuccessful.

```ballerina
var copyImage = amazonEC2Client->copyImage("Copy_Image", "ami-0ba423rr4gtcb48ssfsfs", "us-east-2");
if (copyImage is amazonec2:Image) {
    io:println("Successfully copied the image to the current region: ", copyImage);
} else {
    io:println("Error: ", copyImage.detail().message);
}
```

The `createVolume` remote function creates an EBS volume that can be attached to an instance in the same Availability Zone.
 It returns a `Volume` object with created volume details if it is successful or an `error` if unsuccessful.

```ballerina
var newVolume = amazonEC2Client->createVolume("us-west-2c", size = 8);
if (newVolume is amazonec2:Volume) {
    io:println("Successfully created a new volume: ", newVolume);
} else {
    io:println("Error: ", newVolume.detail().message);
}
```

The `attachVolume` remote function attaches an EBS volume to a running or stopped instance and exposes it to the instance with the specified device name.
 It returns an `AttachmentInfo` object with attachment details if it is successful or an `error` if unsuccessful.

```ballerina
var attachmentInfo = amazonEC2Client->attachVolume("/dev/sdh", "ami-0ba4ce8cssdfd4e6333", volumeId);
if (attachmentInfo is amazonec2:AttachmentInfo ) {
    io:println("Successfully attached volume: ", attachmentInfo);
} else {
    io:println("Error: ", attachmentInfo.detail().message);
}
```

The `detachVolume` remote function detaches an EBS volume from an instance.
 It returns an `AttachmentInfo` object with volume details if successful or an `error` if unsuccessful.

```ballerina
var detachmentInfo = amazonEC2Client->detachVolume(volumeId);
if (detachmentInfo is amazonec2:AttachmentInfo) {
    io:println("Successfully detached the volume: ", detachmentInfo);
} else {
    io:println("Error: ", detachmentInfo.detail().message);
}
```

The `createSecurityGroup` remote function creates a security group. It returns a `SecurityGroup` object with group id if it is successful or an `error` if unsuccessful.

```ballerina
var newSecurityGroup = amazonEC2Client->createSecurityGroup("New_ballerina_group", "Test Ballerina Group in AmazonEC2 instance");
if (newSecurityGroup is amazonec2:SecurityGroup) {
    io:println("Successfully created a new security group: ", newSecurityGroup);
} else {
     io:println("Error: ", newSecurityGroup.detail().message);
}

```

The `deleteSecurityGroup` remote function deletes a security group by specifying either the security group name or the security group ID.
Group id is required for a non default VPC. It returns true as the response if it is successful or an `error` if unsuccessful.

```ballerina
var deleteSecurityGroupResponse = amazonEC2Client->deleteSecurityGroup(groupId = testGroupId);
if (deleteSecurityGroupResponse is amazonec2:EC2ServiceResponse) {
    io:println("Successfully deleted the security group: ", deleteSecurityGroupResponse);
} else {
    io:println("Error: ", deleteSecurityGroupResponse.detail().message);
}
```

## Example 1
```ballerina
import ballerina/io;
import ballerina/runtime;
import wso2/amazonec2;

amazonec2:AmazonEC2Configuration amazonec2Config = {
    accessKeyId: "",
    secretAccessKey: "",
    securityToken: "",
    region: ""
};

amazonec2:Client amazonEC2Client = new(amazonec2Config);

public function main() {

    amazonec2:EC2Instance[] arr = [];
    string imageId = "ami-09b864fbe67479fbd";

    var newInstances = amazonEC2Client->runInstances(imageId, 1, 1);
    if (newInstances is amazonec2:EC2Instance[]) {
        io:println("Successfully ran the instance: ", newInstances);
        arr = newInstances;
    } else {
        io:println("Error: ", newInstances.detail().message);
    }

    runtime:sleep(20000); // wait for a bit before terminating the new instance

    string[] instIds = arr.map(function (amazonec2:EC2Instance inst) returns (string) {return inst.id;});

    var describeInstances = amazonEC2Client->describeInstances(instIds[0]);
    if (describeInstances is amazonec2:EC2Instance[]) {
        io:println("Successfully described the instance: ", describeInstances);
    } else {
        io:println("Error: ", describeInstances.detail().message);
    }

    var terminated = amazonEC2Client->terminateInstances(instIds[0]);
    if (terminated is amazonec2:EC2Instance[]) {
        io:println("Successfully terminated the instance: ", terminated);
        string instanceId = (terminated[0].id);
        io:println("Instance ID: ", instanceId);
    } else {
        io:println("Error: ", terminated.detail().message);
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
import ballerina/config;
import ballerina/io;
import ballerina/runtime;
import wso2/amazonec2;

amazonec2:AmazonEC2Configuration amazonec2Config = {
    accessKeyId: config:getAsString("ACCESS_KEY_ID"),
    secretAccessKey: config:getAsString("SECRET_ACCESS_KEY"),
    securityToken: config:getAsString("SECURITY_TOKEN"),
    region: config:getAsString("REGION")
};

amazonec2:Client amazonEC2Client = new(amazonec2Config);

public function main() {

    string imageId = config:getAsString("IMAGE_ID");
    string sourceImageId = config:getAsString("SOURCE_IMAGE_ID");
    string sourceRegion = config:getAsString("SOURCE_REGION");
    string groupName = "Test Ballerina Group"; // Rename the group name if you wanted create a group with different name.
    string imageName = "Test Ballerina AMI"; // Rename the image name if you wanted create a AMI with different name.
    string deviceName = "/dev/sdh"; // The device name (for example, /dev/sdh or xvdh).

    amazonec2:EC2Instance[] arr;
    string testGroupId;
    string zoneName = "";
    string[] instIds = [];

    var newSecurityGroup = amazonEC2Client->createSecurityGroup(groupName, "Test Ballerina Group in AmazonEC2 instance");
    if (newSecurityGroup is amazonec2:SecurityGroup) {
        io:println("Successfully created a new security group: ", newSecurityGroup);
        testGroupId = untaint newSecurityGroup.groupId;
    } else {
        io:println("Error: ", newSecurityGroup.detail().message);
    }

    var newInstances = amazonEC2Client->runInstances(imageId, 1, 1, securityGroupId = [testGroupId]);
    if (newInstances is amazonec2:EC2Instance[]) {
        io:println("Successfully ran the instance: ", newInstances);
        arr = newInstances;
        instIds = arr.map(function (EC2Instance inst) returns (string) {return inst.id;});
        zoneName = newInstances[0].zone;
    } else {
        io:println("Error: ", newInstances.detail().message);
    }

    runtime:sleep(60000); // wait a bit until launch an instance.

    var describeInstances = amazonEC2Client->describeInstances(instIds[0]);
    if (describeInstances is amazonec2:EC2Instance[]) {
        io:println("Successfully described the instance: ", describeInstances);
    } else {
        io:println("Error: ", describeInstances.detail().message);
    }

    var newImage = amazonEC2Client->createImage(instIds[0], imageName);
    string id = "";
    if (newImage is amazonec2:Image) {
        io:println("Successfully created a new image: ", newImage);
        id = newImage.imageId;
    } else {
        io:println("Error: ", newImage.detail().message);
    }

    runtime:sleep(60000);// wait until the image creates.

    var deregisterImage = amazonEC2Client->deregisterImage(untaint id);
    if (deregisterImage is amazonec2:EC2ServiceResponse) {
        io:println("Successfully deregistered the image: ", deregisterImage);
    } else {
        io:println("Error: ", deregisterImage.detail().message);
    }

    var describeImageResponse = amazonEC2Client->describeImages(imageId);
    if (describeImageResponse is amazonec2:Image[]) {
        io:println("Image description: ", describeImageResponse);
    } else {
        io:println("Error: ", describeImageResponse.detail().message);
    }

    var imageAttributeResponse = amazonEC2Client->describeImageAttribute(imageId, "description");
    if (imageAttributeResponse is amazonec2:ImageAttribute) {
        io:println("Successfully described an image with an attribute: ", imageAttributeResponse);
    } else {
        io:println("Error: ", imageAttributeResponse.detail().message);
    }

    var copyImage = amazonEC2Client->copyImage("Copy_Image", sourceImageId, sourceRegion);
    if (copyImage is amazonec2:Image) {
        io:println("Successfully copy the image to the current region: ", copyImage);
    } else {
        io:println("Error: ", copyImage.detail().message);
    }

    string volumeId = "";
    var newVolume = amazonEC2Client->createVolume(zoneName, size = 8);
    if (newVolume is amazonec2:Volume) {
        io:println("Successfully created a new volume: ", newVolume);
        volumeId = untaint newVolume.volumeId;
    } else {
        io:println("Error: ", newVolume.detail().message);
    }

    runtime:sleep(60000);// wait for a bit before attaching to a new volume until it creates.

    var attachmentInfo = amazonEC2Client->attachVolume(deviceName, instIds[0], volumeId);
    if (attachmentInfo is amazonec2:AttachmentInfo) {
        io:println("Successfully attached volume: ", attachmentInfo);
    } else {
        io:println("Error: ", attachmentInfo.detail().message);
    }

    runtime:sleep(60000); // wait for a bit before detaching the new volume until the attachment completes.

    var detachmentInfo = amazonEC2Client->detachVolume(volumeId);
    if (detachmentInfo is amazonec2:AttachmentInfo) {
        io:println("Successfully detached the volume: ", detachmentInfo);
    } else {
        io:println("Error: ", detachmentInfo.detail().message);
    }

    var terminated = amazonEC2Client->terminateInstances(instIds[0]);
    if (terminated is amazonec2:EC2Instance[]) {
        io:println("Successfully terminated the instance: ", terminated);
        string instanceId = (terminated[0].id);
        io:println("Instance Id: ", instanceId);
    } else {
        io:println("Error: ", terminated.detail().message);
    }

    runtime:sleep(100000); // wait for a bit before delete security group until the instance get terminates

    var deleteSecurityGroupResponse = amazonEC2Client->deleteSecurityGroup(groupId = testGroupId);
    if (deleteSecurityGroupResponse is amazonec2:EC2ServiceResponse) {
        io:println("Successfully deleted the security group: ", deleteSecurityGroupResponse);
    } else {
        io:println("Error: ", deleteSecurityGroupResponse.detail().message);
    }
}
```