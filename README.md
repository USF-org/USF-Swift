# USF-Swift
Swift Package for Access USF

## Overview
The **Universal Schedule Format (USF)** is a compact and efficient format for storing school schedules in JSON. This Swift package provides tools to read, modify, validate, and generate USF files. It includes functionalities to manage subjects, periods, and timetables in a structured format, ideal for use in educational scheduling applications.

This package allows you to:
  • Load and decode USF files.  
  • Check if a USF file is valid.  
  • Retrieve timetable entries.  
  • Generate USF files from data.  
  • Add new subjects and timetable entries.  
  • Save USF data to files.  
  • Handle errors with detailed feedback when loading, modifying, or saving USF files.

## Installation

### Swift Package Manager

To integrate USF-Swift into your project using Swift Package Manager:

1. In Xcode, go to **File > Add Packages**.  
2. Enter the repository URL for USF-Swift:  https://github.com/USF-org/USF-Swift
3. Select the desired version or branch and add the package to your project.

### Manual Installation
Download the source files and add them to your project manually.

## Usage

### Importing the Package

```swift
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
let result = addSubject(to: &usf, name: "Physics", simplifiedName: "物理", teacher: "Dr. Wang", room: "102")

switch result {
case .success:
    print("Subject added successfully.")
case .failure(let error):
    print("Error adding subject: \(error)")
}
```

### Add a New Timetable Entry
```
let result = addTimetableEntry(to: &usf, day: 3, weekType: .odd, subjectName: "Physics", period: 2)

switch result {
case .success:
    print("Timetable entry added successfully.")
case .failure(let error):
    print("Error adding timetable entry: \(error)")
}
```

### Generate a USF File
```
if let data = generateUSF(usf: usf) {
    // Save data to file or perform any operation
    print("Generated USF JSON: \(String(data: data, encoding: .utf8) ?? "")")
} else {
    print("Failed to generate USF JSON.")
}
```

### Save the USF File
```
let saveURL = URL(fileURLWithPath: "path/to/save/usf/file.json")
let result = saveUSF(usf, to: saveURL)

switch result {
case .success:
    print("File saved successfully.")
case .failure(let error):
    print("Error saving file: \(error)")
}
```

## Errors Handling
After USF-Swift releases version 1.2.0, we introduces following new error handlings:

	•	USFError.subjectAlreadyExists: Raised when attempting to add a subject that already exists in the file.
 
	•	USFError.timetableEntryAlreadyExists: Raised when attempting to add a timetable entry that already exists.
 
	•	USFError.invalidData: Raised when the data does not meet the required structure or contains invalid values.
 
	•	USFError.failedToGenerateJSON: Raised when the USF file cannot be properly serialized into JSON.

## Contribution
We welcome contributions to the USF Swift Package! Feel free to report an issue or send a Pull Request!

## Licence
This project is licensed under the MIT License - see the LICENSE file for details.
