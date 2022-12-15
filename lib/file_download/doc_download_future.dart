import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocDownloadFuturePage extends StatefulWidget {
  const DocDownloadFuturePage({super.key});

  @override
  State<DocDownloadFuturePage> createState() => _DocDownloadFuturePageState();
}

class _DocDownloadFuturePageState extends State<DocDownloadFuturePage> {
  List<FileSystemEntity> docList = [];
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
    setState(() => docList = path.listSync());
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
                await downloadPdf(doxUrlList[0])
                    .then((value) => getDownloadedDoc());
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: docList.isEmpty
          ? const Center(child: Text('Empty Data'))
          : ListView.builder(
              itemCount: docList.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(docList[index].path.split('/').last),
                  trailing: Text('${index + 1}'),
                  onTap: () async {
                    await OpenFile.open(docList[index].path);
                  },
                ),
              ),
            ),
    );
  }
}

List<String> doxUrlList = [
  'https://file-examples.com/wp-content/uploads/2017/02/file-sample_100kB.doc',
  'https://filesamples.com/formats/docx',
  'https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_100KB_DOCX.docx',
];
