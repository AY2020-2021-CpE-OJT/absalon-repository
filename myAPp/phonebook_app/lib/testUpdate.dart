import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_app/DataFromAPI.dart';

class ContactDataUpdate {
  final String lastName;
  final String firstName;
  final List<String> phoneNumbers;

  ContactDataUpdate(this.lastName, this.firstName, this.phoneNumbers);
}

class updateContact extends StatefulWidget {
  const updateContact({Key? key}) : super(key: key);
  @override
  _updateContactState createState() => _updateContactState();
}

class _updateContactState extends State<updateContact> {

  int key = 0, checkAdd = 0, listNumber = 1, _count = 2;
  String val = '';
  RegExp digitValidator = RegExp("[0-9]+");

  bool isANumber = true;
  String fname = '', lname = '';

  final fnameController = TextEditingController(text: 'Dummy');
  final lnameController = TextEditingController();

  List<TextEditingController> pnumControllers = <TextEditingController>[
    TextEditingController()
  ];

  final FocusNode fnameFocus = FocusNode();
  final FocusNode lnameFocus = FocusNode();

  List<ContactDataUpdate> contactsAppend = <ContactDataUpdate>[];

  void saveContact() {
    List<String> pnums = <String>[];
    for (int i = 0; i < _count; i++) {
      pnums.add(pnumControllers[i].text);
    }
    List<String> reversedpnums = pnums.reversed.toList();
    setState(() {
      contactsAppend.insert(0, ContactDataUpdate(lnameController.text, fnameController.text, reversedpnums));
    });
    print('Status Append Contacts [Success]');
  }

  @override
  void initState() {
    super.initState();
    _count = 1;
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    for (int i = 0; i < _count; i++) {
      pnumControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Update Contact", style: TextStyle(color: Color(0xFF5B3415))),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  key = 0;
                  checkAdd = 0;
                  listNumber = 1;
                  _count = 1;
                  fnameController.clear();
                  lnameController.clear();
                  pnumControllers.clear();
                  pnumControllers = <TextEditingController>[
                    TextEditingController()
                  ];
                });
              },
            )
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: fnameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: fnameFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, fnameFocus, lnameFocus);
                  },
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF5B3415),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFCC13A),
                      ),
                    ),
                    //errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    labelText: 'First name',

                    suffixIcon: IconButton(
                      onPressed: fnameController.clear,
                      icon: Icon(Icons.cancel),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: lnameController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: lnameFocus,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF5B3415),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFCC13A),
                      ),
                    ),
                    //errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    labelText: 'Last Name',
                    suffixIcon: IconButton(
                      onPressed: lnameController.clear,
                      icon: Icon(Icons.cancel),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Contact Number/s: $listNumber",
                    style: TextStyle(color: Color(0xFF5B3415))),
                SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: _count,
                      itemBuilder: (context, index) {
                        return _row(index, context);
                      }),
                ),
                //Text(_result),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: const Text("Confirm",
                      style: TextStyle(
                        color: Color(0xFF5B3415),
                        fontWeight: FontWeight.bold,
                      )),
                  content: const Text("Confirm creating this contact"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("CANCEL",
                            style: TextStyle(color: Colors.redAccent))),
                    TextButton(
                      onPressed: () {
                        saveContact();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CheckScreen(todo: contactsAppend)),
                                (_) => false);
                      },
                      child: const Text("CONFIRM",
                          style: TextStyle(color: Color(0xFFFCC13A))),
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.save),
          label: Text("Save Changes"),
          foregroundColor: Color(0xFFFCC13A),
          backgroundColor: Color(0xFF5B3415),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: const Text("Are you sure?",
              style: TextStyle(
                color: Color(0xFF5B3415),
                fontWeight: FontWeight.bold,
              )),
          content: const Text("Go back to home and no changes will be made"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("CANCEL",
                    style: TextStyle(color: Colors.redAccent))),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DataFromAPI()),
                        (_) => false);
              },
              child: const Text("CONFIRM",
                  style: TextStyle(color: Color(0xFFFCC13A))),
            ),
          ],
        );
      },
    );
    return new Future.value(true);
  }

  _row(int key, context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            controller: pnumControllers[key],
            textCapitalization: TextCapitalization.sentences,
            maxLength: 11,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF5B3415),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFFCC13A),
                ),
              ),
              // errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorText: isANumber ? null : "Please enter a number",
              contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              labelText: 'Phone number',
              suffixIcon: IconButton(
                onPressed: pnumControllers[key].clear,
                icon: Icon(Icons.cancel),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: _addRemoveButton(key == checkAdd, key),
          ),
        ),
      ],
    );
  }

  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }

  Widget _addRemoveButton(bool isTrue, int index) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isTrue) {
          setState(() {
            _count++;
            checkAdd++;
            listNumber++;
            pnumControllers.insert(0, TextEditingController());
          });
        } else {
          setState(() {
            _count--;
            checkAdd--;
            listNumber--;
            pnumControllers.removeAt(index);
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: (isTrue) ? Color(0xFFFCC13A) : Colors.redAccent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(
          (isTrue) ? Icons.add : Icons.remove,
          color: Colors.white70,
        ),
      ),
    );
  }
}

_fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

class CheckScreen extends StatelessWidget {
  final List<ContactDataUpdate> todo;

  const CheckScreen({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> strHold = <String>[];
    //final String specificID = todo[index]['_id'];
    Future<http.Response> createAlbum(String fname, String lname, List pnums) {
      return http.patch(
        Uri.parse('https://jwa-phonebook-api.herokuapp.com/contacts/update/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone_numbers': pnums,
          'first_name': fname,
          'last_name': lname,
        }),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Successful')),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: todo.length,
            itemBuilder: (context, index) {
              createAlbum(todo[index].firstName, todo[index].lastName,
                  todo[index].phoneNumbers);
              return Container(
                child: Column(
                  children: <Widget>[
                    Text('\nSuccessfully Updated',
                        style: TextStyle(
                            color: Color(0xFF5B3415),
                            fontWeight: FontWeight.bold,
                            fontSize: 40)),
                    Text(
                        '\n\nFirst Name: ${todo[index].firstName} \n\nLast Name: ${todo[index].lastName} \n\nContact/s:',
                        style:
                        TextStyle(color: Color(0xFF5B3415), fontSize: 24)),
                    for (var strHold in todo[index].phoneNumbers)
                      Text('\n' + strHold,
                          style: TextStyle(
                              color: Color(0xFF5B3415), fontSize: 20)),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        child: new Text(
                          "Done",
                          style: new TextStyle(
                              fontSize: 20.0, color: Color(0xFFFCC13A)),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/screen1', (_) => false);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFF5B3415),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.all(20)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
