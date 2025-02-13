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
    
    // 校验学科是否已存在
    func subjectExists(name: String) -> Bool {
        return subjects.keys.contains(name)
    }
    
    // 校验课程表项是否已存在
    func timetableEntryExists(day: Int, weekType: WeekType, subjectName: String, period: Int) -> Bool {
        return timetable.contains { entry in
            entry.day == day && entry.weekType == weekType && entry.subjectName == subjectName && entry.period == period
        }
    }
}

// 错误类型定义
enum USFError: Error {
    case fileNotFound
    case decodingFailed
    case encodingFailed
    case invalidData
    case subjectAlreadyExists
    case timetableEntryAlreadyExists
}

// 读取 USF 文件
func loadUSF(from fileURL: URL) -> Result<USF, USFError> {
    let decoder = JSONDecoder()
    do {
        let data = try Data(contentsOf: fileURL)
        let usf = try decoder.decode(USF.self, from: data)
        return .success(usf)
    } catch {
        print("Error loading USF: \(error)")
        return .failure(.decodingFailed)
    }
}

// 检查 USF 文件是否有效
func isValidUSF(fileURL: URL) -> Bool {
    switch loadUSF(from: fileURL) {
    case .success(_):
        return true
    case .failure(_):
        return false
    }
}

// 获取课表信息
func getTimetable(from usf: USF) -> [USF.TimetableEntry] {
    return usf.timetable
}

// 生成 USF JSON 数据
func generateUSF(usf: USF) -> Result<Data, USFError> {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let data = try encoder.encode(usf)
        return .success(data)
    } catch {
        print("Error encoding USF: \(error)")
        return .failure(.encodingFailed)
    }
}

// 在已有 USF 中增加学科
func addSubject(to usf: inout USF, name: String, simplifiedName: String, teacher: String, room: String) -> Result<Void, USFError> {
    if usf.subjectExists(name: name) {
        return .failure(.subjectAlreadyExists)  // 如果学科已存在，返回错误
    }
    let newSubject = USF.Subject(simplifiedName: simplifiedName, teacher: teacher, room: room)
    usf.subjects[name] = newSubject
    return .success(())
}

// 在已有 USF 中增加课程信息
func addTimetableEntry(to usf: inout USF, day: Int, weekType: USF.WeekType, subjectName: String, period: Int) -> Result<Void, USFError> {
    if usf.timetableEntryExists(day: day, weekType: weekType, subjectName: subjectName, period: period) {
        return .failure(.timetableEntryAlreadyExists)  // 如果课程项已存在，返回错误
    }
    let newEntry = USF.TimetableEntry(day: day, weekType: weekType, subjectName: subjectName, period: period)
    usf.timetable.append(newEntry)
    return .success(())
}

// 保存 USF 文件
func saveUSF(_ usf: USF, to fileURL: URL) -> Result<Void, USFError> {
    switch generateUSF(usf: usf) {
    case .success(let data):
        do {
            try data.write(to: fileURL)
            print("File saved successfully")
            return .success(())
        } catch {
            print("Error saving file: \(error)")
            return .failure(.invalidData)
        }
    case .failure(let error):
        return .failure(error)
    }
}
