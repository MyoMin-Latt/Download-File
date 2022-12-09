import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  downloadImage(String url) async {
    Directory? directory = await getExternalStorageDirectory();
    String savePath = '${directory!.path}/Image/${url.split('/').last}';
    log('urlPath => $savePath');
    await Dio().download(
      url,
      savePath,
      onReceiveProgress: (count, total) => log('count/total => $count/$total'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download & Open File'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              downloadImage(
                  'https://sample-videos.com/img/Sample-jpg-image-50kb.jpg');
            },
            child: const Text('Download Image')),
      ),
    );
  }
}
