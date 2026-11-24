import SwiftUI

struct HealthCalcView: View {
    @State private var heightText = ""
    @State private var weightText = ""
    @State private var ageText = ""
    @State private var isMale = true

    private var heightCm: Double? {
        return Double(heightText)
    }

    private var weightKg: Double? {
        return Double(weightText)
    }

    private var age: Double? {
        return Double(ageText)
    }

    private var bmi: Double? {
        guard let h = heightCm, let w = weightKg, h > 0, w > 0 else {
            return nil
        }
        let meters = h / 100
        return w / (meters * meters)
    }

    private var bmiCategory: String {
        guard let value = bmi else {
            return ""
        }
        if value < 18.5 {
            return "偏瘦"
        }
        if value < 24 {
            return "正常"
        }
        if value < 28 {
            return "超重"
        }
        return "肥胖"
    }

    private var waterMl: Double? {
        guard let w = weightKg, w > 0 else {
            return nil
        }
        return w * 30
    }

    private var bmr: Double? {
        guard let h = heightCm, let w = weightKg, let a = age, h > 0, w > 0, a > 0 else {
            return nil
        }
        let base = 10 * w + 6.25 * h - 5 * a
        if isMale {
            return base + 5
        }
        return base - 161
    }

    var body: some View {
        ZStack {
            AppBackground()
            Form {
                Section("身体数据") {
                    HStack {
                        Text("性别")
                        Spacer()
                        Picker("性别", selection: $isMale) {
                            Text("男").tag(true)
                            Text("女").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 140)
                    }
                    HStack {
                        Text("身高")
                        Spacer()
                        TextField("厘米", text: $heightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                            .foregroundStyle(Color.secondary)
                    }
                    HStack {
                        Text("体重")
                        Spacer()
                        TextField("公斤", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                            .foregroundStyle(Color.secondary)
                    }
                    HStack {
                        Text("年龄")
                        Spacer()
                        TextField("岁", text: $ageText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("岁")
                            .foregroundStyle(Color.secondary)
                    }
                }

                Section("结果") {
                    resultRow(title: "BMI", value: bmiText, note: bmiCategory)
                    resultRow(title: "每日建议饮水", value: waterText, note: "约体重×30毫升")
                    resultRow(title: "基础代谢", value: bmrText, note: "静息状态每天消耗")
                }

                Section {
                    Text("以上是通用估算值，个体差异很大，仅供日常参考，不能替代医生的评估。")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("健康计算")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
    }

    private var bmiText: String {
        guard let value = bmi else {
            return "—"
        }
        return String(format: "%.1f", value)
    }

    private var waterText: String {
        guard let value = waterMl else {
            return "—"
        }
        return String(format: "%.0f 毫升", value)
    }

    private var bmrText: String {
        guard let value = bmr else {
            return "—"
        }
        return String(format: "%.0f 千卡/天", value)
    }

    private func resultRow(title: String, value: String, note: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(note)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}
