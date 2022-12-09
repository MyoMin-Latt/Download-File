import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Download',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download & Open File'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              openFile(
                  url:
                      'https://file-examples.com/storage/fe352586866388d59a8918d/2017/04/file_example_MP4_640_3MG.mp4',
                  fileName: 'file_example_MP4_640_3MG.mp4');
            },
            child: const Text('Download & Open File')),
      ),
    );
  }

  Future<void> openFile({required String url, String? fileName}) async {
    final file = await downloadFile(url, fileName!);
    if (file == null) return;
    print('Path : ${file.path}');
    OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url, String fileName) async {
    final appStorge = await getApplicationDocumentsDirectory();
    final file = File('${appStorge.path}/$fileName');

    try {
      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0,
          ));

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      return null;
    }
  }
}
