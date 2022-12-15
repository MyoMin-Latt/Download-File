import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageDownloadFuturePage extends StatefulWidget {
  const ImageDownloadFuturePage({super.key});

  @override
  State<ImageDownloadFuturePage> createState() =>
      _ImageDownloadFuturePageState();
}

class _ImageDownloadFuturePageState extends State<ImageDownloadFuturePage> {
  List<FileSystemEntity> imageList = [];
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
    setState(() => imageList = path.listSync());
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
        title: const Text('Download & Open Image'),
        actions: [
          IconButton(
              onPressed: () async {
                await downloadImage(urlList[0])
                    .then((value) => getDownloadedImage());
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: ListView.builder(
        itemCount: imageList.length,
        itemBuilder: (context, index) => Card(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.file(
                File(imageList[index].path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              Positioned(
                child: IconButton(
                  onPressed: () {
                    imageList[index].delete();
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
                    child: Text(imageList[index].path.split('/').last)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> urlList = [
  'https://filesamples.com/samples/image/jpg/sample_1280%C3%97853.jpg',
  'https://sample-videos.com/img/Sample-jpg-image-50kb.jpg',
  'https://file-examples.com/storage/fe352586866388d59a8918d/2017/10/file_example_JPG_100kB.jpg',
  'https://download.samplelib.com/jpeg/sample-clouds-400x300.jpg',
  'https://download.samplelib.com/jpeg/sample-red-400x300.jpg',
  'https://download.samplelib.com/jpeg/sample-green-400x300.jpg',
  'https://download.samplelib.com/jpeg/sample-blue-400x300.jpg',
];
