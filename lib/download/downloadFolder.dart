import 'dart:io';
import 'package:abugida_online/openPDF/localPDF.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';




class DownloadFolder extends StatefulWidget {
  @override
  _DownloadFolderState createState() => _DownloadFolderState();
}
class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle style, String url, String text})
      : super(
      style: style,
      text: text ?? url,
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          launch(url);
        });
}

class _DownloadFolderState extends State<DownloadFolder> {
  var _openResult = 'Unknown';

  _launchURL() async {
    const url = 'https://demo.trillium-elearing.com/storage/materials/pic1.jpg';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Directory rootPathResource;
  Directory rootPathAssignment;

  String filePath;
  String dirPath;

  FileTileSelectMode filePickerSelectMode = FileTileSelectMode.wholeTile;

  @override
  void initState() {
    super.initState();

    _prepareStorage();

  }

  Future<void> _prepareStorage() async {
    rootPathAssignment = Directory('storage/emulated/0/Assignment');
    rootPathResource = Directory('storage/emulated/0/Resource');
    // Create sample directory if not exists
    Directory sampleFolder = Directory('storage/emulated/0/Assignment');
    if (!sampleFolder.existsSync()) {
      sampleFolder.createSync();
    }
    Directory sampleFolderResource = Directory('storage/emulated/0/Resource');
    if (!sampleFolderResource.existsSync()) {
      sampleFolderResource.createSync();
    }
    // Create sample file if not exists
    File sampleFile = File('${sampleFolder.path}/Sample.txt');
    if (!sampleFile.existsSync()) {
      sampleFile.writeAsStringSync('FileSystem Picker sample file.');
    }
    File sampleFileResource = File('${sampleFolderResource.path}/Sample.txt');
    if (!sampleFileResource.existsSync()) {
      sampleFileResource.writeAsStringSync('FileSystem Picker sample file.');
    }
    setState(() {});
  }

  Future<void> _openFile(BuildContext context) async {
    String path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      rootDirectory: rootPathAssignment,
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      allowedExtensions: ['.jpg','.jpeg', '.png', '.pdf', '.doc', '.docx','.pptx', '.ppt'],
      fileTileSelectMode: filePickerSelectMode,
      requestPermission: () async =>
      await Permission.storage.request().isGranted,
    );
    String ggg;
    if (path != null) {
      File file = File('$path');
      String contents =  file.path;
      ggg=file.path;
      print(file.path);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(contents)));
    }
    print(path);
    if(path!=null) {
      final mimeType = lookupMimeType(ggg);
      print(mimeType);
      if(mimeType=='application/pdf')
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    new PDFScreen(title: 'assignment', path: ggg)));
      }
      else{

          OpenFile.open(ggg);
      }
    }
    setState(() {
      filePath = path;
    });
  }
  Future<void> _openFileResource(BuildContext context) async {
    String path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      rootDirectory: rootPathResource,
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      allowedExtensions: ['.jpg','.jpeg', '.png', '.pdf', '.doc', '.docx','.pptx', '.ppt'],
      fileTileSelectMode: filePickerSelectMode,
      requestPermission: () async =>
      await Permission.storage.request().isGranted,
    );
    String ggg;
    if (path != null) {
      File file = File('$path');
      String contents =  file.path;
      ggg=file.path;
      print(file.path);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(contents)));
    }
    print(path);
    final mimeType = lookupMimeType(ggg);
    print(mimeType);
    if(path!=null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              new PDFScreen(title: 'Resource', path: ggg)));
    }
    setState(() {
      filePath = path;
    });
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Theme Brightness Switch Button




                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10,20, 8),
                  child: GestureDetector(
                    onTap: (rootPathResource != null) ? () => _openFileResource(context) : null,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xff229546),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Align(
                              child: Text(
                                'Resource',  style: GoogleFonts.fredokaOne(
                                textStyle: TextStyle(color: Colors.white,letterSpacing: .5, fontSize: 20,),),),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),



                Divider(height: 40),

                // File picker section

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: GestureDetector(
                    onTap: (rootPathAssignment != null) ? () => _openFile(context) : null,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xff229546),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Align(
                              child: Text(
                                'Assignment',  style: GoogleFonts.fredokaOne(
                                textStyle: TextStyle(color: Colors.white,letterSpacing: .5, fontSize: 20,),),),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}