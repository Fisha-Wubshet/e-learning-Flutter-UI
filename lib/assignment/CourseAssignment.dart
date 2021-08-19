import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abugida_online/main.dart';
import 'package:abugida_online/resources/Resources.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//================================================================================

class CourseAssignment extends StatefulWidget {
  @override
  _CourseAssignmentState createState() => _CourseAssignmentState();
}

class _CourseAssignmentState extends State<CourseAssignment> {
  _getRequests() async {
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(loginVerified: true)),
          (Route<dynamic> route) => false);
    });
  }

  List Courses = [];
  List BalanceArray = [];
  bool isLoading = false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  double Balance = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchCourses();
  }

  fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/getMyCourseAssignments");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          Courses = items;
          isLoading = false;
        });
      } else {
        Courses = [];
        isLoading = false;
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        isLoading = false;
        timeoutException = true;
      });
      Fluttertoast.showToast(
          msg: "connection timeout, try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } on SocketException catch (e) {
      print('Socket Error: $e');
      setState(() {
        isLoading = false;

        socketException = true;
      });
      Fluttertoast.showToast(
          msg: "no connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } on Error catch (e) {
      print('$e');
      setState(() {
        isLoading = false;
        catchException = true;
      });
      Fluttertoast.showToast(
          msg: "error occurred while loading",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  Material myItems1(int color) {
    return Material(
      color: Color(0xff229546),
      elevation: 14,
      shadowColor: Color(0x502196F3),
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          topLeft: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //text
                  Text(
                    'My Courses',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredokaOne(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xffffffff),
                        letterSpacing: 2,
                        fontSize: 24,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 5.0,
                            color: Color(0x48000000),
                          ),
                        ],
                      ),
                    ),
                  )

                  //balance
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: refreshList,
        child: Scaffold(
          body: socketException || timeoutException
              ? NoConnectionBody()
              : getBody(),
        ));
  }

  Widget getBody() {
    if (Courses.contains(null) || Courses.length < 0 || isLoading) {
      return Material(
          child: SpinKitThreeBounce(
        color: Color(0xff229546),
        size: 30,
      ));
    }
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 8, right: 8),
              child: StaggeredGridView.count(
                shrinkWrap: true,
                crossAxisCount: 1,
                physics: ScrollPhysics(),
                children: <Widget>[
                  myItems1(0xff000000),
                ],
                staggeredTiles: [
                  StaggeredTile.extent(1, 50.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: StaggeredGridView.countBuilder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                crossAxisCount: 2,
                itemCount: Courses.length,
                itemBuilder: (context, index) {
                  return getCard(Courses[index]);
                },
                staggeredTileBuilder: (int index) =>
                    StaggeredTile.extent(1, 110.0),
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InkWell getCard(item) {
    var courseName = item['courseName'];
    var quantity = item['resource_count'];

    return InkWell(
      onTap: () => Navigator.of(context)
          .push(
            new MaterialPageRoute(
                builder: (_) => new Resources(course_id: item['id'])),
          )
          .then((val) => val ? _getRequests() : null),
      child: Material(
        color: Color(0xff229546),
        elevation: 14,
        shadowColor: Color(0x502196F3),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //text
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.33,
                        child: Text(
                          courseName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xffffffff),
                              letterSpacing: 1,
                              fontSize: 20,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Color(0x48000000),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //Icon
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget NoConnectionBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/animation.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                icon: Icon(
                  Icons.refresh_sharp,
                  color: Colors.orange,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    socketException = false;
                    timeoutException = false;
                  });
                  refreshList();
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              margin: EdgeInsets.only(top: 15.0),
              child: RaisedButton(
                onPressed: () {},
                elevation: 0.0,
                color: Color(0xff82C042),
                child: Text("Download", style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
