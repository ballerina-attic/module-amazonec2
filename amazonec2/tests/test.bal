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

import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/runtime;
import ballerina/test;

string testAccessKeyId = config:getAsString("ACCESS_KEY_ID");
string testSecretAccessKey = config:getAsString("SECRET_ACCESS_KEY");
string testSecurityToken = config:getAsString("SECURITY_TOKEN");
string testRegion = config:getAsString("REGION");
string testImageId = config:getAsString("IMAGE_ID");
string testSourceImageId = config:getAsString("SOURCE_IMAGE_ID");
string testSourceRegion = config:getAsString("SOURCE_REGION");
string[] testInstanceIds = [];
string[] testImageIds = [];
string[] imgIds = [];
string testGroupId = "";
string testVolumeId = "";
string testZoneName = "";

AmazonEC2Configuration amazonec2Config = {
    accessKeyId: testAccessKeyId,
    secretAccessKey: testSecretAccessKey,
    securityToken: testSecurityToken,
    region: testRegion
};

Client amazonEC2Client = new(amazonec2Config);

@test:Config
function testCreateSecurityGroup() {
    log:printInfo("amazonEC2Client -> createSecurityGroup()");

    time:Time time = time:currentTime();
    int currentTimeMills = time.time;
    string currentTimeStamp = string.convert(currentTimeMills / 1000);
    var securityGroup = amazonEC2Client->createSecurityGroup("Ballerina_test_group" + currentTimeStamp,
        "Ballerina Test Group");
    if (securityGroup is SecurityGroup) {
        io:println("Successfully created the security group: ", securityGroup);
        testGroupId = untaint securityGroup.groupId;
        test:assertTrue(testGroupId.length() > 0, msg = "Failed to create the security group");
    } else {
        test:assertFail(msg = <string>securityGroup.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateSecurityGroup"]
}
function testRunInstances() {
    EC2Instance[] arr;
    log:printInfo("amazonEC2Client -> runInstances()");
    var insts = amazonEC2Client->runInstances(testImageId, 1, 1, securityGroupId = [testGroupId]);
    if (insts is error) {
        test:assertFail(msg = <string>insts.detail().message);
    } else {
        io:println("Successfully ran the instance: ", insts);
        arr = insts;
        testInstanceIds = arr.map(function (EC2Instance inst) returns (string) {
                return inst.id;
            });
        testImageIds = arr.map(function (EC2Instance inst) returns (string) {
            return inst.imageId;
        });
        testZoneName = insts[0].zone;
        test:assertEquals(testImageId, testImageIds[0], msg = "Failed to run the instances");
    }
}

@test:Config {
    dependsOn: ["testRunInstances"]
}
function testDescribeInstances() {
    runtime:sleep(50000);
    log:printInfo("amazonEC2Client -> describeInstances()");
    var reservations = amazonEC2Client->describeInstances(testInstanceIds[0]);
    if (reservations is error) {
        test:assertFail(msg = <string>reservations.detail().message);
    } else {
        io:println("Successfully described the instances: ", reservations);
        string instanceId = reservations[0].id;
        test:assertEquals(instanceId, testInstanceIds[0], msg = "Failed to describeInstances");
    }
}

@test:Config {
    dependsOn: ["testDescribeInstances"]
}
function testCreateImage() {
    runtime:sleep(40000);
    log:printInfo("amazonEC2Client -> testCreateImage()");
    var image = amazonEC2Client->createImage(testInstanceIds[0], "Ballerina test instance image");
    if (image is Image) {
        io:println("Successfully created the image: ", image);
        string image_id = (image.imageId);
        imgIds = untaint [image_id];
        test:assertTrue(image_id.length() > 0, msg = "Failed to create the image");
    } else {
        test:assertFail(msg = <string>image.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateImage"]
}
function testDescribeImages() {
    runtime:sleep(40000);
    log:printInfo("amazonEC2Client -> describeImages()");
    var image = amazonEC2Client->describeImages(imgIds[0]);
    if (image is error) {
        test:assertFail(msg = <string>image.detail().message);
    } else {
        io:println("Successfully described the images: ", image);
        string imageId = image[0].imageId;
        test:assertEquals(imageId, imgIds[0], msg = "Failed to describe the images");
    }
}

@test:Config {
    dependsOn: ["testDescribeImages"]
}
function testDescribeImageAttribute() {
    runtime:sleep(90000);
    log:printInfo("amazonEC2Client -> describeImageAttribute()");
    var attribute = amazonEC2Client->describeImageAttribute(imgIds[0], "description");
    if (attribute is ImageAttribute) {
        if (attribute is DescriptionAttribute) {
            io:println("Successfully described the image with an attribute: ", attribute);
            test:assertTrue(attribute.description.length() >= 0, msg = "Failed to describe an image with an attribute");
        }
    } else {
        test:assertFail(msg = <string>attribute.detail().message);
    }
}

@test:Config {
    dependsOn: ["testDescribeImageAttribute"]
}
function testDeregisterImage() {
    runtime:sleep(40000);
    log:printInfo("amazonEC2Client -> deregisterImage()");
    var serviceResponse = amazonEC2Client->deregisterImage(imgIds[0]);
    if (serviceResponse is EC2ServiceResponse) {
        io:println("Successfully deregistered the image: ", serviceResponse);
        boolean success = serviceResponse.success;
        test:assertTrue(success, msg = "Failed to deregister the image");
    } else {
        test:assertFail(msg = <string>serviceResponse.detail().message);
    }
}

@test:Config {
    dependsOn: ["testDeregisterImage"]
}
function testCopyImage() {
    runtime:sleep(50000);
    log:printInfo("amazonEC2Client -> copyImage()");
    var image = amazonEC2Client->copyImage("My-Copy-AMI", testSourceImageId, testSourceRegion);
    if (image is Image) {
        io:println("Successfully copied the image: ", image);
        test:assertTrue(image.imageId.length() > 0, msg = "Failed to copy the image");
    } else {
        test:assertFail(msg = <string>image.detail().message);
    }
}

@test:Config {
    dependsOn: ["testRunInstances"]
}
function testCreateVolume() {
    runtime:sleep(50000);
    log:printInfo("amazonEC2Client -> createVolume()");
    string standard = "standard";
    var volume = amazonEC2Client->createVolume(testZoneName, size = 8, volumeType = standard);
    if (volume is Volume) {
        io:println("Successfully created the volume: ", volume);
        testVolumeId = untaint volume.volumeId;
        test:assertEquals(volume.volumeType, standard, msg = "Failed to create a volume");
    } else {
        test:assertFail(msg = <string>volume.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateVolume"]
}
function testAttachVolume() {
    runtime:sleep(40000);
    log:printInfo("amazonEC2Client -> attachVolume()");
    var attachment = amazonEC2Client->attachVolume("/dev/sdh", testInstanceIds[0], testVolumeId);
    if (attachment is AttachmentInfo) {
        io:println("Successfully attached the volume: ", attachment);
        test:assertEquals(attachment.volumeId, testVolumeId, msg = "Failed to attach the volume");
    } else {
        test:assertFail(msg = <string>attachment.detail().message);
    }
}

@test:Config {
    dependsOn: ["testAttachVolume"]
}
function testDetachVolume() {
    runtime:sleep(40000);
    log:printInfo("amazonEC2Client -> detachVolume()");
    var attachment = amazonEC2Client->detachVolume(testVolumeId);
    if (attachment is AttachmentInfo) {
        io:println("Successfully detached the volume: ", attachment);
        test:assertEquals(attachment.volumeId, testVolumeId, msg = "Failed to detach the volume");
    } else {
        test:assertFail(msg = <string>attachment.detail().message);
    }
}

@test:Config {
    dependsOn: ["testDetachVolume"]
}
function testTerminateInstances() {
    runtime:sleep(60000);
    log:printInfo("amazonEC2Client -> terminateInstances()");
    var instance = amazonEC2Client->terminateInstances(testInstanceIds[0]);
    if (instance is error) {
        test:assertFail(msg = <string>instance.detail().message);
    } else {
        io:println("Successfully terminated the instance: ", instance);
        string instanceId = (instance[0].id);
        test:assertEquals(instanceId, testInstanceIds[0], msg = "Failed to terminate the instances");
    }
}

@test:Config {
    dependsOn: ["testTerminateInstances"]
}
function testDeleteSecurityGroup() {
    runtime:sleep(100000);
    log:printInfo("amazonEC2Client -> deleteSecurityGroup()");
    var serviceResponse = amazonEC2Client->deleteSecurityGroup(groupId = testGroupId);
    if (serviceResponse is EC2ServiceResponse) {
        io:println("Successfully deleted the security group: ", serviceResponse);
        boolean success = serviceResponse.success;
        test:assertTrue(success, msg = "Failed to delete a security group");
    } else {
        test:assertFail(msg = <string>serviceResponse.detail().message);
    }
}
