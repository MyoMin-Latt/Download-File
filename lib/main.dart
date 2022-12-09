import 'dart:async';
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
  Future<void> downloadImage(String url) async {
    Directory? directory = await getExternalStorageDirectory();
    String savePath = '${directory!.path}/Image/${url.split('/').last}';
    log('urlPath => $savePath');
    await Dio()
        .download(
          url,
          savePath,
          onReceiveProgress: (count, total) =>
              log('count/total => $count/$total'),
        )
        .then((value) => streamSink.add(savePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download & Open File'),
        actions: [
          IconButton(
              onPressed: () async {
                await downloadImage(urlList[1]);
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.file(File(snapshot.data.toString()));
            } else if (snapshot.hasError) {
              return const Text('Snapshot has Error');
            } else {
              return const Text('No Image');
            }
          },
        ),
      ),
    );
  }
}

StreamController<String> streamController = StreamController();
StreamSink streamSink = streamController.sink;
Stream<String> stream = streamController.stream;

List<String> urlList = [
  'https://filesamples.com/samples/image/jpg/sample_1280%C3%97853.jpg',
  'https://sample-videos.com/img/Sample-jpg-image-50kb.jpg',
  'https://file-examples.com/storage/fe352586866388d59a8918d/2017/10/file_example_JPG_100kB.jpg',
];
