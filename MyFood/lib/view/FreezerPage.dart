import 'package:MyFoodLogin/view/FridgePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FreezerPage extends StatefulWidget {
  FreezerPage({Key key}) : super(key: key);

  @override
  _FreezerPageState createState() => _FreezerPageState();
}

class _FreezerPageState extends State<FreezerPage> {
  //FirebaseFirestore db = FirebaseFirestore.getInstance();

  //Initialize the database, text controller for food item, and amount controller for food item
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _textController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

//Ask for all of the food items from the current user
  Future getPosts() async {
    var db = FirebaseFirestore.instance;
    final User user = auth.currentUser;
    final uid = user.uid;

    QuerySnapshot qn = await db
        .collection("Users")
        .doc(uid)
        .collection("Drawer")
        .where("Type", isEqualTo: "Freezer")
        .get();

    return qn.docs;
  }

  //List<int> amount = <int>[/*2, 0, 10, 6, 52, 4, 0, 2, 1, 2, 3, 4, 5, 6, 7*/];
  //List<String> foodItem = <String>[];

//Function that is called when a new item is submitted.
//Submits the new food item from the text controller to the current user and setting its type to freezer
  onSubmit(String name, String amount) {
    final User user = auth.currentUser;
    final uid = user.uid;
    setState(() {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(uid) // user,user.uid
          .collection("Drawer")
          .doc(name)
          .set({
        "Name": name,
        "Type": "Freezer",
        "Amount": amount,
      });
    });
  }

//Function that is called when submitting a new amount for a food item.
//Sets the new amount of the current item for the current user to what is in the amount text field
  changeAmount(String item) {
    final User user = auth.currentUser;
    final uid = user.uid;
    setState(() {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("Drawer")
          .doc(item)
          .update({"Amount": _amountController.text});
    });
    _amountController.clear();
  }

//Deletes the current food item
  deleteItem(String item) {
    final User user = auth.currentUser;
    final uid = user.uid;
    setState(() {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("Drawer")
          .doc(item)
          .delete();
    });
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            constraints: BoxConstraints.expand(),
            //Set background image
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        "assets/images/fridge_section_background.png"),
                    fit: BoxFit.fill)),
            child: Column(
              children: <Widget>[
                //Top of page
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Back button
                    InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FridgePage())),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(width: 3),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            margin: EdgeInsets.only(
                                left: deviceWidth * .05,
                                top: deviceHeight * .02),
                            width: deviceWidth * .15,
                            height: deviceHeight * .045,
                            child: Center(
                              child: Text(
                                "Back",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontSize: deviceWidth * .03,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ))),
                  ],
                ),
                //Row with textbox and Add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Textbox to add food
                    Container(
                      width: deviceWidth * .6,
                      height: deviceHeight * .2,
                      margin: EdgeInsets.only(top: deviceHeight * .015),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffe0f7f3),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 3.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 3.0),
                            ),
                            hintText: 'Enter a Food Item Here'),
                      ),
                    ),
                    //Add Item Button
                    InkWell(
                        onTap: () {
                          //Amount Alert
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(_textController.text),
                                  content: SingleChildScrollView(
                                      child: ListBody(children: <Widget>[
                                    TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Color(0xffe0f7f3),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 3.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue, width: 3.0),
                                          ),
                                          hintText: 'Set Amount'),
                                    ),
                                    // Drop down UOM goes here
                                    new DropdownButton<String>(
                                      items: <String>[
                                        'Boxes',
                                        'Bags',
                                        'Pounds',
                                        'Ounces'
                                      ].map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (_) {},
                                    )
                                  ])),
                                  actions: <Widget>[
                                    //Submit Button
                                    InkWell(
                                      onTap: () {
                                        onSubmit(_textController.text,
                                            _amountController.text);
                                        Navigator.of(context).pop();
                                        _textController.clear();
                                      },
                                      child: Container(
                                          height: deviceHeight * .05,
                                          width: deviceWidth * .15,
                                          decoration: BoxDecoration(
                                              color: Colors.green[300],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Center(
                                            child: Text(
                                              "Submit",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ),

                                    //Cancel Button
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                          height: deviceHeight * .05,
                                          width: deviceWidth * .15,
                                          decoration: BoxDecoration(
                                              color: Colors.red[300],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Center(
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    )
                                  ],
                                );
                              });
                        },
                        //Actual "+" button
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/add_button.png"),
                                  fit: BoxFit.fill)),
                          width: deviceWidth * .11,
                          height: deviceHeight * .06,
                          margin: EdgeInsets.only(
                              bottom: deviceHeight * 0.105,
                              left: deviceWidth * .02),
                        )),
                  ],
                ),

                //List of items
                Row(
                  children: [
                    Container(
                      width: deviceWidth * .922,
                      height: deviceHeight * .663,
                      margin: EdgeInsets.only(
                          bottom: deviceHeight * 0, top: deviceHeight * 0),
                      child: Container(
                          margin: EdgeInsets.only(
                              bottom: deviceHeight * .0,
                              left: deviceWidth * 0.062),
                          decoration: BoxDecoration(
                              //color: Color(0xff3f6576),
                              color: Colors.blue[200],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              )),
                          //This is where the items are loaded in from the DB
                          child: FutureBuilder(
                            future: getPosts(),
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Text("Loading..."),
                                );
                              } else {
                                return ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (_, index) {
                                      //When an item is clicked, a dialog box to change the amount of that item or to delete the item appears
                                      return InkWell(
                                          onTap: () => showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(snapshot
                                                      .data[index]
                                                      .get("Name")),
                                                  content:
                                                      SingleChildScrollView(
                                                          child: ListBody(
                                                              children: <
                                                                  Widget>[
                                                        TextField(
                                                          controller:
                                                              _amountController,
                                                          decoration:
                                                              InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Color(
                                                                      0xffe0f7f3),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .blue,
                                                                        width:
                                                                            3.0),
                                                                  ),
                                                                  hintText:
                                                                      'Change Amount'),
                                                        ),
                                                      ])),
                                                  actions: <Widget>[
                                                    //Submit Button
                                                    InkWell(
                                                      onTap: () {
                                                        changeAmount(snapshot
                                                            .data[index]
                                                            .get("Name"));
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                          height: deviceHeight *
                                                              .05,
                                                          width:
                                                              deviceWidth * .15,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .green[300],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Center(
                                                            child: Text(
                                                              "Submit",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          )),
                                                    ),
                                                    //Cancel Button
                                                    InkWell(
                                                      onTap: () {
                                                        deleteItem(snapshot
                                                            .data[index]
                                                            .get("Name"));
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      //Delete Button
                                                      child: Container(
                                                          height: deviceHeight *
                                                              .05,
                                                          width:
                                                              deviceWidth * .15,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .red[300],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Center(
                                                            child: Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          )),
                                                    )
                                                  ],
                                                );
                                              }),
                                          //Individual Items
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0.0,
                                                  horizontal: 10.0),
                                              child: Card(
                                                  color: Colors.white,
                                                  child: ListTile(
                                                    title: Text(
                                                      snapshot.data[index]
                                                          .get("Name"),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    trailing: Text(
                                                      snapshot.data[index]
                                                          .get("Amount")
                                                          .toString(),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ))));
                                    });
                              }
                            },
                          )),
                    )
                  ],
                ),
              ],
            )));
  }
}
