import XCTest
@testable import USF

final class USFTests: XCTestCase {
    
    // 测试 USF JSON 解析
    func testLoadUSF() {
        let jsonString = """
        {
            "version": 1,
            "subjects": {
                "Math": {
                    "simplified_name": "数学",
                    "teacher": "张老师",
                    "room": "101"
                }
            },
            "periods": [
                ["08:00:00", "08:45:00"],
                ["09:00:00", "09:45:00"]
            ],
            "timetable": [
                {
                    "day": 1,
                    "weekType": "all",
                    "subjectName": "Math",
                    "period": 1
                }
            ]
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let usf = try decoder.decode(USF.self, from: jsonData)
            XCTAssertEqual(usf.version, 1)
            XCTAssertEqual(usf.subjects["Math"]?.simplifiedName, "数学")
            XCTAssertEqual(usf.subjects["Math"]?.teacher, "张老师")
            XCTAssertEqual(usf.subjects["Math"]?.room, "101")
            XCTAssertEqual(usf.periods.count, 2)
            XCTAssertEqual(usf.timetable.count, 1)
            XCTAssertEqual(usf.timetable[0].day, 1)
            XCTAssertEqual(usf.timetable[0].weekType, .all)
            XCTAssertEqual(usf.timetable[0].subjectName, "Math")
            XCTAssertEqual(usf.timetable[0].period, 1)
        } catch {
            XCTFail("Failed to decode USF: \(error)")
        }
    }
    
    // 测试 USF 文件的有效性检查
    func testIsValidUSF() {
        let validJsonString = """
        {
            "version": 1,
            "subjects": {},
            "periods": [],
            "timetable": []
        }
        """
        let invalidJsonString = """
        {
            "version": 1,
            "subjects": {}
        }
        """
        
        let validFileURL = writeTempFile(named: "valid.usf", content: validJsonString)
        let invalidFileURL = writeTempFile(named: "invalid.usf", content: invalidJsonString)
        
        XCTAssertTrue(isValidUSF(fileURL: validFileURL))
        XCTAssertFalse(isValidUSF(fileURL: invalidFileURL))
    }
    
    // 测试获取课表信息
    func testGetTimetable() {
        let usf = USF(version: 1, subjects: [:], periods: [], timetable: [
            USF.TimetableEntry(day: 1, weekType: .all, subjectName: "Math", period: 1)
        ])
        let timetable = getTimetable(from: usf)
        XCTAssertEqual(timetable.count, 1)
        XCTAssertEqual(timetable[0].day, 1)
        XCTAssertEqual(timetable[0].weekType, .all)
        XCTAssertEqual(timetable[0].subjectName, "Math")
        XCTAssertEqual(timetable[0].period, 1)
    }
    
    // 测试 USF 生成 JSON
    func testGenerateUSF() {
        let usf = USF(version: 1, subjects: [:], periods: [], timetable: [])
        let result = generateUSF(usf: usf)
        
        switch result {
        case .success(let data):
            XCTAssertNotNil(data)
        case .failure(let error):
            XCTFail("Failed to generate USF: \(error)")
        }
    }
    
    // 测试添加学科
    func testAddSubject() {
        var usf = USF(version: 1, subjects: [:], periods: [], timetable: [])
        let result = addSubject(to: &usf, name: "Physics", simplifiedName: "物理", teacher: "李老师", room: "102")
        
        switch result {
        case .success:
            XCTAssertEqual(usf.subjects["Physics"]?.simplifiedName, "物理")
            XCTAssertEqual(usf.subjects["Physics"]?.teacher, "李老师")
            XCTAssertEqual(usf.subjects["Physics"]?.room, "102")
        case .failure(let error):
            XCTFail("Failed to add subject: \(error)")
        }
    }
    
    // 测试添加已有学科
    func testAddSubjectAlreadyExists() {
        var usf = USF(version: 1, subjects: ["Math": USF.Subject(simplifiedName: "数学", teacher: "张老师", room: "101")], periods: [], timetable: [])
        let result = addSubject(to: &usf, name: "Math", simplifiedName: "数学", teacher: "张老师", room: "101")
        
        switch result {
        case .success:
            XCTFail("Subject should already exist")
        case .failure(let error):
            XCTAssertEqual(error, USFError.subjectAlreadyExists)
        }
    }
    
    // 测试添加课程信息
    func testAddTimetableEntry() {
        var usf = USF(version: 1, subjects: ["Math": USF.Subject(simplifiedName: "数学", teacher: "张老师", room: "101")], periods: [], timetable: [])
        let result = addTimetableEntry(to: &usf, day: 2, weekType: .even, subjectName: "Math", period: 2)
        
        switch result {
        case .success:
            XCTAssertEqual(usf.timetable.count, 1)
            XCTAssertEqual(usf.timetable[0].day, 2)
            XCTAssertEqual(usf.timetable[0].weekType, .even)
            XCTAssertEqual(usf.timetable[0].subjectName, "Math")
            XCTAssertEqual(usf.timetable[0].period, 2)
        case .failure(let error):
            XCTFail("Failed to add timetable entry: \(error)")
        }
    }
    
    // 测试添加已有课程表项
    func testAddTimetableEntryAlreadyExists() {
        var usf = USF(version: 1, subjects: ["Math": USF.Subject(simplifiedName: "数学", teacher: "张老师", room: "101")], periods: [], timetable: [
            USF.TimetableEntry(day: 1, weekType: .all, subjectName: "Math", period: 1)
        ])
        
        let result = addTimetableEntry(to: &usf, day: 1, weekType: .all, subjectName: "Math", period: 1)
        
        switch result {
        case .success:
            XCTFail("Timetable entry should already exist")
        case .failure(let error):
            XCTAssertEqual(error, USFError.timetableEntryAlreadyExists)
        }
    }
    
    // 测试保存文件
    func testSaveUSF() {
        let usf = USF(version: 1, subjects: [:], periods: [], timetable: [])
        let fileURL = writeTempFile(named: "test.usf", content: "")
        
        switch saveUSF(usf, to: fileURL) {
        case .success:
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        case .failure(let error):
            XCTFail("Failed to save USF file: \(error)")
        }
    }
    
    // ** 辅助方法 **
    // 用于创建临时文件
    private func writeTempFile(named fileName: String, content: String) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to write temp file: \(error)")
        }
        
        return fileURL
    }
}
