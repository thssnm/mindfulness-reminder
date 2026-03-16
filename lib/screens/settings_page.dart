import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfulness_reminder/text/app_strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedInterval = 151; // Default
  int startHour = 8;
  int endHour = 22;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInterval = prefs.getInt('notification_interval') ?? 151;
      startHour = prefs.getInt('start_hour') ?? 8;
      endHour = prefs.getInt('end_hour') ?? 22;
      isLoading = false;
    });
  }

  Future<void> _saveInterval(int interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_interval', interval);
    setState(() {
      selectedInterval = interval;
    });
  }

  Future<void> _saveTimeWindow(int start, int end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('start_hour', start);
    await prefs.setInt('end_hour', end);
    setState(() {
      startHour = start;
      endHour = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A4A4A),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9CA3AF)),
          onPressed: () =>
              Navigator.pop(context, true), // true = settings changed
        ),
        title: Text(
          AppStrings.settings,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intervall-Einstellung
            Text(
              AppStrings.notificationInterval,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            _buildIntervalOption(60, AppStrings.everyHour),
            _buildIntervalOption(90, AppStrings.every90Minutes),
            _buildIntervalOption(120, AppStrings.every2Hours),
            _buildIntervalOption(151, AppStrings.every2AndHalfHours),
            _buildIntervalOption(180, AppStrings.every3Hours),

            const SizedBox(height: 32),

            // Zeitfenster
            Text(
              AppStrings.activeTimeWindow,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: AppStrings.startTime,
                    value: startHour,
                    onChanged: (newValue) {
                      if (newValue < endHour) {
                        _saveTimeWindow(newValue, endHour);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(
                    label: AppStrings.endTime,
                    value: endHour,
                    onChanged: (newValue) {
                      if (newValue > startHour) {
                        _saveTimeWindow(startHour, newValue);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              AppStrings.settingsNote,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalOption(int minutes, String label) {
    final bool isSelected = selectedInterval == minutes;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _saveInterval(minutes),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF374151),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF4B5563),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF374151)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1F2937),
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            items: List.generate(24, (index) => index)
                .map((hour) => DropdownMenuItem(
                      value: hour,
                      child: Text('$hour:00'),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}
