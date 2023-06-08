// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum S {
  /// Plural format key: "%#@days@"
  internal static func amountOfDay(_ p1: Int) -> String {
    return S.tr("Localizable", "amountOfDay", p1, fallback: "Plural format key: \"%#@days@\"")
  }
  /// Отменить
  internal static let cancel = S.tr("Localizable", "cancel", fallback: "Отменить")
  /// Создать
  internal static let create = S.tr("Localizable", "create", fallback: "Создать")
  /// Удалить
  internal static let delete = S.tr("Localizable", "delete", fallback: "Удалить")
  /// Готово
  internal static let done = S.tr("Localizable", "done", fallback: "Готово")
  /// Редактировать
  internal static let edit = S.tr("Localizable", "edit", fallback: "Редактировать")
  /// Каждый день
  internal static let everyDay = S.tr("Localizable", "everyDay", fallback: "Каждый день")
  /// Пт
  internal static let fri = S.tr("Localizable", "fri", fallback: "Пт")
  /// Пятница
  internal static let friday = S.tr("Localizable", "friday", fallback: "Пятница")
  /// Пн
  internal static let mon = S.tr("Localizable", "mon", fallback: "Пн")
  /// Понедельник
  internal static let monday = S.tr("Localizable", "monday", fallback: "Понедельник")
  /// Закрепить
  internal static let pin = S.tr("Localizable", "pin", fallback: "Закрепить")
  /// Сб
  internal static let sat = S.tr("Localizable", "sat", fallback: "Сб")
  /// Суббота
  internal static let saturday = S.tr("Localizable", "saturday", fallback: "Суббота")
  /// Сохранить
  internal static let save = S.tr("Localizable", "save", fallback: "Сохранить")
  /// Вс
  internal static let sun = S.tr("Localizable", "sun", fallback: "Вс")
  /// Воскресенье
  internal static let sunday = S.tr("Localizable", "sunday", fallback: "Воскресенье")
  /// Чт
  internal static let thu = S.tr("Localizable", "thu", fallback: "Чт")
  /// Четверг
  internal static let thursday = S.tr("Localizable", "thursday", fallback: "Четверг")
  /// Вт
  internal static let tue = S.tr("Localizable", "tue", fallback: "Вт")
  /// Вторник
  internal static let tuesday = S.tr("Localizable", "tuesday", fallback: "Вторник")
  /// Открепить
  internal static let unpin = S.tr("Localizable", "unpin", fallback: "Открепить")
  /// Ср
  internal static let wed = S.tr("Localizable", "wed", fallback: "Ср")
  /// Среда
  internal static let wednesday = S.tr("Localizable", "wednesday", fallback: "Среда")
  internal enum Alert {
    internal enum DeleteCategory {
      /// Уверены что хотите удалить категорию?
      internal static let message = S.tr("Localizable", "alert.deleteCategory.message", fallback: "Уверены что хотите удалить категорию?")
    }
    internal enum DeleteNonEmptyCategory {
      /// Если вы удалите категорию, все трекеры тоже исчезнут
      internal static let message = S.tr("Localizable", "alert.deleteNonEmptyCategory.message", fallback: "Если вы удалите категорию, все трекеры тоже исчезнут")
      /// В этой категории есть незавершенные трекеры
      internal static let title = S.tr("Localizable", "alert.deleteNonEmptyCategory.title", fallback: "В этой категории есть незавершенные трекеры")
    }
    internal enum DeleteTracker {
      /// Уверены что хотите удалить трекер?
      internal static let title = S.tr("Localizable", "alert.deleteTracker.title", fallback: "Уверены что хотите удалить трекер?")
    }
  }
  internal enum Button {
    internal enum IrregularEvent {
      /// Нерегулярное событие
      internal static let title = S.tr("Localizable", "button.IrregularEvent.title", fallback: "Нерегулярное событие")
    }
    internal enum AddNewCategory {
      /// Добавить категорию
      internal static let title = S.tr("Localizable", "button.addNewCategory.title", fallback: "Добавить категорию")
    }
    internal enum Habit {
      /// Привычка
      internal static let title = S.tr("Localizable", "button.habit.title", fallback: "Привычка")
    }
  }
  internal enum Category {
    /// Категория
    internal static let title = S.tr("Localizable", "category.title", fallback: "Категория")
  }
  internal enum Color {
    /// Цвет
    internal static let title = S.tr("Localizable", "color.title", fallback: "Цвет")
  }
  internal enum Emoji {
    /// Emoji
    internal static let title = S.tr("Localizable", "emoji.title", fallback: "Emoji")
  }
  internal enum Filter {
    /// Все трекеры
    internal static let allTrackers = S.tr("Localizable", "filter.allTrackers", fallback: "Все трекеры")
    /// Завершенные
    internal static let completed = S.tr("Localizable", "filter.completed", fallback: "Завершенные")
    /// Не завершенные
    internal static let notCompleted = S.tr("Localizable", "filter.notCompleted", fallback: "Не завершенные")
    /// Фильтры
    internal static let title = S.tr("Localizable", "filter.title", fallback: "Фильтры")
    /// Трекеры на сегодня
    internal static let trackersForToday = S.tr("Localizable", "filter.trackersForToday", fallback: "Трекеры на сегодня")
  }
  internal enum NavBar {
    internal enum AddNewCategory {
      /// Введите название категории
      internal static let title = S.tr("Localizable", "navBar.addNewCategory.title", fallback: "Введите название категории")
    }
    internal enum CreateTracker {
      /// Создание трекера
      internal static let title = S.tr("Localizable", "navBar.createTracker.title", fallback: "Создание трекера")
    }
    internal enum EditHabit {
      /// Редактирование привычки
      internal static let title = S.tr("Localizable", "navBar.editHabit.title", fallback: "Редактирование привычки")
    }
    internal enum EditIrregularEvent {
      /// Редактирование нерегулярного события
      internal static let title = S.tr("Localizable", "navBar.editIrregularEvent.title", fallback: "Редактирование нерегулярного события")
    }
    internal enum NewHabit {
      /// Новая привычка
      internal static let title = S.tr("Localizable", "navBar.newHabit.title", fallback: "Новая привычка")
    }
    internal enum NewIrregularEvent {
      /// Новое нерегулярное событие
      internal static let title = S.tr("Localizable", "navBar.newIrregularEvent.title", fallback: "Новое нерегулярное событие")
    }
  }
  internal enum Onboarding {
    /// Отслеживайте только то, что хотите
    internal static let firstTitle = S.tr("Localizable", "onboarding.firstTitle", fallback: "Отслеживайте только то, что хотите")
    /// Даже если это не литры воды и йога
    internal static let secondTitle = S.tr("Localizable", "onboarding.secondTitle", fallback: "Даже если это не литры воды и йога")
    internal enum Button {
      /// Вот это технологии!
      internal static let title = S.tr("Localizable", "onboarding.button.title", fallback: "Вот это технологии!")
    }
  }
  internal enum Schedule {
    /// Расписание
    internal static let title = S.tr("Localizable", "schedule.title", fallback: "Расписание")
  }
  internal enum StackView {
    internal enum AddCategory {
      /// Привычки и события можно объединить по смыслу
      internal static let title = S.tr("Localizable", "stackView.addCategory.title", fallback: "Привычки и события можно объединить по смыслу")
    }
    internal enum NotFoundTrackers {
      /// Ничего не найдено
      internal static let title = S.tr("Localizable", "stackView.notFoundTrackers.title", fallback: "Ничего не найдено")
    }
    internal enum NotStatistic {
      /// Анализировать пока нечего
      internal static let title = S.tr("Localizable", "stackView.notStatistic.title", fallback: "Анализировать пока нечего")
    }
    internal enum StartTracking {
      /// Что будем отслеживать?
      internal static let title = S.tr("Localizable", "stackView.startTracking.title", fallback: "Что будем отслеживать?")
    }
  }
  internal enum Statistic {
    /// Среднее значение
    internal static let averageValue = S.tr("Localizable", "statistic.averageValue", fallback: "Среднее значение")
    /// Лучший период
    internal static let bestPeriod = S.tr("Localizable", "statistic.bestPeriod", fallback: "Лучший период")
    /// Трекеров завершено
    internal static let completedTrackers = S.tr("Localizable", "statistic.completedTrackers", fallback: "Трекеров завершено")
    /// Идеальные дни
    internal static let perfectDays = S.tr("Localizable", "statistic.perfectDays", fallback: "Идеальные дни")
    /// Статистика
    internal static let title = S.tr("Localizable", "statistic.title", fallback: "Статистика")
  }
  internal enum TextField {
    internal enum NewHabit {
      /// Введите название трекера
      internal static let placeholder = S.tr("Localizable", "textField.newHabit.placeholder", fallback: "Введите название трекера")
    }
    internal enum Search {
      /// Поиск
      internal static let placeholder = S.tr("Localizable", "textField.search.placeholder", fallback: "Поиск")
    }
  }
  internal enum Trackers {
    /// Трекеры
    internal static let title = S.tr("Localizable", "trackers.title", fallback: "Трекеры")
  }
  internal enum WarningMessage {
    /// Ограничение 38 символов
    internal static let title = S.tr("Localizable", "warningMessage.title", fallback: "Ограничение 38 символов")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension S {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
