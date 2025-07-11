import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/educational_service.dart';

class EducationalContentPage extends StatefulWidget {
  final String uid;

  const EducationalContentPage({super.key, required this.uid});

  @override
  State<EducationalContentPage> createState() => _EducationalContentPageState();
}

class _EducationalContentPageState extends State<EducationalContentPage> {
  final EducationalService service = EducationalService();
  final Map<String, bool> expandedText =
      {}; // Track expanded state for each doc

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Content'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrUpdateDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getEducationalContent(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final contents = snapshot.data!.docs;

          if (contents.isEmpty) {
            return const Center(child: Text('No content available.'));
          }

          return ListView.builder(
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final doc = contents[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final isExpanded = expandedText[docId] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8, // Increased elevation for a more elevated look
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildContentPreview(data, docId, isExpanded),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              _showAddOrUpdateDialog(
                                context,
                                docId: docId,
                                existingData: data,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await service.deleteContent(docId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContentPreview(
    Map<String, dynamic> data,
    String docId,
    bool isExpanded,
  ) {
    final type = data['type'];
    final content = data['content'];

    switch (type) {
      case 'text':
        final shortText =
            content.length > 150 ? content.substring(0, 150) : content;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isExpanded ? content : shortText,
              style: const TextStyle(fontSize: 16),
            ),
            if (content.length > 150)
              TextButton(
                onPressed: () {
                  setState(() {
                    expandedText[docId] = !isExpanded;
                  });
                },
                child: Text(isExpanded ? 'Read Less' : 'Read More'),
              ),
          ],
        );
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            content,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case 'video':
        return _fileTile(Icons.videocam, 'Video', content);
      case 'audio':
        return _fileTile(Icons.audiotrack, 'Audio', content);
      case 'document':
        return _fileTile(Icons.insert_drive_file, 'Document', content);
      default:
        return const Text('Unknown content type');
    }
  }

  Widget _fileTile(IconData icon, String label, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.green, size: 36),
      title: Text(label),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: () {
          // Open file with url_launcher or another viewer
        },
      ),
    );
  }

  void _showAddOrUpdateDialog(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? existingData,
  }) {
    final titleController = TextEditingController(
      text: existingData?['title'] ?? '',
    );
    final contentController = TextEditingController(
      text:
          existingData != null && existingData['type'] == 'text'
              ? existingData['content']
              : '',
    );
    final formKey = GlobalKey<FormState>();

    String selectedType = existingData?['type'] ?? 'text';
    File? selectedFile;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        docId == null ? 'Add Content' : 'Update Content',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      if (selectedType == 'text')
                        TextFormField(
                          controller: contentController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                          ),
                          validator:
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Content is required'
                                      : null,
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: contentController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'File path',
                                ),
                                validator:
                                    (_) =>
                                        selectedFile == null && docId == null
                                            ? 'Select a file'
                                            : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.folder_open),
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions:
                                          selectedType == 'video'
                                              ? ['mp4', 'mov']
                                              : selectedType == 'audio'
                                              ? ['mp3', 'wav']
                                              : selectedType == 'document'
                                              ? ['pdf', 'doc', 'docx']
                                              : ['jpg', 'jpeg', 'png'],
                                    );

                                if (result != null &&
                                    result.files.single.path != null) {
                                  setState(() {
                                    selectedFile = File(
                                      result.files.single.path!,
                                    );
                                    contentController.text = selectedFile!.path;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'text', child: Text('Text')),
                          DropdownMenuItem(
                            value: 'image',
                            child: Text('Image'),
                          ),
                          DropdownMenuItem(
                            value: 'video',
                            child: Text('Video'),
                          ),
                          DropdownMenuItem(
                            value: 'audio',
                            child: Text('Audio'),
                          ),
                          DropdownMenuItem(
                            value: 'document',
                            child: Text('Document'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedType = value;
                              contentController.clear();
                              selectedFile = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final title = titleController.text.trim();
                          String finalContent = contentController.text.trim();

                          if (selectedType != 'text' && selectedFile != null) {
                            final fileName = selectedFile!.uri.pathSegments.last;
                            final downloadUrl = await service.uploadFile(
                              selectedFile!,
                              fileName,
                            );

                            if (downloadUrl == null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('File upload failed'),
                                ),
                              );
                              return;
                            }

                            finalContent = downloadUrl;
                          }

                          if (docId == null) {
                            await service.addContent(
                              title: title,
                              type: selectedType,
                              content: finalContent,
                            );
                          } else {
                            await service.updateContent(
                              docId: docId,
                              title: title,
                              type: selectedType,
                              content:
                                  selectedType == 'text'
                                      ? finalContent
                                      : selectedFile != null
                                      ? finalContent
                                      : existingData!['content'],
                            );
                          }

                          if (!mounted) return;
                          Navigator.pop(ctx);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(docId == null ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
