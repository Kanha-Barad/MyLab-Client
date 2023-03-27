import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'AllBottomNavBars.dart';
import 'Business.dart';
import 'ClientLogin.dart';
import 'ClientProfile.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

TextEditingController _Mobile_NoController = TextEditingController();
TextEditingController _billnoController = TextEditingController();

class ClientDashboard extends StatefulWidget {
  // String empID = "0";
  // salesManagerDashboard(String iEmpid) {
  //   empID = iEmpid;
  //   this.empID = iEmpid;
  // }

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  // String empID = "0";
  // _salesManagerDashboardState(String iEmpid) {
  //   this.empID = iEmpid;
  // }
  String date = "";
  // DateTimeRange? selectedDate;

  _selectDashBoardDate(BuildContext context) async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: context,
      // initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
      saveText: 'Done',
    );
    //  if (selected != null && selected != selectedDate) {
    setState(() {
      //  selectedDate = selected;
      //  globals.selectDate = selected as String;
      globals.fromDate = selected!.start.toString().split(' ')[0];
      globals.ToDate = selected.end.toString().split(' ')[0];
      login(globals.controllerUserName.toString(),
          globals.controllerPassword.toString(), context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => ClientDashboard()));
    });
    // }
  }

  login(username, password, BuildContext context) async {
    var isLoading = true;

    Map data = {
      "user_name": username,
      "password": password,
      "from_dt": globals.fromDate,
      "to_dt": globals.ToDate,
      "connection": globals.Connection_Flag
      //"Server_Flag":""
    };
    print(data.toString());
    final response =
        await http.post(Uri.parse(globals.API_url + '/MobileSales/Login'),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded"
            },
            body: data,
            encoding: Encoding.getByName("utf-8"));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);

      if (resposne["message"] != "Invalid Username or Password") {
        print(resposne["Data"]);
        Map<String, dynamic> user = resposne['Data'][0];

        print(user['USER_ID']);

        String empID = user['REFERENCE_ID'].toString();
        globals.loginEmpid = user['REFERENCE_ID'].toString();
        globals.statusvisit = user['LOCK_STATUS'].toString();
        globals.MailId = user['EMAIL_ID'].toString();
        // globals.EmpName = user['EMP_NAME'].toString();
        globals.clientdata = resposne['Data'][0];
        globals.clientName = user['COMPANY_NAME'].toString();
        //if (globals.clientdata["AMOUNT"].toString() == null){ globals.clientdata["AMOUNT"].toString()="Not Specified.";}
        // if (user['REFERENCE_TYPE_ID'].toString() == '8') {
        //   globals.selectedClientid = globals.loginEmpid;
        //   Navigator.push(context,
        //       MaterialPageRoute(builder: ((context) => ClientProfile())));
        // } else {
        //   //  globals.sessionid = user['session_id'].toString();
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientDashboard()),
          );
          // }
        });
      } else {
        errormsg();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // globals.fromDate = '';
    // globals.ToDate = '';
    Map<String, double> todayData = {
      "Payments":
          double.parse(globals.clientdata["DAY_WISE_PAYMENTAMOUNT"].toString()),
      "Business": double.parse(
          globals.clientdata["DAY_WISE_BUSINESSAMOUNT"].toString()),
      // "Xamarin": 2,
      // "Ionic": 2,
    };
    Map<String, double> monthlyData = {
      "Payments": double.parse(
          globals.clientdata["MONTH_WISE_PAYMENTAMOUNT"].toString()),
      "Business": double.parse(
          globals.clientdata["MONTH_WISE_BUSINESSAMOUNT"].toString()),
      // "Xamarin": 2,
      // "Ionic": 2,
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Builder(
                builder: (context) => IconButton(
                  icon: Image(image: NetworkImage(globals.Logo)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            Text('Client Dashboard'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.date_range_outlined),
              onPressed: () {
                _selectDashBoardDate(context);
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xff123456),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xff123456),
                image: DecorationImage(
                    image: AssetImage("assets/gold.jpg"), fit: BoxFit.cover),
              ),
              child: Container(
                child: Column(
                  children: [
                    Text(
                      'Logged in as Client',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image(image: NetworkImage(globals.Logo)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      globals.clientdata["COMPANY_NAME"],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      globals.clientdata["EMAIL_ID"],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientLogin()),
                  );
                },
                leading: Icon(Icons.settings_power_outlined,
                    color: Color.fromARGB(255, 19, 102, 170)),
                title: Text("Log Out"))
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
            child: Container(
          color: const Color.fromARGB(255, 250, 248, 248),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                child: InkWell(
                  onTap: () {
                    globals.selectedClientid =
                        globals.clientdata["REFERENCE_ID"].toString();
                    globals.clientName =
                        globals.clientdata["COMPANY_NAME"].toString();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => ClientProfile(0))));
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8, 0.0, 0.0, 6.0),
                            child: Row(
                              children: [
                                Text(
                                  globals.clientdata["COMPANY_NAME"],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                                Spacer(),
                                (globals.statusvisit.toString() == "N")
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.lock_open_rounded,
                                            size: 18,
                                            color: Colors.green,
                                          ),
                                          Icon(
                                            Icons.double_arrow_outlined,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Icon(
                                            Icons.lock_open_rounded,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          Icon(
                                            Icons.double_arrow_outlined,
                                            size: 22,
                                            color: Colors.red,
                                          ),
                                        ],
                                      )
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0.0, 0.0, 2.0),
                          child: Row(
                            children: [
                              Text(
                                (globals.clientdata["MOBILE_PHONE"] == null)
                                    ? "null"
                                    : globals.clientdata["MOBILE_PHONE"]
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0.0, 0.0, 2.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 320,
                                child: Text(
                                  globals.clientdata["ADDRESS1"],
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Today",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: PieChart(
                                  dataMap: todayData,
                                  chartLegendSpacing: 20,
                                  initialAngleInDegree: 180,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 3.5,
                                  legendOptions: const LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValuesInPercentage: true,
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    //  showChartValuesInPercentage: true,
                                    showChartValuesOutside: true,
                                    decimalPlaces: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                "Monthly",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: PieChart(
                                  dataMap: monthlyData,
                                  chartLegendSpacing: 20,
                                  initialAngleInDegree: 130,
                                  ringStrokeWidth: 0,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 3.5,
                                  legendOptions: const LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    //     showChartValuesInPercentage: true,
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    showChartValuesInPercentage: true,
                                    showChartValuesOutside: true,
                                    decimalPlaces: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 4.0,
                child: Column(
                  children: [
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Row(
                            children: [
                              Icon(Icons.business_center_outlined,
                                  color: Color.fromARGB(255, 90, 136, 236)),
                              SizedBox(
                                width: 10,
                              ),
                              Text('My Business',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text(
                                  '\u{20B9} ' +
                                      globals.clientdata["USAGE_AMOUNT"]
                                          .toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {
                          globals.fromDate = '';
                          globals.ToDate = '';
                          globals.selectedClientid =
                              globals.clientdata["REFERENCE_ID"].toString();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClientBusiness(
                                      globals.selectedClientid.toString())));
                        }),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Row(
                            children: [
                              Icon(Icons.payments_outlined,
                                  color: Color.fromARGB(255, 163, 230, 165)),
                              SizedBox(
                                width: 10,
                              ),
                              Text('My Payments',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text(
                                  '\u{20B9} ' +
                                      globals.clientdata["DEPOSIT"].toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Row(
                            children: [
                              Icon(Icons.money_rounded,
                                  color: Color.fromARGB(255, 20, 169, 206)),
                              SizedBox(
                                width: 10,
                              ),
                              Text('My Dues',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text(
                                  '\u{20B9} ' +
                                      globals.clientdata["CLOSING_BALANCE"]
                                          .toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Row(
                            children: [
                              const Icon(Icons.currency_rupee_outlined,
                                  color: Color.fromARGB(255, 194, 30, 150)),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Last Payment',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text(
                                  '\u{20B9} ' +
                                      globals.clientdata["AMOUNT"].toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range_outlined,
                                  color: Color.fromARGB(255, 243, 135, 19)),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Last Payment Date',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text(
                                  globals.clientdata["LAST_PAYMENT_DT"]
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Row(
                            children: [
                              const Icon(Icons.report,
                                  color: Color.fromARGB(255, 59, 221, 140)),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Report',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Icon(Icons.double_arrow)
                            ],
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(32.0))),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Mobile No. :'),
                                      TextField(
                                        controller: _Mobile_NoController,
                                        decoration: InputDecoration(
                                            hintText: "Enter here Mobile No. "),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                        child: Text('OR',
                                            style: TextStyle(
                                                color: Colors.indigo)),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Bill No.:'),
                                      TextField(
                                        controller: _billnoController,
                                        decoration: InputDecoration(
                                            hintText: "Enter here Bill No.:  "),
                                      ),
                                      Center(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          color: Colors.green,
                                          child: TextButton(
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              globals.selectedClientid = globals
                                                  .clientdata["REFERENCE_ID"]
                                                  .toString();

                                              if (_billnoController.text ==
                                                      "" &&
                                                  _Mobile_NoController.text ==
                                                      "") {
                                                // return false;

                                                Fluttertoast.showToast(
                                                    msg: "Enter Valid Number",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 180, 17, 17),
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              } else if (_billnoController
                                                          .text !=
                                                      "" &&
                                                  _Mobile_NoController.text !=
                                                      "") {
                                                // return false;

                                                Fluttertoast.showToast(
                                                    msg: "Clear one value",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 180, 17, 17),
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              } else if (_billnoController
                                                          .text !=
                                                      "" ||
                                                  _Mobile_NoController.text !=
                                                      "") {
                                                globals.mobile_no =
                                                    _Mobile_NoController.text;
                                                globals.bill_no =
                                                    _billnoController.text;
                                                // ReportTabPage(0);
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ClientProfile(0)));
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }),
                  ],
                ),
              ),
            ),
          ]),
        )),
      ),
      bottomNavigationBar: AllBottomnavbars(),
    );
  }
}
