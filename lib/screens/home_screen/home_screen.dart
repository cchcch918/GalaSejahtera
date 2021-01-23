import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gala_sejahtera/models/auth_credentials.dart';
import 'package:gala_sejahtera/models/daily_cases.dart';
import 'package:gala_sejahtera/models/general_cases.dart';
import 'package:gala_sejahtera/screens/login_screen/login_screen.dart';
import 'package:gala_sejahtera/services/rest_api_services.dart';
import 'package:gala_sejahtera/widgets/custom_autocomplete.dart';
import 'package:gala_sejahtera/widgets/display_box.dart';
import 'package:gala_sejahtera/widgets/rounded_button.dart';
import 'package:provider/provider.dart';

import 'covid_bar_chart.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RestApiServices restApiServices = RestApiServices();
  String selected = "";
  TextEditingController controller = TextEditingController();
  int totalConfirmed = 0, totalActive = 0;

  @override
  void initState() {
    super.initState();
    fetchCases();
  }

  void fetchCases() async {
    GeneralCases generalCasesRecords =
        await restApiServices.fetchGeneralCases();
    setState(() {
      totalConfirmed = generalCasesRecords.totalConfirmed;
      totalActive = generalCasesRecords.activeCases;
    });
  }

  Widget generateButton() {
    String accessToken = Provider.of<AuthCredentials>(context).accessToken;
    if (accessToken == null) {
      return RoundedButton(
        title: 'Login For More Features',
        color: Colors.black,
        onPressed: () {
          Navigator.pushNamed(context, LoginScreen.id);
        },
      );
    } else
      return RoundedButton(
        title: 'Logout',
        color: Colors.redAccent,
        onPressed: () async {
          //logout method
          await restApiServices.userLogout(accessToken: accessToken);
          Provider.of<AuthCredentials>(context, listen: false).setDefault();
          Navigator.pushNamed(context, LoginScreen.id);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: <Widget>[
            DisplayBox(
              title: totalConfirmed.toString(),
              description: "Total Cases",
            ),
            DisplayBox(
              title: totalActive.toString(),
              description: "Active Cases",
            ),
          ]),
          CovidBarChart(),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: generateButton(),
            ),
          )
        ],
      ),
    );
  }
}
