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
    await Dio().download(
      url,
      savePath,
      onReceiveProgress: (count, total) => log('count/total => $count/$total'),
    );
  }

  Future<void> getDownloadedImage() async {
    Directory? directory = await getExternalStorageDirectory();
    Directory path = Directory('${directory!.path}/Image/');
    List<FileSystemEntity> imageList = path.listSync();
    streamSink.add(imageList);
  }

  @override
  void initState() {
    super.initState();
    getDownloadedImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download & Open File'),
        actions: [
          IconButton(
              onPressed: () async {
                await downloadImage(urlList[6])
                    .then((value) => getDownloadedImage());
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            log(snapshot.data.toString());
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Card(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.file(
                        File(snapshot.data![index].path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        child: IconButton(
                          onPressed: () {
                            snapshot.data![index].delete();
                            getDownloadedImage();
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 2,
                        bottom: 2,
                        child: Container(
                            color: Colors.black26,
                            padding: const EdgeInsets.all(4),
                            child: Text(
                                snapshot.data![index].path.split('/').last)),
                      ),
                    ],
                  ),
                ),
              );
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

StreamController<List<FileSystemEntity>> streamController = StreamController();
StreamSink streamSink = streamController.sink;
Stream<List<FileSystemEntity>> stream = streamController.stream;

List<String> urlList = [
  'https://filesamples.com/samples/image/jpg/sample_1280%C3%97853.jpg',
  'https://sample-videos.com/img/Sample-jpg-image-50kb.jpg',
  'https://file-examples.com/storage/fe352586866388d59a8918d/2017/10/file_example_JPG_100kB.jpg',
  'https://download.samplelib.com/jpeg/sample-clouds-400x300.jpg',
  'https://download.samplelib.com/jpeg/sample-red-400x300.jpg',
  'https://download.samplelib.com/jpeg/sample-green-400x300.jpg',
  'https://download.samplelib.com/jpeg/sample-blue-400x300.jpg',
];
