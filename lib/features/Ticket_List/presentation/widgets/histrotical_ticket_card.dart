import 'package:flutter/material.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';

class HistoricalTicketCard extends StatelessWidget {
  clsRequest request;
  HistoricalTicketCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFFF8FAFC),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(request.getWarshaIcon, color: Colors.lightBlue[100]),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                      request.description,
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                        Text("Completed", style: TextStyle(color: Colors.green[600])),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                request.formatedDate,
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
