import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'ClientDashBoard.dart';
import 'globals.dart' as globals;

TextEditingController nameController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController newpasswordController = TextEditingController();
TextEditingController reEnterpasswordController = TextEditingController();
TextEditingController OtpController = TextEditingController();
var checking = "";

class ClientLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ClientLogin> {
  login1(username, password, BuildContext context) async {

    var isLoading = true;

    Map data = {
      "IP_USER_NAME": username,
      "IP_PASSWORD": '',
      "connection": "7"
      //"Server_Flag":""
    };

    print(data.toString());
    final response = await http.post(
        Uri.parse(globals.API_url + '/Logistics/APP_VALIDATION_MOBILE'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);

      globals.Connection_Flag = resposne["Data"][0]["CONNECTION_STRING"];
      globals.Report_URL = resposne["Data"][0]["REPORT_URL"];
      globals.Logo = resposne["Data"][0]["COMPANY_LOGO"];
      globals.API_url = resposne["Data"][0]["API_URL"];
      login(nameController.text, passwordController.text, context);
    }
  }

  login(username, password, BuildContext context) async {
    var isLoading = true;

    Map data = {
      "user_name": username.split(':')[1],
      "password": password,
      "connection": globals.Connection_Flag
      //"from_dt": 'null',
      //"to_dt": 'null'
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
        checking = "";
        String empID = user['REFERENCE_ID'].toString();
        globals.loginEmpid = user['REFERENCE_ID'].toString();
        globals.statusvisit = user['LOCK_STATUS'].toString();
        globals.MailId = user['EMAIL_ID'].toString();
        // globals.EmpName = user['EMP_NAME'].toString();
        globals.clientdata = resposne['Data'][0];
        globals.clientName = user['COMPANY_NAME'].toString();
        globals.controllerUserName = nameController.text.toString();
        globals.controllerPassword = passwordController.text.toString();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientDashboard()),
        );
        nameController.text = ''; passwordController.text="";
        // }

      } else {
        errormsg();
      }
    }
  }

  OTPGenerate() async {
    newpasswordController.text = '';
    reEnterpasswordController.text = '';
    OtpController.text = '';
    Map data = {
      "user_name": nameController.text.toString(), "session_id": "1"
      //"Server_Flag":""
    };
    final response = await http.post(
        Uri.parse(globals.API_url + '/AllDashboards/GenerateOTP'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);
      if (resposne["message"] == "success") {
        globals.generateOtp = resposne["Data"][0]["MSG_ID"].toString();
        OtpSent();
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const otpGenerate())));
      } else {
        return Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 238, 78, 38),
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Client App',
              style: TextStyle(
                  // fontFamily: 'Tapestry'
                  )),
          backgroundColor: Color(0xff123456),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Stack(children: [
          // Container(
          //   height: 450,
          //   decoration: BoxDecoration(
          //     image: new DecorationImage(
          //       // fit: BoxFit.cover,
          //       colorFilter: ColorFilter.mode(
          //           Colors.white.withOpacity(0.1), BlendMode.dstATop),
          //       image: new NetworkImage(
          //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjUzkE0CZ3zMzMG8_Bs8TRLC63Prv5WWwsIA&usqp=CAU',
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top:40),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  children: <Widget>[
                    Container(
                      height: 100.0,
                      width: 100.0,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage("assets/images/clientapplogo.png"),
                              fit: BoxFit.fitHeight)),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(25, 30, 25, 10),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_circle),
                          focusColor: Color(0xff123456),
                          labelText: 'User Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        OTPGenerate();
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          color: Color(0xff123456),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 70),
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xff123456),
                                Color(0xff123456),
                              ]),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Color.fromRGBO(
                                        0, 0, 0, 0.57), //shadow for button
                                    blurRadius: 5) //blur radius of shadow
                              ]),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.transparent,
                                onSurface: Colors.transparent,
                                shadowColor: Colors.transparent,
                                //make color or elevated button transparent
                              ),
                              onPressed: () {
                                checking = "";

                                print(nameController.text);
                                print(passwordController.text);

                                login1(nameController.text,
                                    passwordController.text, context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(),
                                child:
                                    Text("Login", style: TextStyle(fontSize: 24)),
                              ))),
                    ),
                    SizedBox(
                      height: 170,
                    ),
                    Column(
                      children: [
                        Text(
                          'Powered by',
                          style: TextStyle(fontFamily: 'Tapestry'),
                        ),
                        Text(
                          'Suvarna Technosoft Pvt Ltd.',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}

class otpGenerate extends StatefulWidget {
  const otpGenerate({Key? key}) : super(key: key);

  @override
  State<otpGenerate> createState() => _otpGenerateState();
}

class _otpGenerateState extends State<otpGenerate> {
  OTPValidate() async {
    if (OtpController.text.toString() == "") {
      plzEnterOtp();
      return false;
    }

    Map data = {
      "MSG_ID": globals.generateOtp.split('.')[0],
      "OTP": OtpController.text.toString()
      //"Server_Flag":""
    };
    final response = await http.post(
        Uri.parse(globals.API_url + '/AllDashboards/ValidateOTP'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);
      if (resposne["message"] == "success") {
        Successtoaster();
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const newPassPopup())));
      } else {
        return Fluttertoast.showToast(
            msg: "Invalid OTP",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 238, 78, 38),
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: [
                  TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          filled: true,
                          //  hintText: 'Enter text',
                          labelText: 'Enter OTP'),
                      controller: OtpController),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        OTPValidate();
                      },
                      child: Container(
                          width: 100,
                          height: 40,
                          decoration: const BoxDecoration(
                              color: Color(0xff123456),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                          child: const Center(
                            child: Text('APPLY',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white)),
                          )),
                    ),
                  ),
                ],
              ),
            ]));
  }
}

class newPassPopup extends StatefulWidget {
  const newPassPopup({Key? key}) : super(key: key);

  @override
  State<newPassPopup> createState() => _newPassPopupState();
}

class _newPassPopupState extends State<newPassPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: [
                  TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          filled: true,
                          //  hintText: 'Enter text',
                          labelText: 'Enter new Password'),
                      controller: newpasswordController),
                  TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          filled: true,
                          //  hintText: 'Enter text',
                          labelText: 'Confirm Password'),
                      controller: reEnterpasswordController),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        NewPassword(context);
                      },
                      child: Container(
                          width: 100,
                          height: 40,
                          decoration: const BoxDecoration(
                              color: Color(0xff123456),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                          child: const Center(
                            child: Text('Submit',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white)),
                          )),
                    ),
                  ),
                ],
              ),
            ]));
  }
}

Successtoaster() {
  return Fluttertoast.showToast(
      msg: "Validate Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 93, 204, 89),
      textColor: Colors.white,
      fontSize: 16.0);
}

OtpSent() {
  return Fluttertoast.showToast(
      msg: "OTP Sent",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 126, 224, 123),
      textColor: Colors.white,
      fontSize: 16.0);
}

errormsg() {
  return Fluttertoast.showToast(
      msg: "Invalid UserName and Password",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 238, 26, 11),
      textColor: Colors.white,
      fontSize: 16.0);
}

passwordmismatch() {
  return Fluttertoast.showToast(
      msg: "Password is mismatch",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 238, 26, 11),
      textColor: Colors.white,
      fontSize: 16.0);
}

plzEnterOtp() {
  return Fluttertoast.showToast(
      msg: "Enter OTP",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 236, 231, 230),
      textColor: Colors.black,
      fontSize: 16.0);
}

NewPassword(BuildContext context) async {
  if (newpasswordController.text.toString() !=
      reEnterpasswordController.text.toString()) {
    passwordmismatch();
    return false;
  }
  Map data = {
    "user_name": nameController.text.toString(),
    "password": newpasswordController.text.toString()
    //"Server_Flag":""
  };
  final response = await http.post(
      Uri.parse(globals.API_url + '/AllDashboards/UpdatePassword'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: data,
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> resposne = jsonDecode(response.body);
    if (resposne["message"] == "success") {
      Successtoaster();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ClientLogin()));
    } else {
      return Fluttertoast.showToast(
          msg: "Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromARGB(255, 238, 78, 38),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
