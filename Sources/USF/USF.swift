import Foundation

// USF 结构体
struct USF: Codable {
    let version: Int
    var subjects: [String: Subject]
    var periods: [[String]]
    var timetable: [TimetableEntry]
    
    struct Subject: Codable {
        let simplifiedName: String
        let teacher: String
        let room: String
        
        enum CodingKeys: String, CodingKey {
            case simplifiedName = "simplified_name"
            case teacher
            case room
        }
    }
    
    struct TimetableEntry: Codable {
        let day: Int
        let weekType: WeekType
        let subjectName: String
        let period: Int
    }
    
    enum WeekType: String, Codable {
        case all, even, odd
    }
}

// 读取 USF 文件
func loadUSF(from fileURL: URL) -> USF? {
    let decoder = JSONDecoder()
    do {
        let data = try Data(contentsOf: fileURL)
        let usf = try decoder.decode(USF.self, from: data)
        return usf
    } catch {
        print("Error loading USF: \(error)")
        return nil
    }
}

// 检查 USF 文件是否有效
func isValidUSF(fileURL: URL) -> Bool {
    return loadUSF(from: fileURL) != nil
}

// 获取课表信息
func getTimetable(from usf: USF) -> [USF.TimetableEntry] {
    return usf.timetable
}

// 生成 USF JSON 数据
func generateUSF(usf: USF) -> Data? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let data = try encoder.encode(usf)
        return data
    } catch {
        print("Error encoding USF: \(error)")
        return nil
    }
}

// 在已有 USF 中增加学科
func addSubject(to usf: inout USF, name: String, simplifiedName: String, teacher: String, room: String) {
    let newSubject = USF.Subject(simplifiedName: simplifiedName, teacher: teacher, room: room)
    usf.subjects[name] = newSubject
}

// 在已有 USF 中增加课程信息
func addTimetableEntry(to usf: inout USF, day: Int, weekType: USF.WeekType, subjectName: String, period: Int) {
    let newEntry = USF.TimetableEntry(day: day, weekType: weekType, subjectName: subjectName, period: period)
    usf.timetable.append(newEntry)
}

// 保存 USF 文件
func saveUSF(_ usf: USF, to fileURL: URL) {
    guard let data = generateUSF(usf: usf) else {
        print("Failed to generate USF data")
        return
    }
    
    do {
        try data.write(to: fileURL)
        print("File saved successfully")
    } catch {
        print("Error saving file: \(error)")
    }
}
