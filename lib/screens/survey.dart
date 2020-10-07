import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_tracer/widgets/badge.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_tracer/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'package:flutter_tracer/screens/visits.dart';

class SurveyScreen extends StatefulWidget {
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  Uint8List bytes = Uint8List(0);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map profile = {};
  String data;
  String userId;
  String dateEntry;
  String dateExit;
  String soreThroat;
  String headAche;
  String fever;
  String cough;
  String exposure;
  String travelHistory;
  String bodyPain;
  int indicator = 0;
  bool isDone = false;
  int companionId;
  String companionFirstName;
  String companionLastName;
  String companionProvince;
  String companionCity;
  String companionStreet;
  String companionPhoneNumber;
  String companionTemperature;
  String companionBarangay;
  var rawJson = ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7'];

  List<SmartSelectOption<String>> options = [
    SmartSelectOption<String>(value: 'Yes', title: 'Yes'),
    SmartSelectOption<String>(value: 'No', title: 'No'),
  ];

  DateTime now = DateTime.now();

  getProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    data = preferences.getString("user");
    setState(() {
      profile = json.decode(data);
      userId = profile["id"].toString();
      dateEntry = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      rawJson.insert(0, userId);
      rawJson.insert(1, dateEntry);
      var number = new Random();
      companionId = number.nextInt(900000) + 100000;
      rawJson.insert(9, companionId.toString());
    });
    print(data);
    print(rawJson);
    print(companionId);
    _generateBarCode(rawJson.toString());
  }

  Future submitCompanion() async {
    var data = {
      'companion_first_name': companionFirstName,
      'companion_last_name': companionLastName,
      'companion_street': companionStreet,
      'companion_barangay': companionBarangay,
      'companion_municipality': companionCity,
      'companion_province': companionProvince,
      'companion_temperature': companionTemperature,
      'companion_contact_number': companionPhoneNumber,
    };
    print(data);
    try {
      var res = await Network().authData(data, '/add_companion');
      var body = json.decode(res.body);
      if (body['success'] == true) {
        Navigator.pop(context);
      } else {
        print(body["message"]);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future _generateBarCode(String inputCode) async {
    Uint8List result = await scanner.generateBarCode(inputCode);
    this.setState(() => this.bytes = result);
    if (indicator >= 7) {
      setState(() {
        isDone = true;
      });
      final snackBar = SnackBar(
        duration: Duration(seconds: 5),
        content: Container(
            height: 40.0,
            child: Center(
              child: Text(
                'Generated successfully',
                style: TextStyle(fontSize: 16.0),
              ),
            )),
        backgroundColor: Colors.greenAccent,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    print("isDone = " + isDone.toString());
  }

  addCompanion() async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new SingleChildScrollView(
          child: Column(children: <Widget>[
            new Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                top: 12.0,
                bottom: 12.0,
                left: 0.0,
                right: 0.0,
              ),
              child: Text(
                "Companion",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            new TextField(
              textInputAction: TextInputAction.next,
              autofocus: true,
              onChanged: (value) {
                companionFirstName = value;
              },
              decoration: InputDecoration(
                labelText: "First Name",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion first name",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              autofocus: false,
              onChanged: (value) {
                companionLastName = value;
              },
              decoration: InputDecoration(
                labelText: "Last Name",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion last name",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              autofocus: false,
              onChanged: (value) {
               companionProvince = value;
              },
              decoration: InputDecoration(
                labelText: "Province",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion province",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              autofocus: false,
              onChanged: (value) {
                companionCity = value;
              },
              decoration: InputDecoration(
                labelText: "City / Municipality",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion municipality",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              autofocus: false,
              onChanged: (value) {
                companionBarangay = value;
              },
              decoration: InputDecoration(
                labelText: "Barangay",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion barangay",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              autofocus: false,
              onChanged: (value) {
                companionStreet = value;
              },
              decoration: InputDecoration(
                labelText: "House Unit / Street",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion house unit or street",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              autofocus: false,
              onChanged: (value) {
                companionPhoneNumber = value;
              },
              controller: TextEditingController(text: "+63"),
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion phone number",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            new TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              autofocus: false,
              onChanged: (value) {
                companionTemperature = value;
              },
              decoration: InputDecoration(
                labelText: "Temperature",
                labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Enter companion temperature",
                // prefixIcon: Icon(
                //   Icons.perm_identity,
                //   color: Colors.black,
                // ),
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
          ]),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Add Companion'),
              onPressed: () {
                submitCompanion();
              })
        ],
      ),
    );
  }

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Wait Lang!",
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return VisitScreen();
                  },
                ),
              );
            },
            tooltip: "Save",
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(
              height: 190,
              child: isDone
                  ? Image.memory(bytes)
                  : Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: ExactAssetImage('assets/806700.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
            ),
            SizedBox(
              height: 30,
              child: isDone
                  ? Text(
                      "Merchant will scan this generated\ndynamic code",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
                    )
                  : Text(
                      "Complete the survey first to generate\na dynamic code",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
                    ),
            ),
            // SizedBox(
            //   height: 20,
            // ),
            // StepsIndicator(
            //   selectedStep: indicator,
            //   nbSteps: 7,
            //   selectedStepColorOut: Colors.blue,
            //   selectedStepColorIn: Colors.blue,
            //   doneStepColor: Colors.blue,
            //   unselectedStepColor: Colors.red,
            //   doneLineColor: Colors.blue,
            //   undoneLineColor: Colors.red,
            //   isHorizontal: true,
            //   lineLength: 40,
            //   lineThickness: 1,
            //   doneStepSize: 10,
            //   unselectedStepSize: 10,
            //   selectedStepSize: 10,
            //   selectedStepBorderSize: 1,
            // ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                top: 25.0,
                left: 12.0,
              ),
              child: Text(
                "Required Questions",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                top: 20.0,
                left: 12.0,
                right: 12.0,
              ),
              child: Text(
                "All information submitted shall be encrypted, and strictly used only in compliance to the Philippine law, guidelines, and ordinances, in relation to business operation in light of COVID-19 responses.",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black45,
                ),
              ),
            ),

            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have sore throat?',
                value: soreThroat,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        soreThroat = val;
                        if (rawJson[2] == "Q1") {
                          indicator += 1;
                        }
                        if (rawJson.asMap().containsKey(2) == false) {
                          rawJson.insert(2, val);
                        } else {
                          rawJson.removeAt(2);
                          rawJson.insert(2, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(2));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have headache?',
                value: headAche,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        if (rawJson[3] == "Q2") {
                          indicator += 1;
                        }
                        headAche = val;
                        if (rawJson.asMap().containsKey(3) == false) {
                          rawJson.insert(3, val);
                        } else {
                          rawJson.removeAt(3);
                          rawJson.insert(3, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(3));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have fever?',
                value: fever,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        if (rawJson[4] == "Q3") {
                          indicator += 1;
                        }
                        fever = val;
                        if (rawJson.asMap().containsKey(4) == false) {
                          rawJson.insert(4, val);
                        } else {
                          rawJson.removeAt(4);
                          rawJson.insert(4, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(4));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have travel history?',
                value: travelHistory,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        if (rawJson[5] == "Q4") {
                          indicator += 1;
                        }
                        travelHistory = val;
                        if (rawJson.asMap().containsKey(5) == false) {
                          rawJson.insert(5, val);
                        } else {
                          rawJson.removeAt(5);
                          rawJson.insert(5, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(5));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have exposure?',
                value: exposure,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        if (rawJson[6] == "Q5") {
                          indicator += 1;
                        }
                        exposure = val;
                        if (rawJson.asMap().containsKey(6) == false) {
                          rawJson.insert(6, val);
                        } else {
                          rawJson.removeAt(6);
                          rawJson.insert(6, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(6));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have cough or colds?',
                value: cough,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        if (rawJson[7] == "Q6") {
                          indicator += 1;
                        }
                        cough = val;
                        if (rawJson.asMap().containsKey(7) == false) {
                          rawJson.insert(7, val);
                        } else {
                          rawJson.removeAt(7);
                          rawJson.insert(7, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(7));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 10.0),
            SmartSelect<String>.single(
                title: 'Do you have body pain?',
                value: bodyPain,
                options: options,
                modalType: SmartSelectModalType.bottomSheet,
                choiceType: SmartSelectChoiceType.radios,
                onChange: (val) => {
                      setState(() {
                        if (rawJson[8] == "Q7") {
                          indicator += 1;
                        }
                        bodyPain = val;
                        if (rawJson.asMap().containsKey(8) == false) {
                          rawJson.insert(8, val);
                        } else {
                          rawJson.removeAt(8);
                          rawJson.insert(8, val);
                        }
                        print(rawJson);
                        print(rawJson.asMap().containsKey(8));
                        _generateBarCode(rawJson.toString());
                      })
                    }),
            SizedBox(height: 80.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // onPressed: isDone ? () => addCompanion() : null,
        onPressed: () => addCompanion(),
        label: Text('Add Companion'),
        icon: Icon(Icons.add),
        backgroundColor: isDone ? Colors.pink : Colors.grey,
      ),
    );
  }
}
