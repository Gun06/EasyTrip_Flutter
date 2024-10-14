import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DdayBottomSheet extends StatelessWidget {
  final DateTime startDate;
  final VoidCallback onClose;

  DdayBottomSheet({required this.startDate, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'D-day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Enter a date and add a description'),
                SizedBox(height: 16),
                _buildDateDisplay(),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter a description',
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("1 day from the setting date"),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    child: Text('Complete'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today),
          SizedBox(width: 8),
          Text(
            DateFormat('yyyy/MM/dd').format(startDate),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
