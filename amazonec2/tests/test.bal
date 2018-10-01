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
import ballerina/test;
import ballerina/runtime;

string testAccessKeyId = config:getAsString("ACCESS_KEY_ID");
string testSecretAccessKey = config:getAsString("SECRET_ACCESS_KEY");
string testRegion = config:getAsString("REGION");
string testImageId = config:getAsString("IMAGE_ID");
string testSourceImageId = config:getAsString("SOURCE_IMAGE_ID");
string testSourceRegion = config:getAsString("SOURCE_REGION");
string[] testInstanceIds;
string[] imgIds;
string testGroupId;
string testVolumeId;
string testZoneName;

endpoint Client amazonEC2Client {
    accessKeyId: testAccessKeyId,
    secretAccessKey: testSecretAccessKey,
    region: testRegion
};


@test:Config
function testCreateSecurityGroup() {
    log:printInfo("amazonEC2Client -> createSecurityGroup()");
    var rs = amazonEC2Client->createSecurityGroup("Ballerina_test_group", "Ballerina Test Group");
    match rs {
        SecurityGroup securityGroup => {
            io:println(" Successfully create the security group : ");
            io:println(securityGroup);
            testGroupId = securityGroup.groupId;
            test:assertNotEquals(securityGroup.groupId , null, msg = "Failed to create the security group");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn:["testCreateSecurityGroup"]
}
function testRunInstances() {
    EC2Instance[] arr;
    log:printInfo("amazonEC2Client -> runInstances()");
    var rs = amazonEC2Client->runInstances(testImageId, 1, 1, securityGroupId = [testGroupId]);
    match rs {
        EC2Instance[] insts => {
            io:println(" Successfully run the instance : ");
            io:println(insts);
            arr = insts;
            testInstanceIds = arr.map(function (EC2Instance inst) returns (string) {return inst.id;});
            testZoneName = insts[0].zone;
            test:assertNotEquals(testInstanceIds[0], null, msg = "Failed to run the instances");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn:["testRunInstances"]
}
function testDescribeInstances() {
    runtime:sleep(90000);
    log:printInfo("amazonEC2Client -> describeInstances()");
    var rs = amazonEC2Client->describeInstances(testInstanceIds[0]);
    match rs {
        EC2Instance[] reservations => {
            io:println(" Successfully describe the instances : ");
            io:println(reservations);
            string instanceId = reservations[0].id;
            test:assertNotEquals(instanceId, null, msg = "Failed to describeInstances");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn:["testDescribeInstances"]
}
function testCreateImage() {
    log:printInfo("amazonEC2Client -> testCreateImage()");
    var rs = amazonEC2Client->createImage(testInstanceIds[0], "Ballerina test instance image");
    match rs {
        Image image => {
            io:println(" Successfully create the image : ");
            io:println(image);
            string image_id = (image.imageId);
            imgIds = [image_id];
            test:assertNotEquals(image_id , null, msg = "Failed to create the image");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn:["testCreateImage"]
}
function testDescribeImages() {
    runtime:sleep(90000);
    log:printInfo("amazonEC2Client -> describeImages()");
    var rs = amazonEC2Client->describeImages(imgIds[0]);
    match rs {
        Image[] image => {
            io:println(" Successfully describe the images : ");
            io:println(image);
            string imageId = image[0].imageId;
            test:assertNotEquals(imageId, null, msg = "Failed to describe the images");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testDescribeImages"]
}
function testDescribeImageAttribute() {
    log:printInfo("amazonEC2Client -> describeImageAttribute()");
    var rs = amazonEC2Client->describeImageAttribute(imgIds[0], "description");
    match rs {
        ImageAttribute attribute => {
            io:println(" Successfully describes an image with an attribute : ");
            io:println(attribute);
            test:assertNotEquals(attribute, null, msg = "Failed to describe an image with an attribute");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testDescribeImageAttribute"]
}
function testDeRegisterImage() {
    log:printInfo("amazonEC2Client -> deRegisterImage()");
    var rs = amazonEC2Client->deRegisterImage(imgIds[0]);
    match rs {
        EC2ServiceResponse serviceResponse => {
            io:println(" Successfully de register the image : ");
            io:println(serviceResponse);
            boolean success = serviceResponse.success;
            test:assertTrue(success, msg = "Failed to de register the image");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testDeRegisterImage"]
}
function testCopyImage() {
    log:printInfo("amazonEC2Client -> copyImage()");
    var rs = amazonEC2Client->copyImage("My-Copy-AMI", testSourceImageId, testSourceRegion);
    match rs {
        Image image => {
            io:println(" Successfully copy the image : ");
            io:println(image);
            test:assertNotEquals(image.imageId , null, msg = "Failed to copy the image");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testRunInstances"]
}
function testCreateVolume() {
    log:printInfo("amazonEC2Client -> createVolume()");
    var rs = amazonEC2Client->createVolume(testZoneName, size = 8, volumeType = "standard");
    match rs {
        Volume volume => {
            io:println(" Successfully create a volume : ");
            io:println(volume);
            testVolumeId = volume.volumeId;
            test:assertNotEquals(volume.volumeId, null, msg = "Failed to create a volume");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testCreateVolume"]
}
function testAttachVolume() {
    runtime:sleep(60000);
    log:printInfo("amazonEC2Client -> attachVolume()");
    var rs = amazonEC2Client->attachVolume("/dev/sdh", testInstanceIds[0], testVolumeId);
    match rs {
        AttachmentInfo attachment => {
            io:println(" Successfully attaches volume : ");
            io:println(attachment);
            test:assertNotEquals(attachment.volumeId, null, msg = "Failed to attach the volume");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testAttachVolume"]
}
function testDetachVolume() {
    runtime:sleep(60000);
    log:printInfo("amazonEC2Client -> detachVolume()");
    var rs = amazonEC2Client->detachVolume(testVolumeId);
    match rs {
        AttachmentInfo attachment => {
            io:println(" Successfully detach the volume : ");
            io:println(attachment);
            test:assertNotEquals(attachment.volumeId, null, msg = "Failed to detach the volume");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn:["testDetachVolume"]
}
function testTerminateInstances() {
    runtime:sleep(60000);
    log:printInfo("amazonEC2Client -> terminateInstances()");
    var rs = amazonEC2Client->terminateInstances(testInstanceIds[0]);
    match rs {
        EC2Instance[] instance => {
            io:println(" Successfully terminate the instance : ");
            io:println(instance);
            string instanceId = (instance[0].id);
            test:assertNotEquals(instanceId, null, msg = "Failed to terminate the instances");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
{
    dependsOn: ["testTerminateInstances"]
}
function testDeleteSecurityGroup() {
    runtime:sleep(100000);
    log:printInfo("amazonEC2Client -> deleteSecurityGroup()");
    var rs = amazonEC2Client->deleteSecurityGroup(groupId = testGroupId);
    match rs {
        EC2ServiceResponse serviceResponse => {
            io:println(" Successfully  delete a security group : ");
            io:println(serviceResponse);
            boolean success = serviceResponse.success;
            test:assertTrue(success, msg = "Failed to delete a security group");
        }
        AmazonEC2Error err => {
            io:println(err);
            test:assertFail(msg = err.message);
        }
    }
}