# USF-Swift
Swift Package for Access USF

## Overview
The **Universal Schedule Format (USF)** is a compact and efficient format for storing school schedules in JSON. This Swift package provides tools to read, modify, validate, and generate USF files. It includes functionalities to manage subjects, periods, and timetables in a structured format, ideal for use in educational scheduling applications.

This package allows you to:
	•	Load and decode USF files.
	•	Check if a USF file is valid.
	•	Retrieve timetable entries.
	•	Generate USF files from data.
	•	Add new subjects and timetable entries.
	•	Save USF data to files.

## Installation

### Swift Package Manager

To integrate USF-Swift into your project, using Swift Package Manager:

1. In Xcode, go to **File > Add Packages**.  
2. Enter the repository URL for USF-Swift:  https://github.com/USF-org/USF-Swift
3. Select the desired version or branch and add the package to your project.

### Manual Installation
Download the source files and add them to your project manually.

## Usage

### Importing the Package

```
import USF
```

### Loading a USF file

```
let fileURL = URL(fileURLWithPath: "path/to/your/usf/file.json")
if let usf = loadUSF(from: fileURL) {
    print("USF Loaded: \(usf)")
} else {
    print("Failed to load USF.")
}
```

### Check if a USF file is valid

```
let isValid = isValidUSF(fileURL: fileURL)
print("Is the USF file valid? \(isValid)")
```

### Get Timetable Entries

```
let timetable = getTimetable(from: usf)
for entry in timetable {
    print("Day: \(entry.day), Subject: \(entry.subjectName), Period: \(entry.period)")
}
```

### Add a New Subject

```
var usf = loadUSF(from: fileURL)!
addSubject(to: &usf, name: "Physics", simplifiedName: "物理", teacher: "Dr. Wang", room: "102")
```

### Add a New Timetable Entry

```
addTimetableEntry(to: &usf, day: 3, weekType: .odd, subjectName: "Physics", period: 2)
```

### Generate a USF File

```
if let data = generateUSF(usf: usf) {
    // Save data to file or perform any operation
}
```

### Save the USF File
```
let saveURL = URL(fileURLWithPath: "path/to/save/usf/file.json")
saveUSF(usf, to: saveURL)
```

## Contribution
We welcome contributions to the USF Swift Package! To contribute, please fork the repository and submit a pull request. Be sure to write tests for any new features or bug fixes.

# Licence
This project is licensed under the MIT License - see the LICENSE file for details.
