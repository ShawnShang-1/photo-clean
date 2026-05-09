// BatchSizeEditorView.swift
// 每组数量调整 stepper，范围 5~100，持久化到 UserDefaults
import SwiftUI

struct BatchSizeEditorView: View {
    @Binding var batchSize: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $batchSize, in: 5...100, step: 5) {
                        HStack {
                            Text("每组数量")
                            Spacer()
                            Text("\(batchSize) 张")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("批量分组设置")
                } footer: {
                    Text("每组包含的照片数量，范围 5~100 张。\n数值越大，每次删除的候选越多。")
                }
            }
            .navigationTitle("调整每组数量")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        // 保存到 UserDefaults
                        UserDefaults.standard.set(batchSize, forKey: "quliu.batchSize")
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    BatchSizeEditorView(batchSize: .constant(20))
}
