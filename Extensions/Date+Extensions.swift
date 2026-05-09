// Date+Extensions.swift
// 日期格式化：相对时间字符串和绝对时间字符串

import Foundation

extension Date {
    /// 相对时间字符串
    /// 少于 1 天显示"x 小时前"，少于 1 月显示"x 天前"，少于 1 年显示"x 月前"，否则"x 年前"
    var relativeString: String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: self,
            to: now
        )

        // 优先使用系统 RelativeDateTimeFormatter 获取自然语言相对时间
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.localizedString(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: components.minute
        ))

        if let years = components.year, years >= 1 {
            return "\(years) 年前"
        }
        if let months = components.month, months >= 1 {
            return "\(months) 月前"
        }
        if let days = components.day, days >= 1 {
            return "\(days) 天前"
        }
        if let hours = components.hour, hours >= 1 {
            return "\(hours) 小时前"
        }
        if let minutes = components.minute, minutes >= 1 {
            return "\(minutes) 分钟前"
        }
        return "刚刚"
    }

    /// 绝对时间字符串，格式如"2024/3/15 14:32"
    var absoluteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d HH:mm"
        return formatter.string(from: self)
    }
}
