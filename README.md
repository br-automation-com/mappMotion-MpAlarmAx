## Table of Contents
* [Introduction](#Introduction)
* [Description](#Description)
* [Requirements](#Requirements)
* [Revision History](#Revision-History)

<a name="Introduction"></a>
## Introduction
The function block MpAxisAlarm reads all error messages for a specific axis.

![](/Logical/mappMotion/screenshot.png)

## Description
<a name="Description"></a>
The function block MpAxisAlarm uses the PLC logger to read all information for a specific axis error. This also includes error dependencies that often contain additional information. Each data record contains the following details:
<img align="right" src="https://user-images.githubusercontent.com/2972703/166929021-a539685a-d502-46e9-b738-11c8051e4023.png">

* EvendID
* ErrorText
* Severity
* RecordID
* OriginRecordID
* TimeStamp
* DTsec
* DTmsec

The function block MpAxisAlarm is started with a positive flag on the Execute input. The function block will then use the error number from the input ErrorID and search for the last entry of this error number and all depending errors. In addition, the function block checks for axis errors with MC_ReadAxisError and collect the data from this source as well. The input Language can be used to switch between English and German error text.
The function block is reset and the data is cleared when the input Execute is set to false. The input Execute can be directly connected to the Error output of a motion function block.

NOTE! For motion function blocks from the library MpAxis the error from the Info structure should be used for the ErrorID input (ex. MpAxisBasic_0.Info.Diag.Internal.ID)

The function block generates the following error numbers. All other error numbers are generated from included libraries that can be found in the Automation Studio help.

| No | Constant | Text |
|---|---|---|
| 10000 | ERROR_MAX_NO_ENTRIES  | The maximum number of records was reached. Increase MAX_NO_ENTRIES if neccessary. |
| 10001 | ERROR_MPLINK_MISSING  | Input Axis has no valid axis infomration. |
| 10002 | ERROR_NOT_FOUND  | The error number was not found within the range of the MAX_NO_SEARCH entries. |
| 10003 | ERROR_ID_MISSING  | Input Error is 0 and there is no pending axis error |

The following constants can be used to adjust the function block.

| Constant | Text |
|---|---|
| MAX_NO_ENTRIES | Maximum number of entries that can be read. |
| MAX_NO_SEARCH | Maximum number of logger entries that are searched for the error number. |
| OVERRIDE | Number of execution per cycle. A higher number will speed up data collection but also increase CPU load. |

<a name="Requirements"></a>
## Requirements
* Automation Studio 4.10
* mapp 5.17

<a name="Revision-History"></a>

## Revision History

#### Version 1.0
- Initial commit
