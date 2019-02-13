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

# The supported instance state by this module.
public type InstanceState "pending"|"running"|"shutting-down"|"terminated"|"stopping"|"stopped";

# The supported volume type by this module.
public type VolumeType "standard"|"io1"|"gp2"|"sc1"|"st1";

# The supported volume attachment status by this module.
public type VolumeAttachmentStatus "attaching"|"attached"|"detaching"|"detached"|"busy";

final InstanceState ISTATE_PENDING = "pending";
final InstanceState ISTATE_RUNNING = "running";
final InstanceState ISTATE_SHUTTING_DOWN = "shutting-down";
final InstanceState ISTATE_TERMINATED = "terminated";
final InstanceState ISTATE_STOPPING = "stopping";
final InstanceState ISTATE_STOPPED = "stopped";

final VolumeType TYPE_STANDARD = "standard";
final VolumeType TYPE_IO1 = "io1";
final VolumeType TYPE_GP2 = "gp2";
final VolumeType TYPE_SC1 = "sc1";
final VolumeType TYPE_ST1 = "st1";

final VolumeAttachmentStatus ATTACHING = "attaching";
final VolumeAttachmentStatus ATTACHED = "attached";
final VolumeAttachmentStatus DETACHING = "detaching";
final VolumeAttachmentStatus DETACHED = "detached";
final VolumeAttachmentStatus BUSY = "busy";

# Define the configurations for Amazon ec2 connector.
# + accessKeyId - The access key of Amazon ec2 account
# + secretAccessKey - The secret key of the Amazon ec2 account
# + region - The AWS region
# + clientConfig - HTTP client endpoint config
public type AmazonEC2Configuration record {
    string accessKeyId = "";
    string secretAccessKey = "";
    string region = "";
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
    string id = "";
    string imageId = "";
    InstanceState? state = "pending";
    string iType = ""; // instance type - e.g., t2.micro
    string zone = "";
    string privateIpAddress = "";
    string ipAddress = "";
};

# Define an Image details.
# + description - Image description
# + creationDate - Image creation date
# + imageId - Id of the image
# + imageLocation - Location of the image
# + imageState - State of the image
# + imageType - Type of the image
# + name - name of the image
public type Image record {
    string description = "";
    string creationDate = "";
    string imageId = "";
    string imageLocation = "";
    string imageState = "";
    string imageType = "";
    string name = "";
};

# Define an EC2 service response, it will return boolean value based on the service status.
# + success - If the service request get succeed then the value will be true or flase
public type EC2ServiceResponse record {
    boolean success = false; //The Boolean value.
};

# Define an ImageAttribute, based on these attributes type, an image will be described.
public type ImageAttribute DescriptionAttribute|KernelAttribute|LaunchPermissionAttribute[]|RamdiskAttribute|
ProductCodeAttribute[]|BlockDeviceMapping[]|SriovNetSupportAttribute;

# Define description image attribute, based on this attribute type, an image will be described.
# + description - Value of the description
public type DescriptionAttribute record {
    string description = "";
};

# Define kernel image attribute, based on this attribute type, an image will be described.
# + kernelId - id of the kernel
public type KernelAttribute record {
    string kernelId = "";
};

# Define launch permission image attribute, based on this attribute type, an image will be described.
# + groupName - The name of the group
# + userId - The AWS account ID
public type LaunchPermissionAttribute record {
    string groupName = "";
    string userId = "";
};

# Define ram disk image attribute, based on this attribute type, an image will be described.
# + ramDiskValue - The RAM disk ID
public type RamdiskAttribute record {
    string ramDiskValue = "";
};

# Define product code image attribute, based on this attribute type, an image will be described.
# + productCode - The product code
# + productType - The type of product code
public type ProductCodeAttribute record {
    string productCode = "";
    string productType = "";
};

# Define  block device mapping image attribute, based on this attribute type, an image will be described.
# + deviceName - The device name
# + noDevice - Suppresses the specified device included in the block device mapping of the AMI
# + virtualName - The virtual device name
public type BlockDeviceMapping record {
    string deviceName = "";
    string noDevice = "";
    string virtualName = "";
};

# Define sriovNetSupport image attribute, based on this attribute type, an image will be described.
# + sriovNetSupportValue - Indicates whether enhanced networking with the Intel 82599 Virtual Function
# interface is enabled
public type SriovNetSupportAttribute record {
    string sriovNetSupportValue = "";
};

# Defines whether security group is successfully created or not.
# + groupId - The id of the group
public type SecurityGroup record {
    string groupId = "";
};

# Describe the volume details.
# + availabilityZone - The Availability Zone for the volume
# + volumeId - The ID of the volume
# + size - The size of the volume, in GiBs
# + volumeType - The volume type
public type Volume record {
    string availabilityZone = "";
    int size = 0;
    string volumeId = "";
    VolumeType? volumeType = "standard";
};

# Define an attachment details of an EBS volume which is attached to a running or stopped instance.
# + attachTime - The time stamp when the attachment initiated
# + device - The device name
# + instanceId - The ID of the instance
# + status - The attachment state of the volume
# + volumeId - The ID of the volume
public type AttachmentInfo record {
    string attachTime = "";
    string device = "";
    string instanceId = "";
    VolumeAttachmentStatus? status = "attaching";
    string volumeId = "";
};
