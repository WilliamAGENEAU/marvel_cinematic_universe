// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:marvel_cinematic_universe/helpers/utilities.dart';

Widget ASide(String email, BuildContext context) {
  return Column(
    children: [
      Expanded(
        flex: 1,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    Text(
                      email,
                      style: TextStyle(
                        color: DefaultColors.baby_white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
                leading: Icon(
                  FontAwesome5.globe_asia,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Text("Ordre MCU", style: TextStyle(fontSize: 14)),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: () {
                  ShowToast('Comics screen is work in progress.');
                },
                leading: Icon(
                  FontAwesome5.book,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    Text("Comics", style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: DefaultColors.danger,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      child: Text("WIP", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: () {
                  ShowToast('Characters screen is work in progress.');
                },
                leading: Icon(
                  FontAwesome5.users,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    Text("Characters", style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: DefaultColors.danger,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      child: Text("WIP", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: () {
                  ShowToast('Stories screen is work in progress.');
                },
                leading: Icon(
                  FontAwesome5.history,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    Text("Stories", style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: DefaultColors.danger,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      child: Text("WIP", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
            ],
          ),
        ),
      ),
      Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(bottom: Pad.sm, left: Pad.sm),
        child: Text(
          'v1.0.0',
          style: TextStyle(color: DefaultColors.baby_white),
        ),
      ),
    ],
  );
}
