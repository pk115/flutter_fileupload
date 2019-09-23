import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  File _image;
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  String Status;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    print(image);

    setState(() {
      _image = image;
      _path = image.path;
      _fileName = "image.jpg";
    });
    if (_image != null) {
      // SentIMG(image.path);
    }
  }

  Future SentIMG(String file, String filename) async {
    print("Call http");
    print(file);
    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      "name": "wendux",
      "age": 25,
      "file": await MultipartFile.fromFile(file, filename: filename),
//      "files": [
//        await MultipartFile.fromFile("./text1.txt", filename: "text1.txt"),
//        await MultipartFile.fromFile("./text2.txt", filename: "text2.txt"),
//      ]
    });
    print(file);

    var response =
        await dio.post("http://10.2.13.13:3000/upload", data: formData);
    print(response);
    setState(() {
      Status = response.toString();
    });
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
        print(_fileName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Upload File",
      home: Scaffold(
          appBar: AppBar(
            title: Text("Upload File"),
          ),
          body: ListView(
            children: <Widget>[

              Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(_image),
              ),
              RaisedButton(
                onPressed: () {
                  getImage();
                },
                child: const Text('Camera', style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new DropdownButton(
                    hint: new Text('LOAD PATH FROM'),
                    value: _pickingType,
                    items: <DropdownMenuItem>[
                      new DropdownMenuItem(
                        child: new Text('FROM AUDIO'),
                        value: FileType.AUDIO,
                      ),
                      new DropdownMenuItem(
                        child: new Text('FROM IMAGE'),
                        value: FileType.IMAGE,
                      ),
                      new DropdownMenuItem(
                        child: new Text('FROM VIDEO'),
                        value: FileType.VIDEO,
                      ),
                      new DropdownMenuItem(
                        child: new Text('FROM ANY'),
                        value: FileType.ANY,
                      ),
                      new DropdownMenuItem(
                        child: new Text('CUSTOM FORMAT'),
                        value: FileType.CUSTOM,
                      ),
                    ],
                    onChanged: (value) => setState(() {
                          _pickingType = value;
                          if (_pickingType != FileType.CUSTOM) {
                            _controller.text = _extension = '';
                          }
                        })),
              ),
              RaisedButton(
                onPressed: () {
                  _openFileExplorer();
                },
                child: const Text('Open File', style: TextStyle(fontSize: 20)),
              ),
              Text(
                'FilePath: $_path',
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
              RaisedButton(
                onPressed: () {
                  SentIMG(_path, _fileName);
                },
                child: const Text('Upload ', style: TextStyle(fontSize: 20)),
              ),
              Text("Upload Status : $Status")

            ],
          )),
    );
  }
}
