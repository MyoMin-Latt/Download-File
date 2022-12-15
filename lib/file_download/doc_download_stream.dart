import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocDownloadPage extends StatefulWidget {
  const DocDownloadPage({super.key});

  @override
  State<DocDownloadPage> createState() => _DocDownloadPageState();
}

class _DocDownloadPageState extends State<DocDownloadPage> {
  Future<void> downloadPdf(String url) async {
    Directory? directory = await getExternalStorageDirectory();
    String savePath = '${directory!.path}/Doc/${url.split('/').last}';
    log('urlPath => $savePath');
    await Dio().download(
      url,
      savePath,
      onReceiveProgress: (count, total) => log('count/total => $count/$total'),
    );
  }

  Future<void> getDownloadedDoc() async {
    Directory? directory = await getExternalStorageDirectory();
    Directory path = Directory('${directory!.path}/Doc/');
    List<FileSystemEntity> imageList = path.listSync();
    streamSink.add(imageList);
  }

  @override
  void initState() {
    super.initState();
    getDownloadedDoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download & Open File'),
        actions: [
          IconButton(
              onPressed: () async {
                await downloadPdf(doxUrlList[1])
                    .then((value) => getDownloadedDoc());
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
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(snapshot.data![index].path.split('/').last),
                    trailing: Text('${index + 1}'),
                    onTap: () async {
                      await OpenFile.open(snapshot.data![index].path);
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => OfflinePdfViewer(
                      //         pdfLink: snapshot.data![index].path),
                      //   ),
                      // );
                    },
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

List<String> doxUrlList = [
  'https://file-examples.com/wp-content/uploads/2017/02/file-sample_100kB.doc',
  'https://filesamples.com/formats/docx',
  'https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_100KB_DOCX.docx',
];

class OfflinePdfViewer extends StatelessWidget {
  final String pdfLink;
  const OfflinePdfViewer({super.key, required this.pdfLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Pdf Viewer'),
      ),
      body: SfPdfViewer.file(
        File(pdfLink),
      ),
    );
  }
}
