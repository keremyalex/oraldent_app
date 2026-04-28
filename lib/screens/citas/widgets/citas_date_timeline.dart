import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class CitasDateTimeline extends StatelessWidget {
  const CitasDateTimeline({
    required this.selectedDate,
    required this.onDateChange,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChange;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return EasyDateTimeLine(
      initialDate: selectedDate,
      locale: 'es_ES',
      activeColor: AppColors.primary,
      onDateChange: onDateChange,
      headerProps: EasyHeaderProps(
        showMonthPicker: true,
        monthPickerType: MonthPickerType.switcher,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        selectedDateStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.inverted,
        ),
        monthStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      timeLineProps: const EasyTimeLineProps(
        hPadding: 24,
        separatorPadding: 10,
      ),
      dayProps: EasyDayProps(
        width: 64,
        height: 82,
        dayStructure: DayStructure.dayStrDayNum,
        todayHighlightStyle: TodayHighlightStyle.withBackground,
        todayHighlightColor: AppColors.tertiary.withValues(alpha: 0.16),
        activeDayStyle: DayStyle(
          borderRadius: 16,
          dayNumStyle: textTheme.displayLarge?.copyWith(
            fontSize: 22,
            color: Colors.white,
            height: 1,
          ),
          dayStrStyle: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        inactiveDayStyle: DayStyle(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          dayNumStyle: textTheme.displayLarge?.copyWith(
            fontSize: 21,
            color: AppColors.inverted,
            height: 1,
          ),
          dayStrStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.secondary,
            fontSize: 12,
          ),
        ),
        todayStyle: DayStyle(
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.tertiary.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
