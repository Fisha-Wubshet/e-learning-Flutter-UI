import 'dart:math';

import 'package:abugida_online/pdftest.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:abugida_online/webview.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Resources extends StatefulWidget {
  final course_id;
  final course_name;

  Resources({
    this.course_id,
    this.course_name,
  });

  @override
  _ResourcesState createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  List users = [];
  bool isLoading = false;
  bool downloading = false;
  var progress = "";
  var path = "No Data";
  static final Random random = Random();
  var _onPressed;
  final imgUrl = "https://demo.trillium-elearing.com/storage/materials/Photosynthesis_1606674159.pdf";
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchUser();
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      '${widget.course_name} Resources',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredokaOne(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xffffffff),
                          letterSpacing: 2,
                          fontSize: 18,
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
  Future<void> downloadFile(title, urlPath) async {
    bool  checkPermission1= (await Permission.storage.status).isGranted;
    Dio dio = Dio();


    // print(checkPermission1);
    if (checkPermission1 == false) {
      await Permission.storage.request();
      checkPermission1=(await Permission.storage.status).isGranted;
    }
    if (checkPermission1 == true) {
      String dirloc = "";
      if (Platform.isAndroid) {
        dirloc = "storage/emulated/0/Resource/";
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
      }

      var randid = '${title}  _${random.nextInt(10000)}';
      try {
        FileUtils.mkdir([dirloc]);
        await dio.download('https://demo.trillium-elearing.com$urlPath', dirloc + randid.toString() + ".pdf",
            onReceiveProgress: (receivedBytes, totalBytes) {
              setState(() {
                downloading = true;
                progress =
                    ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
              });
            });
        setState(() {
          downloading = false;
          progress = "Download Completed.";
          path = dirloc + randid.toString();
          Fluttertoast.showToast(
              msg: 'Successfully downloaded $path',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        });
      } catch (e) {
        print(e);
        setState(() {
          downloading = false;

          Fluttertoast.showToast(
              msg: 'download failed',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        });

      }

    } else {
      setState(() {
        progress = "Permission Denied!";
        _onPressed = () {
          downloadFile(title, 'https://demo.trillium-elearing.com$urlPath');
        };
      });
    }
  }
  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url =
          Uri.parse("$httpUrl/api/showCourseResources/${widget.course_id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          users = items;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(
            msg: "Your Account is Locked",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        setState(() {
          users = [];
          isLoading = false;
        });
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

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(onRefresh: refreshList, child: getBody()),
    );
  }

  Widget getBody() {
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(
          child: const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)));
    }
    if (socketException || timeoutException) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/animation.png'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(
                    Icons.sync,
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
            )
          ],
        ),
      ));
    }
    return downloading
        ? Center(
      child: Container(
        height: 120.0,
        width: 200.0,
        child: Card(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:  CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Downloading File: $progress',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    )
        : SingleChildScrollView(
      child:  Column(
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
                StaggeredTile.fit(1),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return getCard(users[index]);
              }),
        ],
      ),
    );
  }

  Widget getCard(item) {
    var name = item['resource_title'];

    var payment_method = item['payment_method'];
    //==================================
    var dateTimeString = '${(item['updated_at'])}';
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    final format = DateFormat('yyyy-MM-dd h:mm a');
    final clockString = format.format(dateTime);

    //=====================================
    DateTime orderTime = DateTime.parse(item['updated_at']).toLocal();

    return InkWell(
      onTap: () {

        showDialog(
          context: context,
          builder: (BuildContext context ) => _buildrequestPopupDialog(context,  item['resource_title'], item['res_loc']),
        );
      },
      child: Card(
        elevation: 3,
        shadowColor: Color(0x502196F3),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.menu_book, color: Color(0xff229546)),
            title: Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$clockString',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildrequestPopupDialog(BuildContext context,title, path ) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  final mimeType = lookupMimeType(path);
                  print(mimeType);
                  if(mimeType=='image/png' || mimeType=='image/jpeg' || mimeType=='image/jpg'){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new WebViewPage(title: title,
                            link: "https://demo.trillium-elearing.com"+path)));
                  }
                  else
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new WebViewPage(
                                title: title,
                                link: "https://drive.google.com/viewerng/viewer?embedded=true&url=demo.trillium-elearing.com" + path)));
                  }
                },
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grid_view, color: Color(0xff229546),),
                      Text(
                        '  View',  style: GoogleFonts.roboto(
                        textStyle: TextStyle(color: Color(0xff000000), fontSize: 20, shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1.5, 1.5),
                            blurRadius: 3.0,
                            color: Color(0x2D7BA0E0),
                          ),
                        ],fontWeight: FontWeight.bold),),),
                    ],),),),),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Divider(color: Color(0xff229546)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  downloadFile(title,path);
                },
                child: Align(
                  alignment: Alignment.center,

                  child: Center(
                    child: Align(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_sharp, color: Color(0xff229546),),
                          Text(
                            '  Download File',  style: GoogleFonts.roboto(
                            textStyle: TextStyle(color: Color(0xff000000), fontSize: 20, shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.5, 1.5),
                                blurRadius: 3.0,
                                color: Color(0x2D7BA0E0),
                              ),
                            ],fontWeight: FontWeight.bold),),),
                        ],),),),),),),



          ],
        ),
      ),

      actions: <Widget>[
        new FlatButton(
          onPressed: () {

            Navigator.of(context).pop();


          },
          child: const Text('Close', style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold),),
        ),

      ],
    );
  }

}
