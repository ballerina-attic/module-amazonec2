//
// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/runtime;
import ballerina/io;

# A function to wait for a specific method to return a 'true' value within a given period of time
# under a specified number of retries.
# + pollDelay - Delay between retries in milliseconds.
# + retryCount - Number of maximum retries.
# + inputFunc - A function which takes a string as an argument and returns a 'true' value when a condition is met.
function pollAndWait(int pollDelay, int retryCount, string functionArg, function (string) returns (boolean) inputFunc) {
    int count = 0;

    while (count < retryCount) {
        if (inputFunc(functionArg)) {
            break;
        }
        count = count + 1;
        runtime:sleep(pollDelay);
    }
}

# Checks if an EC2 instance exists.
# + instanceId - The ID of the EC2 instance.
# + return - Returns 'true' if exists and 'false' otherwise.
function isInstanceRunning(string instanceId) returns boolean {
    var reservations = amazonEC2Client->describeInstances(instanceId);
    if (reservations is error) {
        return false;
    } else {
        string instanceState = reservations[0].state.toString();
        if (instanceState == "running") {
            io:println("Instance is running.");
            return true;
        }
    }
    return false;
}

# Checks if an EC2 instance is terminated.
# + instanceId - The ID of the EC2 instance.
# + return - Returns 'true' if terminated and 'false' otherwise.
function isInstanceTerminated(string instanceId) returns boolean {
    var reservations = amazonEC2Client->describeInstances(instanceId);
    if (reservations is error) {
        return false;
    } else {
        string instanceState = reservations[0].state.toString();
        if (instanceState == "terminated") {
            io:println("Instance is terminated.");
            return true;
        }
    }
    return false;
}

# Checks if an image is in the 'available' state.
# + imageId - The ID of the image.
# + return - Returns 'true' if exists and 'false' otherwise.
function isImageAvailable(string imageId) returns boolean {
    var image = amazonEC2Client->describeImages(imageId);
    if (image is error) {
        return false;
    } else {
        io:println("Successfully described the images: ", image);
        string imageState = image[0].imageState;
        if (imageState == "available") {
            io:println("Image is available.");
            return true;
        }
    }
    return false;
}
