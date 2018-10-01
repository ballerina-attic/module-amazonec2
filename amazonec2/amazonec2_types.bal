//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/io;
import ballerina/time;


# The supported instance state by this package.

public type InstanceState "pending"|"running"|"shutting-down"|"terminated"|"stopping"|"stopped";

# The supported volume type by this package.

public type VolumeType "standard"|"io1"|"gp2"|"sc1"|"st1";

# The supported volume attachment status by this package.

public type VolumeAttachmentStatus "attaching"|"attached"|"detaching"|"detached"|"busy";

@final public InstanceState ISTATE_PENDING = "pending";
@final public InstanceState ISTATE_RUNNING = "running";
@final public InstanceState ISTATE_SHUTTING_DOWN = "shutting-down";
@final public InstanceState ISTATE_TERMINATED = "terminated";
@final public InstanceState ISTATE_STOPPING = "stopping";
@final public InstanceState ISTATE_STOPPED = "stopped";

@final public VolumeType TYPE_STANDARD = "standard";
@final public VolumeType TYPE_IO1 = "io1";
@final public VolumeType TYPE_GP2 = "gp2";
@final public VolumeType TYPE_SC1 = "sc1";
@final public VolumeType TYPE_ST1 = "st1";

@final public VolumeAttachmentStatus ATTACHING = "attaching";
@final public VolumeAttachmentStatus ATTACHED = "attached";
@final public VolumeAttachmentStatus DETACHING = "detaching";
@final public VolumeAttachmentStatus DETACHED = "detached";
@final public VolumeAttachmentStatus BUSY = "busy";

# Define the AmazonEC2 Connector.
# + amazonEC2Config - AmazonEC2 connector configurations
# + amazonEC2Connector - AmazonEC2 Connector object

public type Client object {

    public AmazonEC2Configuration amazonEC2Config = {};
    public AmazonEC2Connector amazonEC2Connector = new;

    # AmazonEC2 connector endpoint initialization function
    # + config - AmazonEC2 connector configuration

    public function init(AmazonEC2Configuration config);

    # Return the AmazonEC2 connector client
    # + return - AmazonEC2 connector client

    public function getCallerActions() returns AmazonEC2Connector;

};

# Define the Amazon ec2 connector.
# + uri - The Amazon ec2 endpoint
# + accessKeyId - The access key of Amazon ec2 account
# + secretAccessKey - The secret key of the Amazon ec2 account
# + region - The AWS region
# + clientEndpoint - HTTP client endpoint

public type AmazonEC2Connector object {
    string uri;
    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public http:Client clientEndpoint = new;

    # Launches the specified number of instances using an AMI for which you have permissions.
    # + imgId -  The ID of the AMI which is required to launch an instance
    # + maxCount - The maximum number of instances to launch
    # + minCount - The minimum number of instances to launch
    # + securityGroup - [EC2-Classic, default VPC] One or more security group names
    # + securityGroupId - One or more security group IDs
    # + return - If success, returns EC2Instance of launched instances, else returns AmazonEC2Error object
    public function runInstances(string imgId, int maxCount, int minCount, string[]? securityGroup = (),
                                 string[]? securityGroupId = ()) returns EC2Instance[]|AmazonEC2Error;

    # Describes one or more of your instances.
    # + instanceIds -  Array of instanceIds to describe those
    # + return - If successful, returns EC2Instance[] with zero or more instances, else returns an AmazonEC2Error
    public function describeInstances(string... instanceIds) returns EC2Instance[]|AmazonEC2Error;

    # Shuts down one or more instances.
    # + instanceArray -  Array of instanceIds to terminate those
    # + return - If success, returns EC2Instance with terminated instances, else returns AmazonEC2Error object
    public function terminateInstances(string... instanceArray) returns EC2Instance[]|AmazonEC2Error;

    # Create image.
    # + instanceId -  The ID of the instance which is created with the particular image id
    # + name - The name of the image
    # + return - If successful, returns Image with image id, else returns an AmazonEC2Error
    public function createImage(string instanceId, string name) returns Image|AmazonEC2Error;

    # Describe images.
    # + imgIdArr -  The string of AMI array to describe those images.
    # + return - If successful, returns Image[] with image details, else returns an AmazonEC2Error
    public function describeImages(string... imgIdArr) returns Image[]|AmazonEC2Error;

    # Deregisters the specified AMI. After you deregister an AMI, it can't be used to launch new instances; however,
    # it doesn't affect any instances that you've already launched from the AMI.
    # + imgId - The ID of the AMI
    # + return - If successful, returns success response, else returns an AmazonEC2Error.
    public function deRegisterImage(string imgId) returns EC2ServiceResponse|AmazonEC2Error;

    # Describes the specified attribute of the specified AMI. You can specify only one attribute at a time.
    # + amiId - The ID of the AMI
    # + attribute - The specific attribute of the image.
    # + return - If successful, returns success response, else returns an AmazonEC2Error
    public function describeImageAttribute(string amiId, string attribute) returns ImageAttribute |AmazonEC2Error;

    # Initiates the copy of an AMI from the specified source region to the current region.
    # + name -  The name of the new AMI in the destination region
    # + sourceImageId - The ID of the AMI to copy
    # + sourceRegion - The name of the region that contains the AMI to copy
    # + return - If successful, returns Image object, else returns an AmazonEC2Error
    public function copyImage(string name, string sourceImageId, string sourceRegion) returns Image |AmazonEC2Error;

    # Creates a security group.
    # + groupName - The name of the security group
    # + groupDescription - A description for the security group
    # + vpcId - The ID of the VPC, Required for EC2-VPC
    # + return - If successful, returns SecurityGroup object with groupId, else returns an AmazonEC2Error
    public function createSecurityGroup(string groupName, string groupDescription, string? vpcId = ())
                        returns SecurityGroup |AmazonEC2Error;

    # Deletes a security group. Can specify either the security group name or the security group ID.
    # But group id is required for a non default VPC.
    # + groupId -  The id of the security group
    # + groupName - The name of the security group
    # + return - If successful, returns success response, else returns an AmazonEC2Error
    public function deleteSecurityGroup(string? groupId = (), string? groupName = ())
                        returns EC2ServiceResponse |AmazonEC2Error;

    # Creates an EBS volume that can be attached to an instance in the same Availability Zone.
    # + availabilityZone - The Availability Zone in which to create the volume
    # + size - The size of the volume, in GiBs
    # + snapshotId - The snapshot from which to create the volume
    # + volumeType - The volume type
    # + return - If successful, returns Volume object with created volume details, else returns an AmazonEC2Error
    public function createVolume(string availabilityZone, int? size = (), string? snapshotId = (),
                                 string? volumeType = ()) returns Volume|AmazonEC2Error;

    # Attaches an EBS volume to a running or stopped instance and exposes it to the instance with the specified device name.
    # + device - The device name
    # + instanceId - The ID of the instance
    # + volumeId - The ID of the EBS volume. The volume and instance must be within the same Availability Zone
    # + return - If successful, returns Attachment information, else returns an AmazonEC2Error
    public function attachVolume(string device, string instanceId, string volumeId) returns AttachmentInfo|AmazonEC2Error;

    # Detaches an EBS volume from an instance.
    # + force - Forces detachment if the previous detachment attempt did not occur cleanly
    # + volumeId - The ID of the volume
    # + return - If successful, returns detached volume information, else returns an AmazonEC2Error
    public function detachVolume(boolean force = false, string volumeId) returns AttachmentInfo|AmazonEC2Error;
};

# Define the configurations for Amazon ec2 connector.
# + uri - The Amazon ec2 endpoint
# + accessKeyId - The access key of Amazon ec2 account
# + secretAccessKey - The secret key of the Amazon ec2 account
# + region - The AWS region
# + clientConfig - HTTP client endpoint config

public type AmazonEC2Configuration record {
    string uri;
    string accessKeyId;
    string secretAccessKey;
    string region;
    http:ClientEndpointConfig clientConfig = {};
};

# Representation of an EC2 instance.
# + id - The ID of the EC2 instance
# + imageId - The ID of the image used to create the instance
# + state - The current state of the instance
# + iType - The type of the instance (e.g., t2.micro)
# + zone - The zone in which the instance resides
# + privateIpAddress - The private IP address of the instance
# + ipAddress - The public IP address of the instance (if assigned one)

public type EC2Instance record {
    string id;
    string imageId;
    InstanceState? state;
    string iType; // instance type - e.g., t2.micro
    string zone;
    string privateIpAddress;
    string ipAddress;
};

# Define an Image details
# + description - Image description
# + creationDate - Image creation date
# + imageId - Id of the image
# + imageLocation - Location of the image
# + imageState - State of the image
# + imageType - Type of the image
# + name - name of the image

public type Image record {
    string description;
    string creationDate;
    string imageId;
    string imageLocation;
    string imageState;
    string imageType;
    string name;
};

# Define an EC2 service response, it will return boolean value based on the service status.
# + success - If the service request get succeed then the value will be true or flase

public type EC2ServiceResponse record {
    boolean success; //The Boolean value.
};

# Define an ImageAttribute, based on these attributes type, an image will be described.

public type ImageAttribute DescriptionAttribute|KernelAttribute|LaunchPermissionAttribute[]|RamdiskAttribute|
ProductCodeAttribute[]|BlockDeviceMapping[]|SriovNetSupportAttribute;

# Define description image attribute, based on this attribute type, an image will be described.
# + description - Value of the description

public type DescriptionAttribute record {
    string description;
};

# Define kernel image attribute, based on this attribute type, an image will be described.
# + kernelId - id of the kernel

public type KernelAttribute record {
    string kernelId;
};

# Define launch permission image attribute, based on this attribute type, an image will be described.
# + groupName - The name of the group
# + userId - The AWS account ID

public type LaunchPermissionAttribute record {
    string groupName;
    string userId;
};

# Define ram disk image attribute, based on this attribute type, an image will be described.
# + ramDiskValue - The RAM disk ID.

public type RamdiskAttribute record {
    string ramDiskValue;
};

# Define product code image attribute, based on this attribute type, an image will be described.
# + productCode - The product code
# + productType - The type of product code

public type ProductCodeAttribute record {
    string productCode;
    string productType;
};

# Define  block device mapping image attribute, based on this attribute type, an image will be described.
# + deviceName - The device name
# + noDevice - Suppresses the specified device included in the block device mapping of the AMI
# + virtualName - The virtual device name

public type BlockDeviceMapping record {
    string deviceName;
    string noDevice;
    string virtualName;
};

# Define sriovNetSupport image attribute, based on this attribute type, an image will be described.
# + sriovNetSupportValue - Indicates whether enhanced networking with the Intel 82599 Virtual Function interface is enabled

public type SriovNetSupportAttribute record {
    string sriovNetSupportValue;
};

# Defines whether security group is successfully created or not.
# + groupId - The id of the group

public type SecurityGroup record {
    string groupId;
};

# Describe the volume details.
# + availabilityZone - The Availability Zone for the volume
# + volumeId - The ID of the volume
# + size - The size of the volume, in GiBs
# + volumeType - The volume type

public type Volume record {
    string availabilityZone;
    int size;
    string volumeId;
    VolumeType? volumeType;
};

# Define an attachment details of an EBS volume which is attached to a running or stopped instance.
# + attachTime - The time stamp when the attachment initiated
# + device - The device name
# + instanceId - The ID of the instance
# + status - The attachment state of the volume
# + volumeId - The ID of the volume

public type AttachmentInfo record {
    string attachTime;
    string device;
    string instanceId;
    VolumeAttachmentStatus? status;
    string volumeId;
};

# Amazon ec2 Client Error
# + message - Error message of the response
# + cause - The error which caused the error

public type AmazonEC2Error record {
    string message;
    error? cause;
};
